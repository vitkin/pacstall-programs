# shellcheck disable=SC2034
# shellcheck disable=SC2148

pkgname="wine-tkg-staging-wow64-bin"
pkgver="11.1"
pkgrel="1"
pkgdesc="A compatibility layer for running Windows programs (TkG-Staging patches, pure 64-bit WoW64 mode)"
maintainer="Victor Itkin <635926+vitkin@users.noreply.github.com>"
arch="amd64"
url="https://github.com/Kron4ek/Wine-Builds"
license=('LGPL-2.1-or-later')
provides=("wine" "wine-staging")
conflicts=("wine" "wine-staging")
source=("https://github.com/Kron4ek/Wine-Builds/releases/download/${pkgver}/wine-${pkgver}-staging-tkg-amd64-wow64.tar.xz")
sha256sums=('fc467ae6879b97612263abfdbe034a0e6344f95bd9a3668c3f0b1f0e7f9537f1')

depends=(
    "libasound2t64"
    "libavcodec60"
    "libavformat60"
    "libavutil58"
    "libc6"
    "libglib2.0-0t64"
    "libgphoto2-6t64"
    "libgphoto2-port12t64"
    "libgstreamer-plugins-base1.0-0"
    "libgstreamer1.0-0"
    "libpcap0.8t64"
    "libpcsclite1"
    "libpulse0"
    "libsane1"
    "libudev1"
    "libunwind8"
    "libusb-1.0-0"
    "libwayland-client0"
    "libwayland-egl1"
    "libx11-6"
    "libxext6"
    "libxkbcommon0"
    "libxkbregistry0"
    "ocl-icd-libopencl1"
    "libasound2-plugins"
    "libncurses6"
    "desktop-file-utils"
)

recommends=(
    "libcairo2"
    "libcap2-bin"
    "libcups2"
    "libdbus-1-3"
    "libfontconfig1"
    "libfreetype6"
    "libglu1-mesa"
    "libgnutls30t64"
    "libgssapi-krb5-2"
    "libgtk-3-0t64"
    "libkrb5-3"
    "libodbc2"
    "libsdl2-2.0-0"
    "libv4l-0t64"
    "libva-drm2"
    "libva-x11-2"
    "libva2"
    "libxcomposite1"
    "libxcursor1"
    "libxfixes3"
    "libxi6"
    "libxinerama1"
    "libxrandr2"
    "libxrender1"
    "libxxf86vm1"
    "libvulkan1"
)

package() {
    local _install_path="/opt/wine-tkg-staging-wow64"
    
    # shellcheck disable=SC2164
    cd "wine-${pkgver}-staging-tkg-amd64-wow64"
    # shellcheck disable=SC2154
    mkdir -p "${pkgdir}${_install_path}"
    cp -rf ./* "${pkgdir}${_install_path}/"

    # Create system-wide symlinks
    mkdir -p "${pkgdir}/usr/bin"
    for binary in "${pkgdir}${_install_path}/bin/"*; do
        local bin_name
        bin_name="$(basename "$binary")"
        
        # Filter out non-binary files or internal scripts not meant for global PATH
        # Also excluding development tools (widl, winegcc, wmc, etc.) to keep /usr/bin clean
        case "$bin_name" in
            *.pl|widl|winebuild|winecpp|winedump|wineg++|winegcc|winemaker|wmc|wrc|msidb)
                continue
                ;;
        esac

        ln -s "${_install_path}/bin/${bin_name}" "${pkgdir}/usr/bin/${bin_name}"
    done
}

# vim: set filetype=bash tabstop=4 foldmethod=marker expandtab:
