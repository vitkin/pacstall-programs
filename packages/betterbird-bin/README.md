# Betterbird for Pacstall

![Betterbird](betterbird.svg)

This is a [Pacstall](https://github.com/pacstall/pacstall) recipe for installing
**Betterbird** on Ubuntu and Debian systems.

**Betterbird** is a fine-tuned version of Mozilla Thunderbird with enhanced
features and optimizations to provide a superior email and messaging experience.

## Features

* **Enhanced Email Client**: Betterbird improves upon Thunderbird with
  additional features and optimizations

* **Easy Installation**: Installs on Debian and Ubuntu systems through Pacstall

* **Clean Integration**: Integrates seamlessly with your desktop environment

* **Desktop Entry**: Full desktop integration with icon and application menu
  support

* **Lightweight Setup**: Installs without requiring additional system
  dependencies beyond essential libraries

## Installation

### Debian/Ubuntu (Pacstall)

1. **Install Pacstall** (if not already installed):

   ```bash
   sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
   ```

2. **Install Betterbird**:

   Clone this repository and run:

   ```bash
   sudo pacstall -P -I betterbird-bin.pacscript
   ```

## Usage

After installation, you can launch Betterbird by:

```bash
betterbird
```

Or find it in your application menu under **Network** > **Email**.

## System Requirements

* **Architecture**: x86_64

* **Libraries**: libdbus-glib-1-2, hunspell

* **Desktop Integration**: xdg-desktop-portal (for system integration)

## Building from Source

To build the package locally with makedeb-compatible tooling:

```bash
bash build.sh
```

To clean build artifacts:

```bash
bash clean.sh
```

## Version Source

This package tracks Betterbird releases from the official downloads page:

* https://www.betterbird.eu/downloads/

Version updates are based on the **English (US) Linux Archive** release
published there.

## Official Links

* **Betterbird Website**: https://www.betterbird.eu/

* **Betterbird Downloads**: https://www.betterbird.eu/downloads/

* **Mozilla Thunderbird**: https://www.thunderbird.net/

## Maintainers

* **Pacstall Recipe**: tranquil <tranquiltr0@proton.me>

> [!NOTE]
> The repository still includes makedeb-related files such as `PKGBUILD` because
> the package was originally based on makedeb. The intended target for this
> project is Pacstall.
