#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"$0")
VERSION="$1"
OUTPUT_DIR="$2"

apt update && apt install -y jq \
                             curl \
                             equivs \
                             arm-linux-gnueabihf-objdump

mkdir -p prefix/usr/bin/
URL=$(curl -s "https://api.github.com/repos/gtsteffaniak/filebrowser/releases/latest" | jq -r '.assets[]|select(.name == "linux-armv7-filebrowser")|.browser_download_url')
curl -L "$URL" --output prefix/usr/bin/filebrowser-quantum

cat <<EOF > "$PKG_NAME.control"
Section: utils
Priority: optional
Standards-Version: 4.6.2

Package: ${PKG_NAME}
Version: ${VERSION#v}
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: armhf
Files: $(while read FILE; do FILE_DIR="${FILE%/*}"; echo " ${FILE} ${FILE_DIR#*prefix}/"; done < <(find prefix/ -mindepth 2 -type f))
Description: Web-based file manager (Quantum fork)
 Filebrowser Quantum is a features-rich web file manager fork designed to
 manage files directly through a clean web interface. It provides file
 uploading, editing, previewing, user management, and custom commands execution.
EOF

DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build --arch armhf "$PKG_NAME.control"

cp *.deb "$OUTPUT_DIR/"
