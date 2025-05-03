#!/bin/zsh
set -e
CUR=$(pwd)
rm -f *.uf2 || :
cd $HOME/Github/zmk
source .venv/bin/activate
cd app
EXTRA_MODULES="$CUR;$HOME/Github/zmk-nice-oled;$HOME/Github/zmk-dongle-display-091-oled;$HOME/Github/zmk-dongle-display;$HOME/Github/nice-view-anim"

function build_reset() {
    echo "Building reset..."
    west build -p -d build/reset -b nice_nano_v2 -- -DSHIELD="settings_reset"

    cp build/reset/zephyr/zmk.uf2 $CUR/reset.uf2
}

function build_central() {
    NAME=$1
    BOARD=$2
    SHIELD=$3
    echo "Building central $NAME..."
    west build -p -d build/central-$NAME -b $BOARD -S studio-rpc-usb-uart -- -DSHIELD="$SHIELD" \
        -DZMK_CONFIG=$CUR/config -DCONFIG_ZMK_STUDIO=y -DZMK_EXTRA_MODULES=$EXTRA_MODULES
    cp build/central-$NAME/zephyr/zmk.uf2 $CUR/central-$NAME.uf2
}

function build_peripheral() {
    NAME=$1
    BOARD=$2
    SHIELD=$3
    ARGS=$4
    echo "Building peripheral $NAME..."
    west build -p -d build/peripheral-$NAME -b $BOARD -- -DSHIELD="$SHIELD" \
        -DZMK_CONFIG=$CUR/config -DZMK_EXTRA_MODULES=$EXTRA_MODULES -DCONFIG_ZMK_SPLIT_ROLE_CENTRAL=n 
    cp build/peripheral-$NAME/zephyr/zmk.uf2 $CUR/peripheral-$NAME.uf2
}
# reset
build_reset

# nice view
build_central left-nice-view nice_nano_v2 "sofle_left nice_view_adapter_rgb nice_epaper" &
build_peripheral left-nice-view nice_nano_v2 "sofle_left nice_view_adapter_rgb nice_epaper" &
build_peripheral left-nice-view-planet nice_nano_v2 "sofle_left nice_view_adapter_rgb nice_view_anim" &
build_peripheral left-nice-view-astronaut nice_nano_v2 "sofle_left nice_view_adapter_rgb nice_view_anim" "-DCONFIG_ZMK_NICE_VIEW_ANIM_VARIANT=1" &
build_peripheral right-nice-view nice_nano_v2 "sofle_right nice_view_adapter_rgb nice_epaper" &
build_peripheral right-nice-view-planet nice_nano_v2 "sofle_right nice_view_adapter_rgb nice_view_anim" &
build_peripheral right-nice-view-astronaut nice_nano_v2 "sofle_right nice_view_adapter_rgb nice_view_anim" "-DCONFIG_ZMK_NICE_VIEW_ANIM_VARIANT=1" &
wait

# oled
build_central dongle-oled-091 nice_nano_v2 "sofle_dongle dongle_display_091_oled" &
build_central dongle-oled nice_nano_v2 "sofle_dongle dongle_display" &
build_central left-oled nice_nano_v2 "sofle_left nice_oled" &
build_peripheral left-oled nice_nano_v2 "sofle_left nice_oled" &
build_peripheral right-oled nice_nano_v2 "sofle_right nice_oled" &
wait
