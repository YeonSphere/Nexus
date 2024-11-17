#!/bin/bash

set -e

echo "Building Nexus Browser..."

# Ensure required dependencies are installed
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Check for required packages
REQUIRED_PACKAGES=(
    "webkit2gtk4.0-devel"
    "gtk3-devel"
    "clang"
    "cmake"
    "ninja-build"
)

for package in "${REQUIRED_PACKAGES[@]}"; do
    if ! rpm -q "$package" &> /dev/null; then
        echo "Package $package is not installed."
        echo "Please install it using: sudo dnf install $package"
        exit 1
    fi
done

# Clean previous builds
echo "Cleaning previous builds..."
cd frontend
flutter clean
cd ..
cd linux_webview
flutter clean
cd ..
# Build Linux WebView plugin
echo "Building Linux WebView plugin..."
cd linux_webview
flutter pub get
cd ..

# Build frontend
echo "Building frontend..."
cd frontend
flutter pub get
flutter build linux --release

echo "Build completed successfully!"
echo "You can find the executable in frontend/build/linux/x64/release/bundle/"
