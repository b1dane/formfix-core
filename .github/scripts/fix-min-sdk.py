#!/usr/bin/env python3
"""
Fix minSdkVersion in Flutter project's Android build configuration.
"""

import sys
import os

def fix_min_sdk(project_path):
    """Update minSdkVersion in android/app/build.gradle"""
    gradle_path = os.path.join(project_path, 'android', 'app', 'build.gradle')
    
    if not os.path.exists(gradle_path):
        print(f"Warning: {gradle_path} not found")
        return
    
    with open(gradle_path, 'r') as f:
        content = f.read()
    
    # Replace minSdkVersion with a compatible version (e.g., 21 for most Flutter apps)
    content = content.replace('minSdkVersion flutter.minSdkVersion', 'minSdkVersion 21')
    
    with open(gradle_path, 'w') as f:
        f.write(content)
    
    print(f"✓ Updated minSdkVersion in {gradle_path}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: fix-min-sdk.py <project_path>")
        sys.exit(1)
    
    fix_min_sdk(sys.argv[1])
