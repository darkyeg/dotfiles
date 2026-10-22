"""Switch at local sunrise/sunset, preserving manual choices until the next event."""
import argparse
from datetime import datetime, timedelta
import fcntl
import math
import os
from pathlib import Path
import subprocess
import tempfile
from zoneinfo import ZoneInfo

from astral import Observer
from astral.sun import sunrise, sunset


def solar_phase(observer, now):
    rise = sunrise(observer, date=now.date(), tzinfo=now.tzinfo)
    setting = sunset(observer, date=now.date(), tzinfo=now.tzinfo)
    if rise <= now < setting:
        return "light", rise, rise, setting
    last_sunset = setting if now >= setting else sunset(
        observer, date=now.date() - timedelta(days=1), tzinfo=now.tzinfo)
    return "dark", last_sunset, rise, setting


def show_status(observer, now, rise, setting, disabled):
    try:
        running = subprocess.run(
            ["systemctl", "--user", "is-active", "--quiet", "theme-solar.timer"],
            check=False, timeout=2,
        ).returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        running = False
    enabled = running and not disabled.exists()
    current_file = Path.home() / ".config/dotfiles/colorScheme"
    current = current_file.read_text().strip() if current_file.exists() else "unknown"
    clock = lambda value: value.strftime("%I:%M %p").lstrip("0")
    city = str(now.tzinfo).rsplit("/", 1)[-1].replace("_", " ")
    print(f"Auto theme: {'On' if enabled else 'Off'} ({city})")
    print(f"Current:    {current.capitalize()}")
    print(f"Sunrise:    {clock(rise)}")
    print(f"Sunset:     {clock(setting)}")
    if not enabled:
        print("Next:       Paused")
        return
    if now < rise:
        next_time, next_mode = rise, "Light"
    elif now < setting:
        next_time, next_mode = setting, "Dark"
    else:
        next_time = sunrise(observer, date=now.date() + timedelta(days=1), tzinfo=now.tzinfo)
        next_mode = "Light"
    minutes = max(1, math.ceil((next_time.timestamp() - now.timestamp()) / 60))
    hours, minutes = divmod(minutes, 60)
    remaining = f"{hours}h {minutes}m" if hours else f"{minutes}m"
    day = " tomorrow" if next_time.date() != now.date() else ""
    print(f"Next:       {next_mode} at {clock(next_time)}{day} (in {remaining})")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--latitude", type=float, required=True)
    parser.add_argument("--longitude", type=float, required=True)
    parser.add_argument("--timezone", required=True)
    parser.add_argument("--switch", required=True)
    parser.add_argument("--status", action="store_true")
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    now = datetime.now(ZoneInfo(args.timezone))
    observer = Observer(args.latitude, args.longitude)
    mode, event, rise, setting = solar_phase(observer, now)
    disabled = Path.home() / ".config/dotfiles/theme-auto-disabled"
    if args.status:
        show_status(observer, now, rise, setting, disabled)
        return
    print(f"Solar schedule ({args.timezone}): sunrise {rise:%H:%M}, sunset {setting:%H:%M}; "
          f"daylight mode: {mode}; automatic switching: {'off' if disabled.exists() else 'on'}")
    if disabled.exists():
        return
    state = Path.home() / ".local/state/dotfiles-theme"
    state.mkdir(parents=True, exist_ok=True)
    # Serialize timer and explicit 'theme-auto on' requests separately from theme-switch.
    with (state / "solar.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        marker = state / "solar-event"
        event_id = f"{args.latitude},{args.longitude}:{event.isoformat()}"
        if not args.force and marker.exists() and marker.read_text().strip() == event_id:
            return
        mode_file = Path.home() / ".config/dotfiles/colorScheme"
        if not mode_file.exists() or mode_file.read_text().strip() != mode:
            subprocess.run([args.switch, mode], check=True)
        # Record only successful application, so a failed switch retries next minute.
        with tempfile.NamedTemporaryFile(mode="w", dir=state, delete=False) as pending:
            pending.write(event_id + "\n")
        os.replace(pending.name, marker)


if __name__ == "__main__":
    main()
