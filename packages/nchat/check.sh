#!/usr/bin/env bash
curl -s https://github.com/d99kris/nchat/releases.atom | grep -oP '(?<=/tag/)[^"]+' | head -n 1
