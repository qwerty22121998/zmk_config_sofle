#!/bin/zsh
set -e
CUR=$(pwd)
cd $HOME/Github/zmk
source .venv/bin/activate
cd app
echo "Building left..."
west build -p -d build/left -b nice_nano_v2 -S studio-rpc-usb-uart --\
 -DSHIELD="sofle_left nice_oled"\
 -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_STUDIO=y\
 -DZMK_EXTRA_MODULES=$HOME/Github/zmk-nice-oled

echo "Buiilding right..."
west build -p -d build/right -b nice_nano_v2 --\
 -DSHIELD="sofle_right nice_oled" -DZMK_CONFIG=$CUR/config\
 -DZMK_EXTRA_MODULES=$HOME/Github/zmk-nice-oled

cp build/left/zephyr/zmk.uf2 $CUR/sofle_left.uf2
cp build/right/zephyr/zmk.uf2 $CUR/sofle_right.uf2