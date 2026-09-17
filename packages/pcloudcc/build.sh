#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"${0}")
VERSION="$1"
OUTPUT_DIR="$2"

# 1. Instala dependências específicas deste app
apt-get update && apt-get install -y git \
                                     equivs \
                                     libfuse3-dev \
                                     libreadline-dev \
                                     libmbedtls-dev \
                                     libsqlite3-dev \
                                     libudev-dev \
                                     zlib1g-dev \
                                     pkgconf

# 2. Clona e compila
git clone https://github.com/lneely/pcloudcc-lneely build_src
cd build_src
git checkout "$VERSION"

make -j$(nproc)
mkdir -p prefix/usr/bin
cp pcloudcc prefix/usr/bin/

# 3. Gera o arquivo control do equivs
cat <<EOF > "${PKG_NAME}".control
Section: net
Priority: optional
Standards-Version: 3.9.2

Package: "${PKG_NAME}"
Version: 0.0~git$(date +%Y%m%d).${VERSION}-1
Maintainer: Victor Oliveira <victor.oliveira@gmx.com>
Architecture: amd64
Depends: $(find prefix -type f -exec dpkg-shlibdeps -O {} + 2>/dev/null | sed -e 's/shlibs:Depends=//' -e 's/\n/,/g' -e 's/,,*/,/g; s/^,//; s/,$//')
Files:$(while read FILE; do FILE_DIR="${FILE%/*}"; echo " ${FILE} ${FILE_DIR#*prefix}/"; done < <(find prefix/ -mindepth 2 -type f))
Description: pcloudcc-lneely is an independent fork of the inactive pcloudcom/console-client
 .
 It's used to mount pCloud folder as a local directory.
EOF

# 4. Empacota e move para o diretório de saída global
DEB_BUILD_OPTIONS="nostrip nodwz" equivs-build "${PKG_NAME}".control
cp *.deb "$OUTPUT_DIR/"
