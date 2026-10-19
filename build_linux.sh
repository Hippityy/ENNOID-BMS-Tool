#!/usr/bin/env bash
set -e

echo "============================================="
echo "   Building ENNOID-BMS-Tool for Linux"
echo "============================================="

# 1. Locate qmake
if command -v qmake >/dev/null 2>&1; then
    QMAKE_BIN="qmake"
elif command -v qmake-qt5 >/dev/null 2>&1; then
    QMAKE_BIN="qmake-qt5"
elif [ -x "/usr/lib/qt5/bin/qmake" ]; then
    QMAKE_BIN="/usr/lib/qt5/bin/qmake"
else
    echo "Error: qmake not found!"
    echo "Please install Qt 5 development packages:"
    echo "  sudo apt-get install qtbase5-dev qtdeclarative5-dev qtquickcontrols2-5-dev libqt5serialport5-dev libqt5bluetooth5-dev qttools5-dev-tools"
    exit 1
fi

echo "Using qmake at: $QMAKE_BIN"

NCPU=$(nproc 2>/dev/null || echo 4)

echo "Step 1: Running qmake..."
"$QMAKE_BIN" "CONFIG-=build_mobile" "CONFIG+=release" ENNOID-BMS-Tool.pro

echo "Step 2: Compiling with $NCPU cores..."
make -j"$NCPU"

# 2. Locate built binary
BIN_PATH=$(find . -maxdepth 2 -name "ENNOID-BMS-ToolV*" -type f -executable | head -n 1)
if [ -z "$BIN_PATH" ]; then
    echo "Error: Application binary not found!"
    exit 1
fi

echo "Built binary: $BIN_PATH"

# 3. Packaging (AppImage & Tarball)
if [ "$1" == "--package" ] || [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    echo "Step 3: Packaging Linux distribution..."

    # Desktop file
    cat << 'EOF' > ennoid-bms-tool.desktop
[Desktop Entry]
Type=Application
Name=ENNOID-BMS-Tool
GenericName=Battery Management System Tool
Comment=Configuration and monitoring tool for ENNOID-BMS
Exec=ENNOID-BMS-Tool
Icon=ennoid-bms-tool
Categories=Utility;Development;
Terminal=false
EOF

    cp res/logo.png ennoid-bms-tool.png

    # Create AppDir
    rm -rf AppDir
    mkdir -p AppDir/usr/bin
    cp "$BIN_PATH" AppDir/usr/bin/ENNOID-BMS-Tool

    # Download linuxdeploy tools if not present
    if [ ! -f "linuxdeploy-x86_64.AppImage" ]; then
        echo "Downloading linuxdeploy..."
        wget -q -O linuxdeploy-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
        chmod +x linuxdeploy-x86_64.AppImage
    fi

    if [ ! -f "linuxdeploy-plugin-qt-x86_64.AppImage" ]; then
        echo "Downloading linuxdeploy-plugin-qt..."
        wget -q -O linuxdeploy-plugin-qt-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage
        chmod +x linuxdeploy-plugin-qt-x86_64.AppImage
    fi

    export APPIMAGE_EXTRACT_AND_RUN=1
    export QML_SOURCES_PATHS=mobile
    export EXTRA_PLATFORM_PLUGINS=libqxcb.so

    echo "Running linuxdeploy..."
    ./linuxdeploy-x86_64.AppImage --appdir AppDir \
        -d ennoid-bms-tool.desktop \
        -i ennoid-bms-tool.png \
        --plugin qt \
        --output appimage

    # Standardize AppImage name
    APPIMAGE_OUT=$(find . -maxdepth 1 -name "ENNOID-BMS-Tool*.AppImage" -not -name "*linuxdeploy*" | head -n 1)
    if [ -n "$APPIMAGE_OUT" ] && [ "$APPIMAGE_OUT" != "./ENNOID-BMS-Tool-Linux-x86_64.AppImage" ]; then
        mv "$APPIMAGE_OUT" ENNOID-BMS-Tool-Linux-x86_64.AppImage
    fi

    echo "Packaging portable tarball..."
    tar -czf ENNOID-BMS-Tool-Linux-x86_64.tar.gz -C AppDir .

    echo "Generated packages:"
    ls -lh ENNOID-BMS-Tool-Linux-x86_64.* 2>/dev/null || true
fi

echo "============================================="
echo "   Linux build completed successfully!"
echo "============================================="
