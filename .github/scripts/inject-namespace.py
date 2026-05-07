#!/usr/bin/env python3
"""
Inject namespace configuration for old Android plugins.
"""

import sys
import os

def inject_namespace(gradle_path):
    """Add namespace configuration to build.gradle if needed"""
    if not os.path.exists(gradle_path):
        print(f"Warning: {gradle_path} not found")
        return
    
    with open(gradle_path, 'r') as f:
        content = f.read()
    
    # Add namespace if not present (for Android Gradle Plugin 8.0+)
    if 'namespace' not in content and 'android {' in content:
        content = content.replace('android {', 'namespace "com.formfix.formfix"\n\nandroid {')
    
    with open(gradle_path, 'w') as f:
        f.write(content)
    
    print(f"✓ Updated namespace in {gradle_path}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: inject-namespace.py <gradle_path>")
        sys.exit(1)
    
    inject_namespace(sys.argv[1])
