#!/usr/bin/env bash
set -e

VERSION="$1"
OUTPUT_DIR="$2"

# 1. Instala dependências específicas deste app
apt-get update && apt-get install -y git sudo lsb-release equivs golang libpng-dev libx11-dev libxcb1-dev

# 2. Clona e compila
git clone https://github.com/d99kris/nchat build_src
cd build_src
git checkout "$VERSION"

./make.sh deps -y
NCHAT_CMAKEARGS="-DCMAKE_INSTALL_PREFIX=/usr" ./make.sh build --no-telegram
cd build
make install DESTDIR=./prefix

# 3. Gera o arquivo control do equivs
cat <<EOF > nchat.control
Section: net
Priority: optional
Standards-Version: 3.9.2

Package: nchat
Version: ${VERSION#v}
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: amd64
Depends: libreadline8, libssl3, libncursesw6, libsqlite3-0, libmagic1, libxcb1
Files:$(while read L; do D=${L%/*}; echo " ./prefix$L $D/"; done < install_manifest.txt)
Description: Terminal-based Telegram and WhatsApp client
 nchat is a terminal-based chat client with support for
 Telegram and WhatsApp. It features a modern ncurses UI.
EOF

# 4. Empacota e move para o diretório de saída global
DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build nchat.control
cp *.deb "$OUTPUT_DIR/"
