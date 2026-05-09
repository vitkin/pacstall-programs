# shellcheck disable=SC2034
# shellcheck disable=SC2148

pkgname="wine-tkg-staging-wow64-bin"
pkgver="11.8"
pkgrel="1"
pkgdesc="A compatibility layer for running Windows programs (WOW64 with TkG-Staging patches)"
maintainer="Victor Itkin <635926+vitkin@users.noreply.github.com>"
arch=('amd64')
repology=("project: ${pkgname}")
url="https://github.com/Kron4ek/Wine-Builds"
license=('LGPL-2.1-or-later')

depends=(
    "libasound2t64>=1.0.16"
    "libavcodec62>=7:8.0.1"
    "libavformat62>=7:8.0.1"
    "libavutil60>=7:8.0.1"
    "libc6>=2.38"
    "libgcc-s1>=3.0"
    "libglib2.0-0t64>=2.80.0"
    "libgphoto2-6t64>=2.5.10"
    "libgphoto2-port12t64>=2.5.10"
    "libgstreamer-plugins-base1.0-0>=1.18.0"
    "libgstreamer1.0-0>=1.14.0"
    "libpcap0.8t64>=1.10.0"
    "libpcsclite1>=1.3.3"
    "libpulse0>=0.99.1"
    "libsane1>=1.0.27"
    "libudev1>=183"
    "libusb-1.0-0>=2:1.0.21"
    "libwayland-client0>=1.20.0"
    "libwayland-egl1>=1.20.0"
    "libx11-6"
    "libxext6"
    "libxkbcommon0>=1.0.0"
    "libxkbregistry0>=1.0.0"
    "ocl-icd-libopencl1 | libopencl1"
    "ocl-icd-libopencl1>=1.0 | libopencl-1.2-1"
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

conflicts=(
    "wine"
    "wine-amd64"
    "wine-i386"
    "wine-staging"
    "wine-staging-amd64"
    "wine-staging-i386"
)

replaces=(
    "wine"
    "wine-amd64"
    "wine-i386"
    "wine-staging"
    "wine-staging-amd64"
    "wine-staging-i386"
    "wine1.4"
    "wine1.4-amd64"
    "wine1.4-i386"
    "wine1.5"
    "wine1.5-amd64"
    "wine1.5-i386"
    "wine1.6"
    "wine1.6-amd64"
    "wine1.6-i386"
    "wine1.7"
    "wine1.7-amd64"
    "wine1.7-i386"
    "wine32"
    "wine64"
)

source=("https://github.com/Kron4ek/Wine-Builds/releases/download/${pkgver}/wine-${pkgver}-staging-tkg-amd64-wow64.tar.xz")

sha256sums=('d8132f9e0959efc6e1c2c72f21377347107c4fc54278eb66ff2b358b703be4ab')

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
