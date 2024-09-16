# Maintainer: Your Name <your.email@example.com>
pkgname=nexus-browser
pkgver=0.0.3
pkgrel=1
pkgdesc="A modern web browser built with Rust"
arch=('x86_64')
url="https://github.com/YeonSphere/Nexus"
license=('custom')
depends=('gtk3' 'webkit2gtk')
makedepends=('rust' 'cargo')
source=("$pkgname-$pkgver.tar.gz::https://github.com/YeonSphere/Nexus/archive/v$pkgver.tar.gz")
sha256sums=('SKIP')

build() {
    cd "$srcdir/Nexus-$pkgver"
    cargo build --release
}

package() {
    cd "$srcdir/Nexus-$pkgver"
    install -Dm755 target/release/nexus "$pkgdir/usr/bin/nexus-browser"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}