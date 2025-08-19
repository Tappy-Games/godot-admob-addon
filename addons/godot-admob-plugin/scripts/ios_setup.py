#!/usr/bin/env python3

import os
import sys
import subprocess
import platform
import shutil
from pathlib import Path

class iOSAdMobSetup:
    def __init__(self):
        self.plugin_dir = Path(__file__).parent.parent
        self.ios_dir = self.plugin_dir / "ios"
        
    def check_macos(self):
        """Ensure we're running on macOS"""
        if platform.system() != "Darwin":
            print("❌ iOS setup requires macOS")
            return False
        return True
    
    def check_xcode(self):
        """Check if Xcode and command line tools are installed"""
        try:
            result = subprocess.run(["xcode-select", "--print-path"], 
                                  capture_output=True, text=True, check=True)
            print(f"✓ Xcode command line tools: {result.stdout.strip()}")
            return True
        except:
            print("❌ Xcode command line tools not found")
            print("   Run: xcode-select --install")
            return False
    
    def install_cocoapods(self):
        """Install CocoaPods if not present"""
        try:
            subprocess.run(["pod", "--version"], capture_output=True, check=True)
            print("✓ CocoaPods already installed")
            return True
        except:
            print("📦 Installing CocoaPods...")
            try:
                subprocess.run(["sudo", "gem", "install", "cocoapods"], check=True)
                print("✓ CocoaPods installed successfully")
                return True
            except:
                print("❌ Failed to install CocoaPods")
                print("   Try manually: sudo gem install cocoapods")
                return False
    
    def create_gdip_file(self):
        """Create iOS plugin configuration file"""
        gdip_content = '''[config]

name="GodotAdMob"
binary="GodotAdMob.a"

[dependencies]

linked_frameworks=["GoogleMobileAds"]
embedded_frameworks=[]
system_frameworks=["AdSupport", "AppTrackingTransparency", "AudioToolbox", "AVFoundation", "CFNetwork", "CoreGraphics", "CoreMedia", "CoreTelephony", "CoreVideo", "MediaPlayer", "MessageUI", "MobileCoreServices", "QuartzCore", "Security", "StoreKit", "SystemConfiguration", "WebKit"]
xcframeworks=[]

[plist]

'''
        
        gdip_path = self.ios_dir / "GodotAdMob.gdip"
        with open(gdip_path, 'w') as f:
            f.write(gdip_content)
        
        print("✓ iOS plugin configuration created")
        return True
    
    def setup_plugin_structure(self):
        """Set up iOS plugin structure for Godot"""
        print("📦 Setting up iOS plugin structure...")
        
        # Check if we have the necessary source files
        source_files = [
            self.ios_dir / "GodotAdMob.mm",
            self.ios_dir / "Info.plist"
        ]
        
        missing_files = []
        for file_path in source_files:
            if not file_path.exists():
                missing_files.append(file_path.name)
        
        if missing_files:
            print(f"⚠ Missing source files: {', '.join(missing_files)}")
            print("  iOS plugin requires native implementation files")
            return False
        
        print("✓ iOS plugin structure verified")
        return True
    
    def create_xcodeproj(self):
        """Create basic Xcode project structure"""
        # This creates a minimal .xcodeproj that can be used to build the plugin
        project_dir = self.ios_dir / "GodotAdMob.xcodeproj"
        project_dir.mkdir(exist_ok=True)
        
        # Create project.pbxproj file
        pbxproj_content = '''// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
		/* Begin PBXBuildFile section */
		/* End PBXBuildFile section */
		
		/* Begin PBXFileReference section */
		/* End PBXFileReference section */
		
		/* Begin PBXFrameworksBuildPhase section */
		/* End PBXFrameworksBuildPhase section */
		
		/* Begin PBXGroup section */
		/* End PBXGroup section */
		
		/* Begin PBXNativeTarget section */
		/* End PBXNativeTarget section */
		
		/* Begin PBXProject section */
		/* End PBXProject section */
		
		/* Begin XCBuildConfiguration section */
		/* End XCBuildConfiguration section */
		
		/* Begin XCConfigurationList section */
		/* End XCConfigurationList section */
	};
	rootObject = "Root Project";
}
'''
        
        with open(project_dir / "project.pbxproj", 'w') as f:
            f.write(pbxproj_content)
        
        print("✓ Xcode project structure created")
        return True
    
    def verify_setup(self):
        """Verify that everything is set up correctly"""
        checks = [
            (self.ios_dir / "GodotAdMob.gdip", "iOS plugin configuration"),
            (self.ios_dir / "GodotAdMob.mm", "Native implementation"),
            (self.ios_dir / "Info.plist", "Info.plist"),
        ]
        
        all_good = True
        for path, name in checks:
            if path.exists():
                print(f"✓ {name} found")
            else:
                print(f"❌ {name} missing")
                all_good = False
        
        return all_good
    
    def run(self):
        """Run the complete iOS setup"""
        print("=== iOS AdMob Plugin Setup ===\n")
        
        if not self.check_macos():
            return 1
        
        if not self.check_xcode():
            return 1
        
        if not self.install_cocoapods():
            return 1
        
        if not self.create_gdip_file():
            return 1
        
        if not self.setup_plugin_structure():
            return 1
        
        if not self.verify_setup():
            return 1
        
        print("\n🎉 iOS setup complete!")
        print("\nNext steps:")
        print("1. The plugin is ready for iOS export")
        print("2. Export your project to iOS - the plugin will be automatically included")
        print("3. AdMob SDK dependencies will be handled during the export process")
        print("4. For headless export: godot --headless --export-release 'iOS' builds/ios/")
        
        return 0

if __name__ == "__main__":
    setup = iOSAdMobSetup()
    sys.exit(setup.run())