# Maintainer: Dae Sanghwi (@daedaevibin) <daedaevibin@naver.com>
pkgname=nexus-browser
pkgver=0.0.3
pkgrel=1
pkgdesc="A modern web browser built with Electron and TypeScript"
arch=('x86_64')
url="https://github.com/YeonSphere/Nexus"
license=('MIT')
depends=('electron')
makedepends=('nodejs' 'npm' 'typescript')
source=("$pkgname-$pkgver.tar.gz::https://github.com/YeonSphere/Nexus/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cd "$srcdir/Nexus-$pkgver"
    npm install
    npm run build
}

package() {
    cd "$srcdir/Nexus-$pkgver"
    install -dm755 "$pkgdir/usr/lib/$pkgname"
    cp -r dist package.json "$pkgdir/usr/lib/$pkgname"
    install -Dm755 /dev/null "$pkgdir/usr/bin/$pkgname"
    echo '#!/bin/sh' > "$pkgdir/usr/bin/$pkgname"
    echo "electron /usr/lib/$pkgname" >> "$pkgdir/usr/bin/$pkgname"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}