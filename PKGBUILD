# Maintainer: Victor "psygreg" Gregory <psygreg_at_pm_dot_me>
pkgname="wine-tkg-staging-bin"
pkgver=10.2
pkgrel=2
pkgdesc="A compatibility layer for running Windows programs (with TkG-Staging patches and multilib support)"
url="https://github.com/Kron4ek/Wine-Builds"
license=('LGPL-2.1-or-later')
arch=('x86_64')
depends=(alsa-lib fontconfig freetype2 gettext gnutls gst-plugins-base-libs libpcap libpulse libxcomposite libxcursor libxi libxinerama libxkbcommon libxrandr opencl-icd-loader pcsclite sdl2 unixodbc v4l-utils wayland desktop-file-utils libgphoto2)
provides=(
  "wine=$pkgver"
  "wine-staging=$pkgver"
)
conflicts=("wine")
source=("https://github.com/Kron4ek/Wine-Builds/releases/download/${pkgver}/wine-${pkgver}-staging-tkg-amd64.tar.xz")
sha256sums=('0a045fc8ec4ba5c2e69742cbc615fbcc91ed626a8983189e3e7b3c90ec9b34fd')

package() {

  ## Create usr binary directory
  mkdir -p ${pkgdir}/usr

  ## Install wine package
  cp -rf ${srcdir}/wine-${pkgver}-staging-tkg-amd64/{bin,lib,share} ${pkgdir}/usr

}
