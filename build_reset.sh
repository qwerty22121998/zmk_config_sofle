#!/bin/zsh
set -e
CUR=$(pwd)
cd $HOME/Github/zmk
source .venv/bin/activate
cd app
echo "Building reset..."
west build -p -d build/reset -b nice_nano_v2 --\
 -DSHIELD="settings_reset"

cp build/reset/zephyr/zmk.uf2 $CUR/reset.uf2