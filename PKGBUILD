# Maintainer: Victor "psygreg" Gregory <psygreg_at_pm_dot_me>
pkgname="wine-tkg-staging-bin"
pkgver=10.1
pkgrel=1
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
sha256sums=('5e2c914c292cb70137cdee37af0fb3accbcbe82f7c00016e1eae293905617f54')

package() {

  ## Create usr binary directory
  mkdir -p ${pkgdir}/usr

  ## Install wine package
  cp -rf ${srcdir}/wine-${pkgver}-staging-tkg-amd64/{bin,lib,share} ${pkgdir}/usr

}
