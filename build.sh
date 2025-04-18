#!/bin/zsh
set -e
CUR=$(pwd)
cd $HOME/Github/zmk
source .venv/bin/activate
cd app

EXTRA_MODULES="$CUR;$HOME/Github/zmk-nice-oled"

echo "Building dongle..."
west build -p -d build/dongle -b nice_nano_v2 -S studio-rpc-usb-uart -- -DSHIELD="sofle_dongle dongle_display_091_oled" \
    -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_STUDIO=y -DZMK_EXTRA_MODULES="$EXTRA_MODULES;$HOME/Github/zmk-dongle-display-091-oled"
echo "Building left..."
west build -p -d build/left -b nice_nano_v2 -- -DSHIELD="sofle_left nice_oled" \
    -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n -DZMK_EXTRA_MODULES=$EXTRA_MODULES\
    -DCONFIG_NICE_OLED_GEM_ANIMATION_MS=1920

echo "Building right..."
west build -p -d build/right -b nice_nano_v2 -- -DSHIELD="sofle_right nice_oled" \
    -DZMK_CONFIG=$CUR/config -DZMK_EXTRA_MODULES=$EXTRA_MODULES\
    -DCONFIG_NICE_OLED_GEM_ANIMATION_MS=1920

cp build/dongle/zephyr/zmk.uf2 $CUR/sofle_dongle.uf2
cp build/left/zephyr/zmk.uf2 $CUR/sofle_left.uf2
cp build/right/zephyr/zmk.uf2 $CUR/sofle_right.uf2
