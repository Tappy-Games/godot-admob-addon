#!/usr/bin/env python3

import os
import sys
import json
import subprocess
import platform
from pathlib import Path

class AdMobPluginSetup:
    def __init__(self):
        self.plugin_dir = Path(__file__).parent.parent
        self.android_dir = self.plugin_dir / "android"
        self.ios_dir = self.plugin_dir / "ios"
        
    def check_requirements(self):
        """Check if required tools are installed"""
        print("Checking requirements...")
        
        issues = []
        
        # Check for Java
        try:
            subprocess.run(["java", "-version"], capture_output=True, check=True)
            print("✓ Java installed")
        except:
            issues.append("Java is not installed. Please install JDK 17 or higher.")
        
        # Check for Gradle (for Android)
        try:
            subprocess.run(["gradle", "-version"], capture_output=True, check=True)
            print("✓ Gradle installed")
        except:
            print("⚠ Gradle not found in PATH (will use wrapper)")
        
        # Check for CocoaPods (for iOS)
        if platform.system() == "Darwin":
            try:
                subprocess.run(["pod", "--version"], capture_output=True, check=True)
                print("✓ CocoaPods installed")
            except:
                issues.append("CocoaPods is not installed. Run: sudo gem install cocoapods")
        
        if issues:
            print("\n⚠ Issues found:")
            for issue in issues:
                print(f"  - {issue}")
            return False
        
        return True
    
    def download_godot_lib(self):
        """Download Godot Android library"""
        libs_dir = self.android_dir / "libs"
        libs_dir.mkdir(exist_ok=True)
        
        godot_lib = libs_dir / "godot-lib.release.aar"
        if not godot_lib.exists():
            print("Downloading Godot Android library...")
            import urllib.request
            url = "https://github.com/godotengine/godot/releases/download/4.2-stable/godot-lib.4.2.stable.release.aar"
            urllib.request.urlretrieve(url, godot_lib)
            print("✓ Godot Android library downloaded")
        else:
            print("✓ Godot Android library already present")
    
    def setup_gradle_wrapper(self):
        """Setup Gradle wrapper for Android"""
        gradle_wrapper = self.android_dir / "gradlew"
        if not gradle_wrapper.exists():
            print("Setting up Gradle wrapper...")
            os.chdir(self.android_dir)
            subprocess.run(["gradle", "wrapper"], check=True)
            print("✓ Gradle wrapper created")
    
    def configure_admob_ids(self):
        """Interactive configuration of AdMob IDs"""
        config_file = self.plugin_dir / "admob_config.json"
        
        print("\n=== AdMob Configuration ===")
        print("Press Enter to keep test IDs, or enter your actual AdMob IDs:")
        
        with open(config_file, 'r') as f:
            config = json.load(f)
        
        fields = [
            ("app_id_android", "Android App ID"),
            ("app_id_ios", "iOS App ID"),
            ("banner_id_android", "Android Banner ID"),
            ("banner_id_ios", "iOS Banner ID"),
            ("interstitial_id_android", "Android Interstitial ID"),
            ("interstitial_id_ios", "iOS Interstitial ID"),
            ("rewarded_id_android", "Android Rewarded ID"),
            ("rewarded_id_ios", "iOS Rewarded ID"),
        ]
        
        modified = False
        for key, label in fields:
            current = config.get(key, "")
            new_value = input(f"{label} [{current[:20]}...]: ").strip()
            if new_value:
                config[key] = new_value
                modified = True
        
        test_mode = input("Enable test mode? (y/n) [y]: ").strip().lower()
        config["test_mode"] = test_mode != 'n'
        
        if modified or test_mode != 'y':
            with open(config_file, 'w') as f:
                json.dump(config, f, indent=4)
            print("✓ Configuration saved")
        else:
            print("✓ Using test configuration")
    
    def build_android(self):
        """Build Android plugin"""
        print("\n=== Building Android Plugin ===")
        
        os.chdir(self.android_dir)
        
        # Use gradlew if available, otherwise gradle
        gradle_cmd = "./gradlew" if (self.android_dir / "gradlew").exists() else "gradle"
        
        print("Running Gradle build...")
        result = subprocess.run([gradle_cmd, "assembleRelease"], capture_output=True, text=True)
        
        if result.returncode == 0:
            # Copy AAR to plugin directory
            import shutil
            import glob
            aar_files = glob.glob(str(self.android_dir / "build/outputs/aar/*.aar"))
            if aar_files:
                shutil.copy(aar_files[0], self.android_dir / "godot-admob-plugin.aar")
                print("✓ Android plugin built successfully")
            else:
                print("⚠ Build succeeded but AAR not found")
        else:
            print("✗ Android build failed:")
            print(result.stderr)
            return False
        
        return True
    
    def setup_ios(self):
        """Setup iOS plugin using dedicated script"""
        if platform.system() != "Darwin":
            print("\n⚠ iOS setup skipped (not on macOS)")
            return True
        
        print("\n=== Setting up iOS Plugin ===")
        
        # Run dedicated iOS setup script
        ios_script = self.plugin_dir / "scripts" / "ios_setup.py"
        result = subprocess.run([sys.executable, str(ios_script)], capture_output=True, text=True)
        
        if result.returncode == 0:
            print(result.stdout)
            return True
        else:
            print("iOS setup failed:")
            print(result.stderr)
            return False
    
    def create_example_project(self):
        """Create example Godot project files"""
        example_dir = self.plugin_dir / "example"
        example_dir.mkdir(exist_ok=True)
        
        # Create example scene
        with open(example_dir / "AdMobExample.gd", 'w') as f:
            f.write('''extends Node

func _ready():
    # Connect to AdMob signals
    AdMob.banner_loaded.connect(_on_banner_loaded)
    AdMob.banner_failed_to_load.connect(_on_banner_failed_to_load)
    AdMob.interstitial_loaded.connect(_on_interstitial_loaded)
    AdMob.interstitial_closed.connect(_on_interstitial_closed)
    AdMob.rewarded_user_earned_reward.connect(_on_rewarded_earned)
    
    # Load and show banner
    AdMob.load_banner(AdMob.BannerSize.ADAPTIVE_BANNER, AdMob.BannerPosition.BOTTOM)

func _on_banner_loaded():
    print("Banner loaded!")
    AdMob.show_banner()

func _on_banner_failed_to_load(error_code):
    print("Banner failed to load: ", error_code)

func load_interstitial():
    AdMob.load_interstitial()

func _on_interstitial_loaded():
    print("Interstitial loaded!")
    AdMob.show_interstitial()

func _on_interstitial_closed():
    print("Interstitial closed")

func load_rewarded():
    AdMob.load_rewarded_ad()

func _on_rewarded_earned(currency, amount):
    print("Reward earned: ", amount, " ", currency)
''')
        
        print("✓ Example project created")
    
    def run(self):
        """Run the complete setup process"""
        print("=== Godot AdMob Plugin Setup ===\n")
        
        if not self.check_requirements():
            print("\n✗ Please install missing requirements and run again.")
            return 1
        
        self.download_godot_lib()
        self.setup_gradle_wrapper()
        self.configure_admob_ids()
        
        # Run dedicated Android setup script
        android_script = self.plugin_dir / "scripts" / "android_setup.py"
        result = subprocess.run([sys.executable, str(android_script)], capture_output=True, text=True)
        
        if result.returncode == 0:
            print(result.stdout)
        else:
            print("Android setup failed:")
            print(result.stderr)
            return 1
        
        self.setup_ios()
        self.create_example_project()
        
        print("\n=== Setup Complete! ===")
        print("\nTo use the plugin:")
        print("1. Copy 'godot-admob-plugin' folder to your project's 'addons' directory")
        print("2. Enable the plugin in Project Settings > Plugins")
        print("3. The AdMob singleton will be available globally")
        print("4. See example/AdMobExample.gd for usage")
        
        return 0

if __name__ == "__main__":
    setup = AdMobPluginSetup()
    sys.exit(setup.run())