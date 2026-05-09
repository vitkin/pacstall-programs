# Wine TkG Staging NTsync (WoW64 Binary) for Pacstall

This is a [Pacstall](https://github.com/pacstall/pacstall) recipe for installing
**Wine TkG Staging NTsync** on Ubuntu/Debian systems.

It uses the **Pure 64-bit WoW64** builds from
[Kron4ek/Wine-Builds](https://github.com/Kron4ek/Wine-Builds).

## Features

* **No Multilib Required**:

    Runs 32-bit Windows applications using the new WoW64 architecture.

    You do **not** need to enable `i386` architecture or install 32-bit
    system libraries (`libc6:i386`, etc.).

* **Latest Staging Patches**:

    Includes the latest Wine Staging patches plus TkG specific tweaks.

* **Clean Install**: Installs to `/opt/wine-tkg-staging-wow64` and symlinks
  only essential binaries to `/usr/bin`, avoiding clutter.

## Installation

1. **Install Pacstall** (if not already installed):

    ```bash
    sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
    ```

2. **Install this package**:

    Clone this repository and run:

    ```bash
    sudo pacstall -P -I wine-tkg-staging-wow64-bin.pacscript
    ```

## NTsync Requirements

To utilize the NTsync driver, you must be running a compatible kernel, such as
**[XanMod Kernel](https://xanmod.org/) 6.11+** or Linux mainline 6.14+.

You can check if your kernel supports NTsync by running:

```bash
grep CONFIG_NTSYNC /boot/config-$(uname -r)
```

If the output is `CONFIG_NTSYNC=m`, ensure the module loads at boot:

```bash
echo ntsync | sudo tee /etc/modules-load.d/ntsync.conf
```

## Maintenance & Updates

To update to a newer build version automatically:

1. Fetch latest version hash and update the pacscript

    ```bash
    ./update-package.sh
    ```

2. Re-install to apply changes

    ```bash
    sudo pacstall -I wine-tkg-staging-wow64-bin.pacscript
    ```

## Credits

* **Builds provided by**:
  [Kron4ek](https://github.com/Kron4ek/Wine-Builds)

* **Original AUR Package**:
  [wine-tkg-staging-bin](https://aur.archlinux.org/packages/wine-tkg-staging-bin)
