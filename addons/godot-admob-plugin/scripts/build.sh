#!/bin/bash

set -e

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$PLUGIN_DIR/android"
IOS_DIR="$PLUGIN_DIR/ios"

echo "Building Godot AdMob Plugin..."

# Build Android plugin
echo "Building Android plugin..."
cd "$ANDROID_DIR"

# Download Godot AAR if not present
if [ ! -f "libs/godot-lib.release.aar" ]; then
    echo "Downloading Godot Android library..."
    mkdir -p libs
    wget -O libs/godot-lib.release.aar \
        "https://github.com/godotengine/godot/releases/download/4.2-stable/godot-lib.4.2.stable.release.aar"
fi

# Build AAR
./gradlew assembleRelease

# Copy AAR to plugin directory
cp build/outputs/aar/*.aar "$ANDROID_DIR/godot-admob-plugin.aar"

echo "Android plugin built successfully!"

# Build iOS plugin
echo "Building iOS plugin..."
cd "$IOS_DIR"

# Install pods
if command -v pod &> /dev/null; then
    pod install
else
    echo "CocoaPods not installed. Please install CocoaPods to build iOS plugin."
    echo "Run: sudo gem install cocoapods"
fi

echo "iOS plugin prepared. Manual build required in Xcode."

echo "Build complete!"
echo ""
echo "Installation instructions:"
echo "1. Copy the 'godot-admob-plugin' folder to your project's 'addons' directory"
echo "2. Enable the plugin in Project Settings > Plugins"
echo "3. Configure your AdMob IDs in 'admob_config.json'"
echo "4. For Android: The plugin will be automatically included"
echo "5. For iOS: Add the iOS framework to your Xcode project"