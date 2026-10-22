# Desktop host

This host contains hardware and storage settings for one existing machine.
Use its module structure as an example; generate hardware settings for another
machine and review its drivers, boot configuration, locale, accounts, and storage.

## Storage and accounts

`storage.nix` mounts the existing Windows volumes by UUID and assigns ownership
through UID `1000` and GID `100`. Preserve those values on this machine unless an
account or storage migration explicitly changes ownership. A second account needs
its own access policy.

## Virtual machines

Libvirt configuration and mutable VM state live outside this repository. Back up
domain definitions together with their virtual disks, UEFI variables, and vTPM
state; inspect the definitions for the actual storage paths. Moving Nix modules
does not migrate that state or register an existing Windows installation as a VM.

## Compatibility notes

- [Ghostty](../../modules/home/apps/ghostty.nix) uses epoll after a local io_uring
  wait-accounting issue. Check the original symptom before changing that setting.
- [Plasma's Walker integration](../../modules/home/desktop/plasma.nix) keeps the
  cached command entry linked to its managed desktop entry, preventing a stale
  launcher path after a Home Manager switch.

These fixes remain in their owning modules. Host notes record why they matter on
this machine; shared setup and maintenance steps live in
[the maintenance guide](../../docs/maintenance.md).
