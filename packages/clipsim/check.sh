#!/usr/bin/env bash
curl -s https://github.com/lucas-mior/clipsim/commits/master.atom | awk -F'[/<]' '/Commit\// {print $3;exit}' | cut -c1-7
