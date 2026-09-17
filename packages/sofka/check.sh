#!/usr/bin/env bash
curl -s https://github.com/nklmilojevic/sofka/releases.atom | grep -oP '(?<=/tag/)[^"]+' | head -n 1
#curl -s "https://api.github.com/repos/nklmilojevic/sofka/releases/latest" | jq -r '.assets[] | select(.name | endswith(".deb") and contains("amd64")) | .browser_download_url'
