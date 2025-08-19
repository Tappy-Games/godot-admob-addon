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
    
    def setup_podfile(self):
        """Create and configure Podfile for the plugin"""
        podfile_content = '''platform :ios, '12.0'
use_frameworks!

target 'GodotAdMob' do
  pod 'Google-Mobile-Ads-SDK', '~> 11.2.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
'''
        
        podfile_path = self.ios_dir / "Podfile"
        with open(podfile_path, 'w') as f:
            f.write(podfile_content)
        
        print("✓ Podfile configured")
        return True
    
    def install_pods(self):
        """Install iOS dependencies via CocoaPods"""
        print("📦 Installing iOS dependencies (this may take a few minutes)...")
        
        old_cwd = os.getcwd()
        try:
            os.chdir(self.ios_dir)
            
            # Run pod install
            result = subprocess.run(["pod", "install"], 
                                  capture_output=True, text=True, timeout=300)
            
            if result.returncode == 0:
                print("✓ iOS dependencies installed successfully")
                return True
            else:
                print("❌ Failed to install pods:")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ Pod installation timed out")
            return False
        except Exception as e:
            print(f"❌ Error during pod installation: {e}")
            return False
        finally:
            os.chdir(old_cwd)
    
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
            (self.ios_dir / "Podfile", "Podfile"),
            (self.ios_dir / "Pods", "Installed pods"),
            (self.ios_dir / "GodotAdMob.xcworkspace", "Xcode workspace"),
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
        
        if not self.setup_podfile():
            return 1
        
        if not self.install_pods():
            return 1
        
        if not self.verify_setup():
            return 1
        
        print("\n🎉 iOS setup complete!")
        print("\nNext steps:")
        print("1. Open GodotAdMob.xcworkspace in Xcode")
        print("2. Build the framework for iOS")
        print("3. Copy the built framework to your Godot iOS export")
        print("4. The AdMob SDK dependencies are now included automatically")
        
        return 0

if __name__ == "__main__":
    setup = iOSAdMobSetup()
    sys.exit(setup.run())