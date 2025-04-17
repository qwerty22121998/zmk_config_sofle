#!/bin/zsh
set -e
CUR=$(pwd)
cd $HOME/Github/zmk
source .venv/bin/activate
cd app

echo "Building dongle..."
west build -p -d build/dongle -b nice_nano_v2 -S studio-rpc-usb-uart -- -DSHIELD="sofle_dongle" \
    -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_STUDIO=y -DZMK_EXTRA_MODULES=$CUR

echo "Building left..."
west build -p -d build/left -b nice_nano_v2 -- -DSHIELD="sofle_left" \
    -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n -DZMK_EXTRA_MODULES=$CUR

echo "Building right..."
west build -p -d build/right -b nice_nano_v2 -- -DSHIELD="sofle_right" \
    -DZMK_CONFIG=$CUR/config -DZMK_EXTRA_MODULES=$CUR

cp build/dongle/zephyr/zmk.uf2 $CUR/sofle_dongle.uf2
cp build/left/zephyr/zmk.uf2 $CUR/sofle_left.uf2
cp build/right/zephyr/zmk.uf2 $CUR/sofle_right.uf2
