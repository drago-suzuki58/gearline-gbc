#!/bin/sh
# GEARLINE build script. Needs RGBDS (rgbasm/rgblink/rgbfix) and python3.
set -e
cd "$(dirname "$0")"
RGBDS="${RGBDS:-}"
python3 tools/gen.py
"${RGBDS}rgbasm" -Wall -o build/main.o src/main.asm
"${RGBDS}rgblink" -m build/gearline.map -n build/gearline.sym -o gearline.gbc build/main.o
"${RGBDS}rgbfix" -v -C -m 0x1B -r 0x02 -p 0xFF -t "GEARLINE" gearline.gbc
ls -l gearline.gbc
