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

prepare() {
    cd "$srcdir/Nexus-$pkgver"
    npm install
}

build() {
    cd "$srcdir/Nexus-$pkgver"
    npm run build
}

package() {
    cd "$srcdir/Nexus-$pkgver"
    install -dm755 "$pkgdir/usr/lib/$pkgname"
    cp -r dist package.json "$pkgdir/usr/lib/$pkgname"
    
    # Create launcher script
    install -Dm755 /dev/null "$pkgdir/usr/bin/$pkgname"
    cat << EOF > "$pkgdir/usr/bin/$pkgname"
#!/bin/sh
exec electron /usr/lib/$pkgname
EOF
    
    # Install license
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
    
    # Install desktop file and icon if available
    if [ -f "assets/icon.png" ]; then
        install -Dm644 assets/icon.png "$pkgdir/usr/share/icons/hicolor/256x256/apps/$pkgname.png"
    fi
    if [ -f "$pkgname.desktop" ]; then
        install -Dm644 "$pkgname.desktop" "$pkgdir/usr/share/applications/$pkgname.desktop"
    fi
}