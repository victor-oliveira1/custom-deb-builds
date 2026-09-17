#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"$0")
VERSION="$1"
OUTPUT_DIR="$2"

# 1. Instala dependências específicas deste app
apt-get update && apt-get install -y git sudo lsb-release equivs golang libpng-dev libx11-dev libxcb1-dev

# 2. Clona e compila
git clone https://github.com/d99kris/nchat
cd nchat
git checkout "$VERSION"

./make.sh deps -y
NCHAT_CMAKEARGS="-DCMAKE_INSTALL_PREFIX=/usr" ./make.sh build --no-telegram
cd build
make install DESTDIR=./prefix

# 3. Gera o arquivo control do equivs
cat <<EOF > "$PKG_NAME.control"
Section: net
Priority: optional
Standards-Version: 3.9.2

Package: $PKG_NAME
Version: ${VERSION#v}
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: amd64
Depends: $(find prefix -type f -exec dpkg-shlibdeps -O {} + 2>/dev/null | sed -e 's/shlibs:Depends=//' -e 's/\n/,/g' -e 's/,,*/,/g; s/^,//; s/,$//')
Files: $(while read FILE; do FILE_DIR="${FILE%/*}"; echo " ${FILE} ${FILE_DIR#*prefix}/"; done < <(find prefix/ -mindepth 2 -type f))
Description: Terminal-based Telegram and WhatsApp client
 nchat is a terminal-based chat client with support for
 Telegram and WhatsApp. It features a modern ncurses UI.
EOF

# 4. Empacota e move para o diretório de saída global
DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build $PKG_NAME.control
cp *.deb "$OUTPUT_DIR/"
