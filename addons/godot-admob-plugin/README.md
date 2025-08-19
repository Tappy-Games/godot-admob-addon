# Godot AdMob Plugin

A production-ready, easy-to-use AdMob integration plugin for Godot Engine that supports both iOS and Android platforms.

## Features

- ✅ **Plug and Play**: Minimal setup required - just copy, enable, and configure
- ✅ **Test Mode Ready**: Includes Google's test ad unit IDs by default
- ✅ **All Ad Types**: Banner, Interstitial, and Rewarded ads
- ✅ **Cross-Platform**: Works on both Android and iOS
- ✅ **Simple Configuration**: JSON-based configuration file
- ✅ **Automated Build**: Scripts to automate SDK setup
- ✅ **GDScript API**: Clean, easy-to-use singleton interface

## Quick Start

### Installation

1. **Clone or download this plugin:**
```bash
git clone https://github.com/yourusername/godot-admob-plugin.git
```

2. **Run the automated setup:**
```bash
cd godot-admob-plugin/scripts
python3 setup.py
```

3. **Copy to your Godot project:**
```bash
cp -r godot-admob-plugin /path/to/your/project/addons/
```

4. **Enable in Godot:**
   - Open your project in Godot
   - Go to Project Settings > Plugins
   - Enable "Godot AdMob Plugin"

### Configuration

The plugin uses test ad IDs by default. To use your own AdMob IDs:

1. Edit `addons/godot-admob-plugin/admob_config.json`
2. Replace the test IDs with your actual AdMob unit IDs:

```json
{
    "app_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX",
    "app_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX",
    "banner_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "banner_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "interstitial_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "interstitial_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "rewarded_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "rewarded_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
    "test_mode": false,
    "child_directed": false,
    "max_ad_content_rating": "G",
    "test_device_ids": []
}
```

## Usage

The plugin provides a global `AdMob` singleton that's automatically available in all your scripts.

### Banner Ads

```gdscript
func _ready():
    # Connect signals
    AdMob.banner_loaded.connect(_on_banner_loaded)
    AdMob.banner_failed_to_load.connect(_on_banner_failed)
    
    # Load banner
    AdMob.load_banner(
        AdMob.BannerSize.ADAPTIVE_BANNER,
        AdMob.BannerPosition.BOTTOM
    )

func _on_banner_loaded():
    AdMob.show_banner()

func _on_banner_failed(error_code):
    print("Banner failed: ", error_code)
```

### Interstitial Ads

```gdscript
func show_interstitial():
    AdMob.interstitial_closed.connect(_on_interstitial_closed)
    AdMob.load_interstitial()

func _on_interstitial_loaded():
    AdMob.show_interstitial()

func _on_interstitial_closed():
    print("User closed interstitial")
```

### Rewarded Ads

```gdscript
func show_rewarded_ad():
    AdMob.rewarded_user_earned_reward.connect(_on_reward_earned)
    AdMob.load_rewarded_ad()

func _on_rewarded_ad_loaded():
    AdMob.show_rewarded_ad()

func _on_reward_earned(currency, amount):
    print("User earned: ", amount, " ", currency)
    # Grant the reward to the player
```

## API Reference

### Enums

```gdscript
enum BannerPosition {
    TOP = 0,
    BOTTOM = 1,
    TOP_LEFT = 2,
    TOP_RIGHT = 3,
    BOTTOM_LEFT = 4,
    BOTTOM_RIGHT = 5,
    CENTER = 6
}

enum BannerSize {
    ADAPTIVE_BANNER = 0,  # Recommended
    SMART_BANNER = 1,
    BANNER = 2,
    MEDIUM_RECTANGLE = 3,
    FULL_BANNER = 4,
    LEADERBOARD = 5
}
```

### Methods

- `load_banner(size: BannerSize, position: BannerPosition)` - Load a banner ad
- `show_banner()` - Show the loaded banner
- `hide_banner()` - Hide the banner (keeps it loaded)
- `destroy_banner()` - Remove the banner completely
- `load_interstitial()` - Load an interstitial ad
- `show_interstitial()` - Show the loaded interstitial
- `load_rewarded_ad()` - Load a rewarded ad
- `show_rewarded_ad()` - Show the loaded rewarded ad

### Signals

**Banner:**
- `banner_loaded()`
- `banner_failed_to_load(error_code: int)`
- `banner_opened()`
- `banner_closed()`
- `banner_clicked()`

**Interstitial:**
- `interstitial_loaded()`
- `interstitial_failed_to_load(error_code: int)`
- `interstitial_opened()`
- `interstitial_closed()`

**Rewarded:**
- `rewarded_ad_loaded()`
- `rewarded_ad_failed_to_load(error_code: int)`
- `rewarded_ad_opened()`
- `rewarded_ad_closed()`
- `rewarded_user_earned_reward(currency: String, amount: int)`

## Platform-Specific Setup

### Android

The Android plugin is automatically configured when you enable the plugin. Make sure you have:

1. Android build template installed in your project
2. Minimum SDK version 21 or higher
3. Target SDK version 33 or higher

### iOS

For iOS, after enabling the plugin:

1. Export your project for iOS
2. Open the Xcode project
3. The plugin files are automatically included
4. Build and run

The plugin handles all Info.plist configurations automatically, including:
- GADApplicationIdentifier
- SKAdNetworkItems (for iOS 14+ App Tracking)

## Building from Source

If you need to modify the plugin:

### Android
```bash
cd android
./gradlew assembleRelease
```

### iOS
```bash
cd ios
pod install
# Then build in Xcode
```

## Testing

The plugin includes test ad unit IDs by default. These will always show test ads:

- Test ads work on any device
- No AdMob account required for testing
- Safe for development and testing

To test with real ads (be careful not to click your own ads):
1. Set `test_mode: false` in config
2. Add your test device IDs to `test_device_ids` array

## Troubleshooting

### Ads not showing
- Check your internet connection
- Verify ad unit IDs are correct
- Check logcat/console for error messages
- Ensure you've called `load_*` before `show_*`

### Build errors
- Android: Ensure you have JDK 17+ installed
- iOS: Ensure you have Xcode and CocoaPods installed
- Run `setup.py` to verify all dependencies

### Plugin not found
- Make sure the plugin is in `addons/godot-admob-plugin/`
- Enable the plugin in Project Settings
- Restart Godot Editor after enabling

## Requirements

- Godot 4.0 or higher
- Android: Min SDK 21, Target SDK 33+
- iOS: iOS 12.0+
- Google Mobile Ads SDK (automatically handled)

## License

MIT License - see LICENSE file

## Support

For issues, questions, or contributions, please visit:
https://github.com/yourusername/godot-admob-plugin

## Credits

Created to provide an easy, production-ready AdMob solution for Godot developers.