#!/usr/bin/env bash

set -e

case "$1" in
	left)
		ZMK_SPLIT_SIDE="left"
		;;
	right)
		ZMK_SPLIT_SIDE="right"
		;;
	both)
		ZMK_SPLIT_SIDE="both"
		;;
	reset)
		ZMK_SPLIT_SIDE="left"
		ZMK_RESET="y"
		;;
	*)
		ZMK_SPLIT_SIDE="left"
		;;
esac

if [ -z "$ZEPHYR_BASE" ]; then
	ZEPHYR_BASE="$HOME/src/github.com/zmkfirmware/zmk/zephyr"
fi
if [ ! -d "$ZEPHYR_BASE/../app" ]; then
	echo "ZEPHYR_BASE environment variable not a valid ZMK repo"
	exit 1
fi

if [ -z "$ZMK_CONFIG" ]; then
	# If running in the ZMK VSCode container workspace...
	if [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
		# Use the container volume.
		ZMK_CONFIG="$ZEPHYR_BASE/../../zmk-config"
	else
		# Use my module
		ZMK_CONFIG="$HOME/src/github.com/gplusplus314/gkey_zmk"
	fi
fi
if [ ! -d "$ZMK_CONFIG" ]; then
	echo "$ZMK_CONFIG"
	echo "ZMK_CONFIG directory does not exist"
	exit 1
fi

if [ -z "$ZMK_BOARD" ]; then
	ZMK_BOARD="nice_nano_v2"
fi

if [ -z "$ZMK_SHIELD" ]; then
	ZMK_SHIELD="gkey_vibraphone"
fi

case "$ZMK_SHIELD" in
	gkey_vibraphone)
		ZMK_SPLIT="y"
		;;
	*)
		ZMK_SPLIT="n"
		;;
esac

if [ -z "$VIRTUAL_ENV" ]; then
	pushd $ZEPHYR_BASE/..
	source .venv/bin/activate
	popd
fi

doBuild() {
	pushd $ZEPHYR_BASE/../app
	if [ "$ZMK_RESET" = "y" ]; then
		DSHIELD="settings_reset"
	else
		DSHIELD="${ZMK_SHIELD}_${ZMK_SPLIT_SIDE}"
	fi
	# Add this option for USB logging:
	# -S zmk-usb-logging \
	west build \
		-p \
		-d build/$ZMK_SPLIT_SIDE \
		-b $ZMK_BOARD -- \
		-DSHIELD=${DSHIELD} \
		-DZMK_CONFIG=$ZMK_CONFIG
	popd
	./bin/flash.sh $ZMK_SHIELD $ZMK_SPLIT_SIDE
}

if [ "$ZMK_SPLIT" = "y" ] || [ "$ZMK_RESET" = "y" ]; then
	if [[ "$ZMK_SPLIT_SIDE" == "both" ]]; then
		ZMK_SPLIT_SIDE="right"
		doBuild
		ZMK_SPLIT_SIDE="left"
	fi
	doBuild
else
	echo "Non-split keyboard, but I don't own one. So... huh?"
	exit 1
fi