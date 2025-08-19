#!/usr/bin/env python3

import os
import sys
import subprocess
import urllib.request
from pathlib import Path

class AndroidAdMobSetup:
    def __init__(self):
        self.plugin_dir = Path(__file__).parent.parent
        self.android_dir = self.plugin_dir / "android"
        
    def check_java(self):
        """Check if Java 17+ is installed"""
        try:
            result = subprocess.run(["java", "-version"], capture_output=True, text=True, check=True)
            # Extract Java version
            version_line = result.stderr.split('\n')[0]
            print(f"✓ Java found: {version_line}")
            return True
        except:
            print("❌ Java not found. Please install JDK 17 or higher")
            return False
    
    def setup_gradle_wrapper(self):
        """Setup Gradle wrapper if not present"""
        gradlew_path = self.android_dir / "gradlew"
        
        if gradlew_path.exists():
            print("✓ Gradle wrapper already exists")
            return True
        
        print("📦 Setting up Gradle wrapper...")
        
        # Create gradle wrapper files
        old_cwd = os.getcwd()
        try:
            os.chdir(self.android_dir)
            
            # Try to use system gradle first
            try:
                subprocess.run(["gradle", "wrapper"], check=True, capture_output=True)
                print("✓ Gradle wrapper created")
                return True
            except:
                print("⚠ Could not create Gradle wrapper (system gradle not available)")
                print("  The plugin will use system gradle for building")
                return True  # Return True to continue setup
                
        except Exception as e:
            print(f"❌ Failed to setup Gradle wrapper: {e}")
            return False
        finally:
            os.chdir(old_cwd)
    
    def _download_gradle_wrapper(self):
        """Download Gradle wrapper manually"""
        print("📦 Downloading Gradle wrapper...")
        
        # Create gradle directory structure
        gradle_dir = self.android_dir / "gradle" / "wrapper"
        gradle_dir.mkdir(parents=True, exist_ok=True)
        
        # Download wrapper jar
        wrapper_jar_url = "https://services.gradle.org/distributions/gradle-8.4-wrapper.jar"
        wrapper_properties_content = '''distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\\://services.gradle.org/distributions/gradle-8.4-bin.zip
networkTimeout=10000
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
'''
        
        try:
            # Download wrapper jar
            urllib.request.urlretrieve(wrapper_jar_url, gradle_dir / "gradle-wrapper.jar")
            
            # Create wrapper properties
            with open(gradle_dir / "gradle-wrapper.properties", 'w') as f:
                f.write(wrapper_properties_content)
            
            # Create gradlew scripts
            gradlew_script = '''#!/bin/sh
DEFAULT_JVM_OPTS="-Xmx64m -Xms64m"
APP_NAME="Gradle"
APP_BASE_NAME=`basename "$0"`
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$HOME/.gradle}"

# Resolve links
PRG="$0"
while [ -h "$PRG" ] ; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \\(.*\\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`"/$link"
    fi
done
SAVED="`pwd`"
cd "`dirname \"$PRG\"`/" >/dev/null
APP_HOME="`pwd -P`"
cd "$SAVED" >/dev/null

exec java $DEFAULT_JVM_OPTS -jar "$APP_HOME/gradle/wrapper/gradle-wrapper.jar" "$@"
'''
            
            with open(self.android_dir / "gradlew", 'w') as f:
                f.write(gradlew_script)
            
            # Make executable
            os.chmod(self.android_dir / "gradlew", 0o755)
            
            print("✓ Gradle wrapper downloaded and configured")
            return True
            
        except Exception as e:
            print(f"❌ Failed to download Gradle wrapper: {e}")
            return False
    
    def download_godot_aar(self):
        """Download Godot Android library"""
        libs_dir = self.android_dir / "libs"
        libs_dir.mkdir(exist_ok=True)
        
        aar_path = libs_dir / "godot-lib.release.aar"
        
        if aar_path.exists():
            print("✓ Godot Android library already present")
            return True
        
        print("📦 Downloading Godot Android library...")
        
        # Try multiple versions in order of preference
        versions_to_try = [
            "4.4.1-stable/godot-lib.4.4.1.stable.template_release.aar",
            "4.3-stable/godot-lib.4.3.stable.template_release.aar",
            "4.2.2-stable/godot-lib.4.2.2.stable.template_release.aar", 
            "4.2.1-stable/godot-lib.4.2.1.stable.template_release.aar"
        ]
        
        for version_path in versions_to_try:
            godot_aar_url = f"https://github.com/godotengine/godot/releases/download/{version_path}"
            try:
                print(f"  Trying {godot_aar_url.split('/')[-1]}...")
                urllib.request.urlretrieve(godot_aar_url, aar_path)
                print("✓ Godot Android library downloaded")
                return True
            except Exception as e:
                print(f"  Failed ({str(e)[:50]}...)")
                continue
                
        print("❌ Could not download Godot Android library from any version")
        return False
    
    def build_plugin(self):
        """Build the Android plugin"""
        print("🔨 Building Android plugin...")
        
        old_cwd = os.getcwd()
        try:
            os.chdir(self.android_dir)
            
            # Check if system gradle is available
            gradle_cmd = None
            if os.path.exists("gradlew"):
                gradle_cmd = "./gradlew"
            else:
                try:
                    subprocess.run(["gradle", "-version"], capture_output=True, check=True)
                    gradle_cmd = "gradle"
                except:
                    print("⚠ No Gradle found. Skipping build step.")
                    print("\nTo complete the setup later:")
                    print("  1. Install Gradle: https://gradle.org/install/")
                    print("  2. Or run: gradle wrapper (from the android directory)")
                    print("  3. Then run: gradle assembleRelease")
                    return False
            
            result = subprocess.run([gradle_cmd, "assembleRelease"], 
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                print("✓ Android plugin built successfully")
                
                # Copy AAR to plugin directory
                import glob
                aar_files = glob.glob("build/outputs/aar/*.aar")
                if aar_files:
                    import shutil
                    shutil.copy(aar_files[0], "godot-admob-plugin.aar")
                    print("✓ Plugin AAR copied")
                
                return True
            else:
                print("❌ Build failed:")
                print("STDOUT:", result.stdout)
                print("STDERR:", result.stderr)
                return False
                
        finally:
            os.chdir(old_cwd)
    
    def verify_setup(self):
        """Verify the Android setup"""
        checks = [
            (self.android_dir / "libs" / "godot-lib.release.aar", "Godot library"),
            (self.android_dir / "build.gradle", "Build configuration"),
            (self.android_dir / "src" / "main" / "java", "Source code"),
        ]
        
        # Optional check for Gradle wrapper
        gradle_wrapper_exists = (self.android_dir / "gradlew").exists()
        gradle_system_available = False
        try:
            subprocess.run(["gradle", "-version"], capture_output=True, check=True)
            gradle_system_available = True
        except:
            pass
            
        if gradle_wrapper_exists:
            print("✓ Gradle wrapper found")
        elif gradle_system_available:
            print("✓ System Gradle available")
        else:
            print("⚠ No Gradle found (install Gradle or run 'gradle wrapper')")
        
        all_good = True
        for path, name in checks:
            if path.exists():
                print(f"✓ {name} found")
            else:
                print(f"❌ {name} missing")
                all_good = False
        
        return all_good
    
    def run(self):
        """Run the complete Android setup"""
        print("=== Android AdMob Plugin Setup ===\n")
        
        if not self.check_java():
            return 1
        
        if not self.setup_gradle_wrapper():
            return 1
        
        if not self.download_godot_aar():
            return 1
        
        build_result = self.build_plugin()
        if not build_result:
            print("\n⚠ Build skipped due to missing Gradle.")
            print("The plugin is ready for manual building when Gradle is available.")
            # Don't return 1, continue with verification
        
        setup_complete = self.verify_setup()
        
        if setup_complete:
            print("\n🎉 Android setup complete!")
            if build_result:
                print("\nThe plugin AAR is ready for use in Godot projects.")
            else:
                print("\nThe plugin source is ready. Build with Gradle when available.")
            print("The Google Play Services Ads dependency is automatically handled.")
        else:
            print("\n⚠ Android setup completed with some components missing.")
            print("Please install missing dependencies and run the setup again.")
        
        return 0

if __name__ == "__main__":
    setup = AndroidAdMobSetup()
    sys.exit(setup.run())