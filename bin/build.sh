#!/usr/bin/env bash

set -e
GKEY_ZMK_DIR=$(dirname $(dirname $(realpath $0)))

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

if [ -z "$ZMK_REPO" ]; then
	ZMK_REPO="$HOME/src/github.com/zmkfirmware/zmk"
fi
if [ ! -d "$ZMK_REPO/app" ]; then
	echo "ZMK_REPO environment variable not a valid ZMK repo"
	exit 1
fi

ZEPHYR_SDK_VERSION=$(cat "$ZMK_REPO/zephyr/SDK_VERSION")
if [ ! -d "$HOME/.local/opt/zephyr-sdk-$ZEPHYR_SDK_VERSION" ]; then
	pushd "$GKEY_ZMK_DIR"
	./bin/init_zmk.sh
fi

if [ -z "$ZMK_EXTRA_MODULES" ]; then
	# If running in the ZMK VSCode container workspace...
	if [ -n "$VSCODE_IPC_HOOK_CLI" ]; then
		# Use the container volume.
		ZMK_EXTRA_MODULES="/workspaces/zmk-modules"
	else
		# Use my module
		ZMK_EXTRA_MODULES="$GKEY_ZMK_DIR"
	fi
fi
if [ ! -d "$ZMK_EXTRA_MODULES" ]; then
	echo "$ZMK_EXTRA_MODULES"
	echo "ZMK_EXTRA_MODULES directory does not exist"
	exit 1
fi

if [ -z "$ZMK_BOARD" ]; then
	# see https://zmk.dev/blog/2025/12/09/zephyr-4-1#board-revisions for an
	# explanation as to why this isn't nice_nano_v2 anymore.
	ZMK_BOARD="nice_nano"
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
	pushd $ZMK_REPO
	source .venv/bin/activate
	popd
fi

doBuild() {
	pushd $ZMK_REPO/app
	if [ "$ZMK_RESET" = "y" ]; then
		DSHIELD="settings_reset"
	else
		DSHIELD="${ZMK_SHIELD}_${ZMK_SPLIT_SIDE}"
	fi
	# Add this option for USB logging:
	# -S zmk-usb-logging \
	set -x
	west build \
		-p \
		-d build/$ZMK_SPLIT_SIDE \
		-b $ZMK_BOARD -- \
		-DSHIELD=${DSHIELD} \
		-DZMK_EXTRA_MODULES=$ZMK_EXTRA_MODULES
	set -x
	popd
	./bin/flash.sh $ZMK_SHIELD $ZMK_SPLIT_SIDE $ZMK_RESET
}

if [ "$ZMK_SPLIT" = "y" ] || [ "$ZMK_RESET" = "y" ]; then
	if [[ "$ZMK_SPLIT_SIDE" == "both" ]]; then
		ZMK_SPLIT_SIDE="right"
		doBuild
		ZMK_SPLIT_SIDE="left"
	fi
	doBuild
else
	echo "Unexpected configuration: non-split keyboard"
	exit 1
fi
