# Limitations

## Package Availability

### APT (Debian/Ubuntu)

This cookbook manages the traditional `/etc/network/interfaces` file format used by `ifupdown`.

* Debian 12: `ifupdown` is available in the Debian package archive.
* Debian 13: `ifupdown` is available in the Debian stable package archive.
* Ubuntu 22.04: `ifupdown` is available in the Ubuntu archive.
* Ubuntu 24.04: `ifupdown` is available in the Ubuntu archive.

### DNF/YUM (RHEL family)

Not applicable. This cookbook only manages Debian-style `/etc/network/interfaces` configuration.

### Zypper (SUSE)

Not applicable. This cookbook only manages Debian-style `/etc/network/interfaces` configuration.

## Architecture Limitations

The cookbook renders text configuration and does not install architecture-specific upstream binaries.

## Source/Compiled Installation

No source build is used.

## Known Issues

* Ubuntu defaults to Netplan on modern releases. This cookbook is intended for hosts that intentionally use `ifupdown`.
* Debian 9, Debian 10, Debian 11, and Ubuntu 18.04 were removed from active support because they are outside current standard support for this migration baseline.
