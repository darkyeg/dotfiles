# Repository working rules

## Read the owner before editing

- For user, profile, host, or fork changes, read [docs/configuration.md](docs/configuration.md).
- For bootstrap, updates, activation, or runtime state, read
  [docs/maintenance.md](docs/maintenance.md).
- Use [README.md](README.md) to find the owning file. Inspect its imports and an
  existing module of the same kind before changing it.
- Inspect the working tree first; preserve unrelated changes. A refactor keeps
  behavior unless the task explicitly requests a behavior change.

## Keep composition simple

- Keep account identity in `users/<user>/identity.nix`, preferences in that user's
  home module, and account permissions in their NixOS module. Shared service
  modules enable services; they do not grant access to a named user.
- Keep the loader and shared builders independent of any user's identity or home
  file. A home target selects its user module; derive user-named targets from that
  home's username. The user module explicitly imports its chosen identity.
- Bootstrap may read the invoking account's username and home directory. Personal
  Git identity must come from an explicitly selected user module, never a lookup
  based on environment variables or directory names.
- Compose a profile and user through ordinary Nix imports. Shared modules must
  work for another user without copying personal identity, signing keys, location,
  or privileges. Derive paths from Home Manager's configuration or shell environment.
- Keep disk IDs, mount ownership, GPU choices, and host locale with the machine.
  Preserve existing UIDs, state versions, and storage behavior during refactors.
- Give each setting and package one owner. Profiles select modules; app modules
  own app behavior; scripts own command logic. Reuse the base profile for common
  packages rather than repeating lists.
- Shared modules may import other shared modules, but never a user's module or a
  profile. Keep host/profile selection explicit in `configurations/` and keep
  `flake.nix` a grouped dependency manifest. Nix requires its inputs to be static.
- Extract helpers for repeated behavior, not to hide a few readable imports.
  Keep the shared loader in `configurations.nix` small; add target files rather
  than branches for particular hosts or users.
- Automatic loading is limited to top-level `.nix` files in `configurations/nixos/`,
  `configurations/home/`, and `packages/`. These expose outputs; profiles and hosts
  still select installed modules explicitly. Duplicate output names must fail.
- Put custom package recipes and upstream package patches in `packages/` and use
  `pkgs.callPackage` at their consumer. Use an overlay only when consumers need
  the same replacement through `pkgs`; do not patch packages inside service setup.
- Use `pkgs.<name>` for packages already in nixpkgs. Add an external flake input
  when its modules or packages are actually needed, rather than one input per app.
- Use normal overrides for per-user preferences. Reserve `lib.mkForce` for a
  documented conflict; fix duplicate ownership instead of hiding it with `lib.unique`.
- Add only requested capabilities. Future desktops and profiles are extension
  points, not a reason to install them or build a configuration framework now.
- Preserve documented commands and flake targets. A new public option, CLI flag,
  or configuration schema needs a realistic usage example and owner approval
  unless that interface was already authorized in the task.
- Keep compatibility fixes with the module or package that owns the failure.
  Reproduce the failure, record a short reason, and verify the relevant upstream
  condition before adding, replacing, or removing a workaround.

## Updates must preserve ownership and state

- Keep `flake.lock` unchanged for structural work. For requested version updates,
  refresh only the intended inputs; review the lock diff and package changes.
- Check platform scope before extending setup. The current bootstrap targets
  installed NixOS desktops; a future laptop gets its own hardware and host imports.
  Architecture that permits another platform does not establish working support.
- Nix owns regular apps and CLI runtimes/launchers. `scripts/dev-setup` owns the
  supported native developer-tool installers and updates. Preserve their existing
  data locations and authentication; avoid adding a second installation owner.
- Setup skips working tools; updates skip absent tools. Validate arguments before
  side effects, return failures accurately, and continue independent update stages.
- Keep home and system target selections independent. Save a selection only after
  successful activation; previews and failures preserve the previous selection.
- Evaluation, builds, and previews must never invoke native installers or update
  commands. Keep credentials and mutable application state outside the repository.
- Implement persistent fixes in source. Treat manual edits to generated home
  files as temporary diagnostics, then restore managed ownership.
- Build and inspect before activation. Apply live configurations only within the
  user's authorization. Reboots, closing terminals, hardware changes, and writes
  to VM disks, vTPM, or UEFI state are not incidental cleanup.

## Verify the change you actually made

- For Nix changes, run
  `nix flake check --impure --no-build --no-write-lock-file`, then build the affected
  home activation package or NixOS toplevel without activating it. Run one heavy
  build at a time. For documentation-only edits, check links and command examples.
- For structural changes, compare evaluated package sets, managed file targets,
  accounts, filesystems, and state versions against a saved baseline. Explain any
  change beyond generated configuration artifacts. Exercise a second user/profile
  when changing composition.
- For shell changes, check syntax and exercise failures, previews, argument
  forwarding, and saved state using isolated homes and fake commands. Keep
  temporary validation fixtures outside the repository; remove task-only tests
  after verification when requested.
- Check commands and module options against the installed CLI or pinned input
  sources. Report unavailable checks rather than weakening configuration to pass.
- Review the final diff and run `git diff --check`. Update the relevant docs when
  behavior or file ownership changes; report paths, passed checks, and limitations.
- Commit only when requested. New files may need `git add -N` for Git-backed
  flakes to see them; that does not authorize a commit.
