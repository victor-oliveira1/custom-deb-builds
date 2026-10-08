#!/usr/bin/env bash
curl -s https://github.com/bluenviron/mediamtx/releases.atom | grep -oP '(?<=/tag/)[^"]+' | head -n 1
