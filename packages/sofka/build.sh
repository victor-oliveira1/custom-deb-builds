#!/usr/bin/env bash
set -e

PKG_NAME=$(awk -F'/' '{print $(NF-1)}' <<<"$0")
VERSION="$1"
OUTPUT_DIR="$2"

URL=$(curl -s "https://api.github.com/repos/nklmilojevic/sofka/releases/latest" | jq -r '.assets[] | select(.name | endswith(".deb") and contains("amd64")) | .browser_download_url')
curl -LO "$URL"
cp *.deb "$OUTPUT_DIR/"
