#!/bin/bash
#
# setup.sh — One-time KMP Gradle wrapper bootstrap
# Run this ONCE from Terminal before the first Xcode build:
#   cd KMP-framework && chmod +x setup.sh && ./setup.sh
#
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/jdk-21.0.7/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

GRADLE_VERSION="8.7"
GRADLE_TMP="/tmp/gradle-bootstrap-$GRADLE_VERSION"

if [ ! -d "$GRADLE_TMP/gradle-$GRADLE_VERSION" ]; then
    echo "⬇️  Downloading Gradle $GRADLE_VERSION..."
    mkdir -p "$GRADLE_TMP"
    curl -L "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
         -o "$GRADLE_TMP/gradle.zip"
    unzip -q "$GRADLE_TMP/gradle.zip" -d "$GRADLE_TMP"
    echo "✓ Gradle downloaded"
fi

echo "🔧 Generating Gradle wrapper (gradlew + gradle-wrapper.jar)..."
"$GRADLE_TMP/gradle-$GRADLE_VERSION/bin/gradle" wrapper \
    --gradle-version "$GRADLE_VERSION" \
    --distribution-type all

chmod +x gradlew

echo ""
echo "✅ Setup complete!"
echo "   • gradlew and gradle/wrapper/gradle-wrapper.jar have been created."
echo "   • Test KMP build: ./gradlew :shared:assembleSharedDebugXCFramework"
echo "   • Run KMP tests:  ./gradlew :shared:iosSimulatorArm64Test"
echo "   • Now build in Xcode (⌘B) — the Run Script phase handles KMP from here."
