#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"$0")
VERSION="$1"
OUTPUT_DIR="$2"

apt update && apt install -y jq \
                             curl \
                             equivs \
                             binutils-arm-linux-gnueabihf

mkdir -p prefix/usr/bin/
mkdir -p prefix/usr/share/doc/$PKG_NAME
URL=$(curl -s "https://api.github.com/repos/bluenviron/mediamtx/releases/tags/$VERSION" | jq -r '.assets[]|select(.name|contains("armv7"))|.browser_download_url')

tar xvf "${URL##*/}"

mv ./mediamtx prefix/usr/bin/
mv ./mediamtx.yml prefix/usr/share/doc/$PKG_NAME/

cat <<EOF > "$PKG_NAME.control"
Section: net
Priority: optional
Standards-Version: 4.6.2

Package: ${PKG_NAME}
Version: ${VERSION#v}
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: armhf
Files: $(while read FILE; do FILE_DIR="${FILE%/*}"; echo " ${FILE} ${FILE_DIR#*prefix}/"; done < <(find prefix/ -mindepth 2 -type f))
Description: Ready-to-use real-time media server and proxy
MediaMTX (formerly rtsp-simple-server) is a ready-to-use and zero-dependency
real-time media server and media proxy that allows to publish, read,
and proxy live video and audio streams.
.
Key features:
Supports RTSP, RTMP, HLS, WebRTC, and SRT protocols.
Allows publishing and reading streams across different protocols.
Low latency and low resource consumption.
Written in Go.
EOF

DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build --arch armhf "$PKG_NAME.control"

cp *.deb "$OUTPUT_DIR/"
