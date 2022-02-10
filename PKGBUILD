# Maintainer: Giovanni Ivan Alberotanza <ivan81@disroot.org>

pkgname=betterbird-bin
_pkgname=betterbird
pkgdesc="Betterbird is a fine-tuned version of Mozilla Thunderbird, Thunderbird on steroids, if you will."
pkgrel=1
pkgver=91.6.0
arch=('x86_64')
url="https://www.betterbird.eu/index.html"
license=('MPL2')
provides=('betterbird')
conflicts=('betterbird')

source=(
        # https://www.betterbird.eu/downloads/get.php?os=linux&lang=en-US&version=release
        "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-91.6.0-bb26.en-US.linux-x86_64.tar.bz2"
        "betterbird.desktop"
        "betterbird.svg"
      )
sha256sums=('2bd772aa07101abe5bd67185c7ece6070f8c1ecced877e8c188ebc411df1391d'
            '524ac695701d59f7442fe7b1aac4ccbb9f45397f8c9bb1af2582c4aba9cf3255'
            'f9c696b4a4f8bb57f2caa8b2801c4f9b4e493c1c29b2fdf2945d5805364bc843')

package() {
    cd "$srcdir"
    mkdir -p "$pkgdir/usr/bin"
    install -d -m755 "$pkgdir/usr/lib/$pkgname"
    install -Dm644 "$_pkgname.desktop" -t "$pkgdir/usr/share/applications"
    cp -r ./betterbird/* "$pkgdir/usr/lib/$pkgname"
    ln -rs "$pkgdir/usr/lib/$pkgname/betterbird" "$pkgdir/usr/bin/betterbird"
    install -D -m644 betterbird.svg "$pkgdir"/usr/share/icons/hicolor/scalable/apps/$_pkgname.svg
}
