#!/usr/bin/env bash
curl -s https://github.com/lneely/pcloudcc-lneely/releases.atom | grep -oP '(?<=/tag/)[^"]+' | head -n 1
