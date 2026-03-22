# shellcheck disable=SC2034
# shellcheck disable=SC2148

pkgname="wine-tkg-staging-wow64-bin"
pkgver="11.5"
pkgrel="1"
pkgdesc="A compatibility layer for running Windows programs (WOW64 with TkG-Staging patches)"
maintainer="Victor Itkin <635926+vitkin@users.noreply.github.com>"
arch=('amd64')
repology=("project: ${pkgname}")
url="https://github.com/Kron4ek/Wine-Builds"
license=('LGPL-2.1-or-later')

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
    "ocl-icd-libopencl1 | libopencl-1.2-1"
    "libasound2-plugins"
    "libncurses6 | libncurses5 | libncurses"
)

recommends=(
    "libcairo2"
    "libcap2-bin"
    "libcups2"
    "libdbus-1-3"
    "libfontconfig1"
    "libfreetype6"
    "libglu1-mesa | libglu1"
    "libgnutls30 | libgnutls-deb0-28 | libgnutls26"
    "libgssapi-krb5-2"
    "libgtk-3-0"
    "libkrb5-3"
    "libodbc2 | libodbc1"
    "libpcap0.8"
    "libsdl2-2.0-0"
    "libv4l-0"
    "libva-drm2 | libva-drm1"
    "libva-x11-2 | libva-x11-1"
    "libva2 | libva1"
    "libxcomposite1"
    "libxcursor1"
    "libxfixes3"
    "libxi6"
    "libxinerama1"
    "libxrandr2"
    "libxrender1"
    "libxxf86vm1"
)

provides=(
    "wine=${pkgver}"
    "wine-staging=${pkgver}"
    "wine-wow64=${pkgver}"
)

conflicts=("wine")

source=("https://github.com/Kron4ek/Wine-Builds/releases/download/${pkgver}/wine-${pkgver}-staging-tkg-amd64-wow64.tar.xz")

sha256sums=('10a175c30cc179dd94b7b66cefaf8f3cba9a4a8f7038a3efce46fd9b0e31afe1')

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
