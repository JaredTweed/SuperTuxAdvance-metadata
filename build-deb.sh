#!/bin/bash

# Set package name and version
PKG_NAME="supertux-advance"
PKG_VERSION="0.2.48"
ARCH="amd64"
MAINTAINER="Jared Tweed <jaredtwe@gmail.com>"
HOMEPAGE="https://github.com/KelvinShadewing/supertux-advance"
LICENSE="AGPL-3.0-or-later"

# Set up working directory
BUILD_DIR="${PKG_NAME}-deb"
mkdir -p ${BUILD_DIR}/DEBIAN

# Create control file
cat <<EOF > ${BUILD_DIR}/DEBIAN/control
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${ARCH}
Maintainer: ${MAINTAINER}
Description: A fun fan-made platformer starring Tux.
Depends: libc6, libgl1, libglu1-mesa, libsdl2-2.0-0, libsdl2-mixer-2.0-0, libsdl2-image-2.0-0
Section: games
Priority: optional
Homepage: ${HOMEPAGE}
EOF

# Create necessary directories
mkdir -p ${BUILD_DIR}/usr/bin
mkdir -p ${BUILD_DIR}/usr/share/applications
mkdir -p ${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps
mkdir -p ${BUILD_DIR}/usr/share/metainfo
mkdir -p ${BUILD_DIR}/usr/share/${PKG_NAME}

# Download and extract the game
echo "Downloading SuperTux Advance..."
wget -O ${PKG_NAME}.zip "https://github.com/JaredTweed/SuperTuxAdvance-metadata/releases/download/v${PKG_VERSION}-zip/sta-${PKG_VERSION}.zip"
unzip ${PKG_NAME}.zip -d ${BUILD_DIR}/usr/share/${PKG_NAME}
chmod +x ${BUILD_DIR}/usr/share/${PKG_NAME}/sta/sta

# Create launcher script
cat <<EOF > ${BUILD_DIR}/usr/bin/${PKG_NAME}
#!/bin/bash
cd /usr/share/${PKG_NAME}/sta
exec ./sta
EOF
chmod +x ${BUILD_DIR}/usr/bin/${PKG_NAME}

# Create .desktop file
cat <<EOF > ${BUILD_DIR}/usr/share/applications/io.github.JaredTweed.SuperTuxAdvance.desktop
[Desktop Entry]
Name=SuperTux Advance
Exec=${PKG_NAME}
Icon=io.github.JaredTweed.SuperTuxAdvance
Type=Application
Categories=Game;ArcadeGame;PlatformGame;
EOF

# Download and place icon
wget -O ${BUILD_DIR}/usr/share/icons/hicolor/scalable/apps/io.github.JaredTweed.SuperTuxAdvance.svg \
    "https://raw.githubusercontent.com/JaredTweed/SuperTuxAdvance-metadata/main/io.github.JaredTweed.SuperTuxAdvance.svg"

# Download and place metainfo
wget -O ${BUILD_DIR}/usr/share/metainfo/io.github.JaredTweed.SuperTuxAdvance.metainfo.xml \
    "https://raw.githubusercontent.com/JaredTweed/SuperTuxAdvance-metadata/main/io.github.JaredTweed.SuperTuxAdvance.metainfo.xml"

# Set correct permissions
chmod -R 755 ${BUILD_DIR}/usr

# Build the .deb package
dpkg-deb --build ${BUILD_DIR}

# Rename and cleanup
mv ${BUILD_DIR}.deb ${PKG_NAME}-${PKG_VERSION}_${ARCH}.deb
rm -rf ${BUILD_DIR}
rm ${PKG_NAME}.zip

# Update desktop database
update-desktop-database ~/.local/share/applications/
sudo update-desktop-database

echo "✅ Done! Your .deb package is ready: ${PKG_NAME}-${PKG_VERSION}_${ARCH}.deb"
