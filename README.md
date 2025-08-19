# Godot AdMob Plugin

A production-ready, easy-to-use AdMob integration plugin for Godot Engine that supports both iOS and Android platforms.

## Features

- ✅ **Automated Setup**: Scripts handle dependency management and configuration
- ✅ **Test Mode Ready**: Includes Google's test ad unit IDs by default
- ✅ **All Ad Types**: Banner, Interstitial, and Rewarded ads
- ✅ **Cross-Platform**: Works on both Android and iOS
- ✅ **Simple Configuration**: JSON-based configuration file
- ✅ **GDScript API**: Clean, easy-to-use singleton interface
- ✅ **Godot 4 Compatible**: Built for modern Godot versions

## Quick Start

### Installation

1. **Clone this repository:**
```bash
git clone https://github.com/TappyGames/tappy-games-admob.git
cd tappy-games-admob
```

2. **Run the automated setup:**
```bash
cd addons/godot-admob-plugin/scripts
python3 setup.py
```

The setup script will:
- Download required Godot Android libraries
- Configure Android build environment
- Set up iOS plugin integration
- Create default AdMob configuration with test IDs

3. **Copy the plugin to your Godot project:**
```bash
cp -r addons/godot-admob-plugin /path/to/your/project/addons/
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
    "test_mode": false
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

## Development Setup

### Prerequisites

**For all platforms:**
- Python 3.6+
- Godot 4.0+

**For Android:**
- Java 17+
- Gradle (optional - setup script will handle this)

**For iOS (macOS only):**
- Xcode and command line tools
- CocoaPods

### Setup Script

The automated setup script (`scripts/setup.py`) handles:

✅ **Dependency verification** - Checks for required tools  
✅ **Godot library download** - Gets the correct Android library  
✅ **Android configuration** - Sets up Gradle build environment  
✅ **iOS plugin setup** - Creates proper `.gdip` configuration  
✅ **Example project** - Generates sample code  

### Manual Build (if needed)

**Android:**
```bash
cd addons/godot-admob-plugin/android
gradle assembleRelease
```

**iOS:**
The iOS plugin integrates automatically during Godot's iOS export process.

### Headless Export

For iOS builds:
```bash
godot --headless --export-release "iOS" builds/ios/
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

The Android plugin uses:
- Google Play Services Ads SDK 23.0.0
- Minimum SDK 21
- Target SDK 34
- Automatic dependency resolution

### iOS

The iOS plugin includes:
- Google Mobile Ads SDK integration
- Required system frameworks
- Automatic Info.plist configuration
- iOS 12.0+ compatibility

## Testing

The plugin includes test ad unit IDs by default:
- Test ads work on any device
- No AdMob account required for testing
- Safe for development

## Troubleshooting

### Setup Issues

**Gradle not found:**
```bash
# Install Gradle (macOS)
brew install gradle

# Or use the setup script fallback
python3 setup.py
```

**Java version errors:**
- Ensure Java 17+ is installed
- Check `java -version`

**iOS setup fails:**
- Run setup on macOS only
- Install Xcode command line tools: `xcode-select --install`

### Runtime Issues

**Ads not showing:**
- Check internet connection
- Verify ad unit IDs in `admob_config.json`
- Check console for error messages
- Ensure `load_*` is called before `show_*`

**Plugin not found:**
- Verify plugin is in `addons/godot-admob-plugin/`
- Enable plugin in Project Settings
- Restart Godot Editor

## Project Structure

```
tappy-games-admob/
├── README.md                     # This file
├── addons/godot-admob-plugin/    # Main plugin directory
│   ├── scripts/                  # Setup automation
│   │   ├── setup.py             # Main setup script
│   │   ├── android_setup.py     # Android-specific setup
│   │   └── ios_setup.py         # iOS-specific setup
│   ├── android/                 # Android plugin files
│   ├── ios/                     # iOS plugin files
│   ├── AdMob.gd                 # Main plugin singleton
│   └── plugin.cfg               # Plugin configuration
├── demo/                        # Example implementation
└── builds/                      # Export builds
```

## Requirements

- **Godot:** 4.0 or higher
- **Android:** Min SDK 21, Target SDK 34+
- **iOS:** iOS 12.0+
- **Google Mobile Ads SDK:** Automatically managed

## License

MIT License - see LICENSE file

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the setup script to verify
5. Submit a pull request

## Support

For issues, questions, or contributions:
- Create an issue on GitHub
- Check the troubleshooting section
- Review the example code in `demo/`

## Credits

Created to provide an easy, production-ready AdMob solution for Godot developers.