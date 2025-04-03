#!/usr/bin/env bash
set -e

# Variables
PKG_NAME="supertux-advance"
PKG_VERSION="0.2.48"
ARCH="x86_64"  # Use x86_64 for RPM packages containing binaries.
MAINTAINER="Jared Tweed <jaredtwe@gmail.com>"
HOMEPAGE="https://github.com/KelvinShadewing/supertux-advance"
LICENSE="AGPL-3.0-or-later"

# Set up the RPM build tree in the current directory
RPM_TOPDIR="$(pwd)/rpm-build"
mkdir -p "${RPM_TOPDIR}"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Create the package content in the BUILD directory
PKG_DIR="${RPM_TOPDIR}/BUILD/${PKG_NAME}-${PKG_VERSION}"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps"
mkdir -p "${PKG_DIR}/usr/share/metainfo"
mkdir -p "${PKG_DIR}/usr/share/${PKG_NAME}"

# Download and extract the game
echo "Downloading SuperTux Advance..."
wget -O "${PKG_NAME}.zip" "https://github.com/JaredTweed/SuperTuxAdvance-metadata/releases/download/v${PKG_VERSION}-zip/sta-${PKG_VERSION}.zip"
unzip "${PKG_NAME}.zip" -d "${PKG_DIR}/usr/share/${PKG_NAME}"
rm "${PKG_NAME}.zip"
chmod +x "${PKG_DIR}/usr/share/${PKG_NAME}/sta/sta"

# Remove Windows files
rm -f "${PKG_DIR}/usr/share/${PKG_NAME}/sta/sta.exe"
find "${PKG_DIR}/usr/share/${PKG_NAME}/sta" -type f \( -iname "*.dll" -o -iname "*.ico" \) -delete

# Create launcher script
cat <<EOF > "${PKG_DIR}/usr/bin/${PKG_NAME}"
#!/bin/bash
cd /usr/share/${PKG_NAME}/sta
exec ./sta
EOF
chmod +x "${PKG_DIR}/usr/bin/${PKG_NAME}"

# Create .desktop file
cat <<EOF > "${PKG_DIR}/usr/share/applications/io.github.JaredTweed.SuperTuxAdvance.desktop"
[Desktop Entry]
Name=SuperTux Advance
Exec=${PKG_NAME}
Icon=io.github.JaredTweed.SuperTuxAdvance
Type=Application
Categories=Game;ArcadeGame;PlatformGame;
EOF

# Download and place icon
wget -O "${PKG_DIR}/usr/share/icons/hicolor/scalable/apps/io.github.JaredTweed.SuperTuxAdvance.svg" "https://raw.githubusercontent.com/JaredTweed/SuperTuxAdvance-metadata/main/io.github.JaredTweed.SuperTuxAdvance.svg"

# Download and place metainfo
wget -O "${PKG_DIR}/usr/share/metainfo/io.github.JaredTweed.SuperTuxAdvance.metainfo.xml" "https://raw.githubusercontent.com/JaredTweed/SuperTuxAdvance-metadata/main/io.github.JaredTweed.SuperTuxAdvance.metainfo.xml"

# Set correct permissions
chmod -R 755 "${PKG_DIR}/usr"

# Create a tarball of the package content
tar czf "${RPM_TOPDIR}/SOURCES/${PKG_NAME}-${PKG_VERSION}.tar.gz" -C "${RPM_TOPDIR}/BUILD" "${PKG_NAME}-${PKG_VERSION}"

# Create SPEC file with debug packaging disabled
cat <<EOF > "${RPM_TOPDIR}/SPECS/${PKG_NAME}.spec"
Name:           ${PKG_NAME}
Version:        ${PKG_VERSION}
Release:        1%{?dist}
Summary:        A fun fan-made platformer starring Tux

%global debug_package %{nil}

License:        ${LICENSE}
URL:            ${HOMEPAGE}
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       SDL2, SDL2_mixer, SDL2_image

%description
SuperTux Advance is a fan-made platformer game featuring Tux, the Linux mascot.

%prep
%setup -q

%build

%install
mkdir -p %{buildroot}/usr
cp -a usr/* %{buildroot}/usr/

%files
/usr/bin/${PKG_NAME}
/usr/share/${PKG_NAME}
/usr/share/applications/io.github.JaredTweed.SuperTuxAdvance.desktop
/usr/share/icons/hicolor/scalable/apps/io.github.JaredTweed.SuperTuxAdvance.svg
/usr/share/metainfo/io.github.JaredTweed.SuperTuxAdvance.metainfo.xml

%changelog
* $(date +"%a %b %d %Y") ${MAINTAINER} - ${PKG_VERSION}-1
- Initial RPM build
EOF

# Build the RPM package
rpmbuild --define "_topdir ${RPM_TOPDIR}" -ba "${RPM_TOPDIR}/SPECS/${PKG_NAME}.spec"

echo "✅ Done! Your RPM package is ready in:"
find "${RPM_TOPDIR}/RPMS" -type f -name "${PKG_NAME}-*.rpm"

