"""Apply prebuilt desktop themes without evaluating or building Nix."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

import json5

THEMES = {
    "gruvbox": ("Gruvbox Dark Hard", "Gruvbox Light Hard"),
    "rose-pine": ("Rose Pine", "Rose Pine Dawn"),
    "catppuccin": ("Catppuccin Mocha", "Catppuccin Latte"),
}
CODE_THEMES = {**THEMES, "rose-pine": ("Rosé Pine", "Rosé Pine Dawn")}


def write(path, text):
    """Replace our own file atomically, keeping store targets untouched."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as tmp:
        tmp.write(text)
    os.replace(tmp.name, path)


def run(*args):
    if shutil.which(args[0]):
        try:
            result = subprocess.run(args, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                                    text=True, timeout=10)
        except (OSError, subprocess.TimeoutExpired) as error:
            print(f"Could not refresh {args[0]}: {error}")
            return
        if result.returncode:
            print(f"Could not refresh {args[0]}: {result.stderr.strip()}")


def reload_ghostty():
    """Reload the existing GTK application without starting or closing it."""
    if not shutil.which("gdbus"):
        return
    try:
        owner = subprocess.run([
            "gdbus", "call", "--session", "--dest", "org.freedesktop.DBus",
            "--object-path", "/org/freedesktop/DBus",
            "--method", "org.freedesktop.DBus.NameHasOwner", "com.mitchellh.ghostty",
        ], capture_output=True, text=True, timeout=2)
    except (OSError, subprocess.TimeoutExpired):
        return
    if owner.returncode == 0 and owner.stdout.strip() == "(true,)":
        run("gdbus", "call", "--session", "--dest", "com.mitchellh.ghostty",
            "--object-path", "/com/mitchellh/ghostty",
            "--method", "org.gtk.Actions.Activate", "reload-config", "[]", "{}")


def skip_trivia(text, pos):
    """Skip JSONC whitespace and comments without changing their contents."""
    while pos < len(text):
        if text[pos].isspace() or text[pos] == "\ufeff":
            pos += 1
        elif text.startswith("//", pos):
            end = text.find("\n", pos)
            pos = len(text) if end < 0 else end + 1
        elif text.startswith("/*", pos):
            end = text.find("*/", pos + 2)
            if end < 0:
                raise ValueError("Unclosed comment")
            pos = end + 2
        else:
            break
    return pos


def parse_value(text, pos):
    value, error, end = json5.parse(text, start=pos, consume_trailing=False,
                                  allow_duplicate_keys=False)
    if error:
        raise ValueError(error)
    return value, end


