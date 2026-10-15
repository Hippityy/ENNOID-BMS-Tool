#!/usr/bin/env bash
set -e

echo "============================================="
echo "   Building ENNOID-BMS-Tool for macOS"
echo "============================================="

# 1. Locate qmake (supports Apple Silicon /opt/homebrew and Intel /usr/local)
if command -v qmake >/dev/null 2>&1; then
    QMAKE_BIN="qmake"
elif [ -x "/opt/homebrew/opt/qt@5/bin/qmake" ]; then
    QMAKE_BIN="/opt/homebrew/opt/qt@5/bin/qmake"
    export PATH="/opt/homebrew/opt/qt@5/bin:$PATH"
elif [ -x "/usr/local/opt/qt@5/bin/qmake" ]; then
    QMAKE_BIN="/usr/local/opt/qt@5/bin/qmake"
    export PATH="/usr/local/opt/qt@5/bin:$PATH"
else
    echo "Error: qmake not found!"
    echo "Please install Qt 5 via Homebrew: brew install qt@5"
    echo "If already installed, ensure it is in your PATH:"
    echo "  export PATH=\"/opt/homebrew/opt/qt@5/bin:\$PATH\""
    exit 1
fi

echo "Using qmake at: $QMAKE_BIN"

# 2. Locate macdeployqt
MACDEPLOYQT_BIN=""
if command -v macdeployqt >/dev/null 2>&1; then
    MACDEPLOYQT_BIN="macdeployqt"
elif [ -x "/opt/homebrew/opt/qt@5/bin/macdeployqt" ]; then
    MACDEPLOYQT_BIN="/opt/homebrew/opt/qt@5/bin/macdeployqt"
elif [ -x "/usr/local/opt/qt@5/bin/macdeployqt" ]; then
    MACDEPLOYQT_BIN="/usr/local/opt/qt@5/bin/macdeployqt"
fi

NCPU=$(sysctl -n hw.ncpu 2>/dev/null || echo 4)

echo "Step 1: Running qmake..."
"$QMAKE_BIN" "CONFIG-=build_mobile" ENNOID-BMS-Tool.pro

echo "Step 2: Compiling with $NCPU cores..."
make -j"$NCPU"

APP_PATH="ENNOID-BMS-Tool.app"
if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH was not created!"
    exit 1
fi

echo "Step 3: Deploying Qt frameworks and creating DMG..."
if [ -n "$MACDEPLOYQT_BIN" ]; then
    "$MACDEPLOYQT_BIN" "$APP_PATH" -qmldir=mobile -dmg
    echo "Generated disk image: ENNOID-BMS-Tool.dmg"
else
    echo "Warning: macdeployqt not found, skipping DMG packaging."
fi

echo ""
echo "============================================="
echo "   Build completed successfully!"
echo "   App: $(pwd)/$APP_PATH"
if [ -f "ENNOID-BMS-Tool.dmg" ]; then
    echo "   DMG: $(pwd)/ENNOID-BMS-Tool.dmg"
fi
echo "============================================="
echo ""
echo "Note for sharing with other Macs:"
echo "If macOS blocks opening on another Mac, run:"
echo "  xattr -cr /Applications/ENNOID-BMS-Tool.app"
