#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"$0")
VERSION="$1"
OUTPUT_DIR="$2"

# 1. Instala dependências específicas deste app
apt-get update && apt-get install -y git \
                                     sudo \
                                     pkgconf \
                                     libx11-dev \
                                     libxfixes-dev \
                                     libxi-dev \
                                     libmagic-dev \
                                     equivs \
                                     gcc


# 2. Clona e compila
git clone https://github.com/lucas-mior/clipsim
cd clipsim
./build.sh
PREFIX=/usr DESTDIR=prefix/ ./build.sh install

# 3. Gera o arquivo control do equivs
cat <<EOF > "$PKG_NAME.control"
Section: x11
Priority: optional
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: amd64
Depends: libx11 libxfixes libxi libmagic
Files:$(while read FILE; do FILE_DIR="${FILE%/*}"; echo " ${FILE} ${FILE_DIR#*prefix}/"; done < <(find prefix/ -mindepth 2 -type f))
Homepage: https://github.com/lucas-mior/clipsim
Vcs-Git: https://github.com/lucas-mior/clipsim.git
Vcs-Browser: https://github.com/lucas-mior/clipsim

Package: $PKG_NAME
Version: 0.0~git$(date +%Y%m%d).${VERSION}-1
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: Simple and fast X clipboard manager written in C
 clipsim is a lightweight and high-performance clipboard manager designed for
 the X Window System (X11).
 .
 It preserves and manages your clipboard history efficiently with a minimal
 resource footprint.

Section: net
Priority: optional
Standards-Version: 3.9.2
EOF

# 4. Empacota e move para o diretório de saída global
DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build "$PKG_NAME.control"
cp *.deb "$OUTPUT_DIR/"