def update_json(path, settings):
    """Patch top-level JSONC values while preserving comments and UI formatting."""
    if not path.exists():
        return
    try:
        original = path.read_bytes().decode("utf-8")
        value = json5.loads(original, allow_duplicate_keys=False)
        if not isinstance(value, dict):
            raise ValueError("Expected a settings object")
        edits = []
        pos = skip_trivia(original, 0) + 1  # Opening object brace.
        last_value_end = None
        trailing_comma = False
        while True:
            pos = skip_trivia(original, pos)
            if original[pos] == "}":
                break
            key, pos = parse_value(original, pos)
            pos = skip_trivia(original, pos)
            if original[pos] != ":":
                raise ValueError("Expected a property separator")
            start = skip_trivia(original, pos + 1)
            old_value, end = parse_value(original, start)
            if key in settings and old_value != settings[key]:
                edits.append((start, end, json.dumps(settings[key], ensure_ascii=False)))
            last_value_end = end
            pos = skip_trivia(original, end)
            trailing_comma = original[pos] == ","
            if trailing_comma:
                pos += 1
        missing = {key: val for key, val in settings.items() if key not in value}
        if missing:
            newline = "\r\n" if "\r\n" in original else "\n"
            if last_value_end is not None and not trailing_comma:
                edits.append((last_value_end, last_value_end, ","))
            additions = newline + "".join(
                f"  {json.dumps(key)}: {json.dumps(val, ensure_ascii=False)},{newline}"
                for key, val in missing.items()
            )
            edits.append((pos, pos, additions))
        if not edits:
            return
        candidate = original
        for start, end, replacement in sorted(edits, reverse=True):
            candidate = candidate[:start] + replacement + candidate[end:]
        # Validate before replacing anything, including unusual user formatting.
        json5.loads(candidate, allow_duplicate_keys=False)
        if path.read_bytes().decode("utf-8") != original:
            print(f"Skipped {path}: settings changed while applying the theme")
            return
        write(path, candidate)
    except (ValueError, OSError, IndexError, TypeError) as error:
        print(f"Skipped {path}: {error}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assets", type=Path, required=True)
    parser.add_argument("--wallpapers", type=Path, required=True)
    parser.add_argument("command", choices=["mode", "theme", "apply"])
    parser.add_argument("value", nargs="?")
    args = parser.parse_args()
    if args.command == "mode" and args.value not in ("dark", "light", "toggle"):
        parser.error("usage: theme-switch dark|light|toggle")
    if args.command == "theme" and args.value not in THEMES:
        parser.error("usage: theme-set gruvbox|rose-pine|catppuccin")

    home = Path.home()
    config = home / ".config"
    state = config / "dotfiles"
    runtime = home / ".local/state/dotfiles-theme"
    runtime.mkdir(parents=True, exist_ok=True)
    with (runtime / "lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        def read(name, default):
            path = state / name
            return path.read_text().strip() if path.exists() else default
        mode = read("colorScheme", "dark")
        theme = read("theme", "gruvbox")
        if args.command == "mode":
            mode = ("light" if mode == "dark" else "dark") if args.value == "toggle" else args.value
        elif args.command == "theme":
            theme = args.value
        if mode not in ("light", "dark") or theme not in THEMES:
            parser.error("Invalid saved theme state; choose a valid theme and mode")
        bundle = args.assets / f"{theme}-{mode}"
        if not bundle.is_dir():
            parser.error(f"Missing theme bundle: {bundle}; rebuild Home Manager once")

        # One atomic symlink exchange updates all GTK assets together.
        pending = runtime / "current.next"
        pending.unlink(missing_ok=True)
        pending.symlink_to(bundle)
        os.replace(pending, runtime / "current")
        slug = f"Dotfiles{theme.replace('-', '').title()}{mode.title()}"
        # Preserve KDE key case when copying the generated scheme.
        text = (bundle / "desktop.colors").read_text()
        text = "\n".join(f"Name={slug}" if line.startswith("Name=") else line
                         for line in text.splitlines()) + "\n"
        scheme = home / ".local/share/color-schemes" / f"{slug}.colors"
        write(scheme, text)
        index = int(mode == "light")
        write(state / "ghostty-theme", f"theme = {THEMES[theme][index]}\n")
        write(state / "colorScheme", mode + "\n")
        write(state / "theme", theme + "\n")

        # KDE broadcasts this change to Qt and the desktop portal (Electron).
        run("plasma-apply-colorscheme", str(scheme))
        run("gsettings", "set", "org.gnome.desktop.interface", "color-scheme", f"prefer-{mode}")
        run("gsettings", "set", "org.gnome.desktop.interface", "gtk-theme",
            "adw-gtk3-dark" if mode == "dark" else "adw-gtk3")
        update_json(config / "Code/User/settings.json", {"workbench.colorTheme": CODE_THEMES[theme][index]})
        zed = json.loads((bundle / "zed.json").read_text())
        write(config / "zed/themes/dotfiles.json", json.dumps(zed))
        update_json(config / "zed/settings.json", {"theme": zed["themes"][0]["name"]})
        wallpaper = args.wallpapers / f"{theme}.png"
        if wallpaper.exists() and args.command != "mode":
            run("plasma-apply-wallpaperimage", str(wallpaper))
        reload_ghostty()
        print(f"Theme: {theme} {mode} (no rebuild).")


if __name__ == "__main__":
    main()
