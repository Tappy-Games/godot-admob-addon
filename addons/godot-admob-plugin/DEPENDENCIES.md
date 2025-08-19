# Dependency Management

This AdMob plugin automatically handles all native SDK dependencies for both iOS and Android platforms.

## ✅ What's Automated

### iOS Dependencies (via CocoaPods)
- **Google Mobile Ads SDK** (`Google-Mobile-Ads-SDK ~> 11.2.0`)
- **All transitive dependencies** (automatically resolved by CocoaPods)
- **SKAdNetwork configuration** (pre-configured in Info.plist)
- **Build settings optimization** (Bitcode disabled, deployment target set)

### Android Dependencies (via Gradle)
- **Google Play Services Ads** (`com.google.android.gms:play-services-ads:23.0.0`)
- **All transitive dependencies** (automatically resolved by Gradle)
- **Manifest permissions** (Internet, Network State)
- **ProGuard rules** (if needed for release builds)

## 🔧 Setup Commands

### Quick Setup (All Platforms)
```bash
cd addons/godot-admob-plugin/scripts
python3 setup.py
```

### Platform-Specific Setup

#### iOS Only (requires macOS)
```bash
python3 ios_setup.py
```
This will:
1. ✅ Check for Xcode command line tools
2. ✅ Install CocoaPods if needed
3. ✅ Configure Podfile with Google Mobile Ads SDK
4. ✅ Run `pod install` to download dependencies
5. ✅ Create Xcode workspace ready for building

#### Android Only
```bash
python3 android_setup.py
```
This will:
1. ✅ Check for Java 17+
2. ✅ Setup Gradle wrapper
3. ✅ Download Godot Android library
4. ✅ Build plugin with Google Play Services Ads included
5. ✅ Generate ready-to-use AAR file

## 📦 What Gets Installed

### iOS Native Dependencies
When you run iOS setup, CocoaPods installs:
- Google Mobile Ads SDK (main framework)
- GoogleAppMeasurement (analytics)
- GoogleUtilities (utilities)
- nanopb (protocol buffers)
- PromisesObjC (async operations)

### Android Native Dependencies  
When you run Android setup, Gradle includes:
- Google Play Services Ads (main library)
- Google Play Services Base 
- Google Play Services Basement
- AndroidX Support Libraries
- Kotlin Standard Library

## 🚀 Production Readiness

### Test Mode (Default)
```json
{
  "test_mode": true,
  "app_id_android": "ca-app-pub-3940256099942544~3347511713",
  "app_id_ios": "ca-app-pub-3940256099942544~1458002511"
}
```
- Shows **real Google test ads**
- No revenue generated (safe for testing)
- Works without AdMob account
- Identical behavior to production ads

### Production Mode
```json
{
  "test_mode": false,
  "app_id_android": "ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID",
  "app_id_ios": "ca-app-pub-YOUR_PUBLISHER_ID~YOUR_APP_ID"
}
```
- Shows **real advertiser ads**
- Generates **actual revenue**
- Requires **approved AdMob account**
- Same code, different configuration

## 🔄 Version Management

The plugin uses specific, tested versions:
- **iOS**: Google Mobile Ads SDK 11.2.0
- **Android**: Play Services Ads 23.0.0
- **Godot**: Compatible with 4.2+ 

To update versions, edit:
- `ios/Podfile` for iOS SDK version
- `android/build.gradle` for Android dependencies

## 🎯 Unity Parity

This plugin matches Unity's AdMob experience:
- ✅ Real test ads in editor/simulator
- ✅ Same test ad unit IDs as Unity
- ✅ Automatic dependency resolution
- ✅ One-click setup process
- ✅ Production-ready builds

## 🛠️ Manual Alternative

If you prefer manual setup:

### iOS Manual Steps:
1. Open Terminal in `ios/` directory
2. Run `pod install`
3. Open `.xcworkspace` in Xcode
4. Build for your target device

### Android Manual Steps:
1. Open Terminal in `android/` directory  
2. Run `./gradlew assembleRelease`
3. Find AAR in `build/outputs/aar/`
4. Copy to your Godot project

The automated scripts do exactly these steps plus dependency verification and error handling.