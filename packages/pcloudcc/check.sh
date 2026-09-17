#!/usr/bin/env bash
curl -s https://github.com/lneely/pcloudcc-lneely/commits/main.atom | awk -F'[/<]' '/Commit\// {print $3;exit}' | cut -c1-7
