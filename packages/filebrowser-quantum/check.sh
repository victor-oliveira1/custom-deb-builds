#!/usr/bin/env bash
curl -s https://github.com/gtsteffaniak/filebrowser/releases.atom | grep -oP '(?<=/tag/)[^"]+' | head -n 1
