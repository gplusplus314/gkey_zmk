#!/usr/bin/env bash

ZMK_SHIELD="${1:-gkey_vibraphone}"
ZMK_SPLIT_SIDE="${2:-left}"

case "$ZMK_SHIELD" in
"gkey_vibraphone")
	MOUNT_NAME="NICENANO"
	;;
*)
	echo "unsupported shield: $ZMK_SHIELD"
	exit 1
	;;
esac

if [ -z "$ZEPHYR_BASE" ]; then
	ZEPHYR_BASE="$HOME/src/github.com/zmkfirmware/zmk/zephyr"
fi
if [ ! -d "$ZEPHYR_BASE/../app" ]; then
	echo "ZEPHYR_BASE environment variable not a valid ZMK repo"
	exit 1
fi

os=$(uname)
if [[ "$os" == "Darwin" ]]; then
	MOUNT_POINT="/Volumes/$MOUNT_NAME"
else
	echo "Unsupported OS: $os"
	exit 1
fi

until [ -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be mounted..."
done
echo "Flashing..."

UF2_PATH="$ZEPHYR_BASE/../app/build/$ZMK_SPLIT_SIDE/zephyr/zmk.uf2"
if [ ! -f "$UF2_PATH" ]; then
	echo "UF2 file not found: $UF2_PATH"
	exit 1
fi

cp "$UF2_PATH" "$MOUNT_POINT"

until [ ! -d "$MOUNT_POINT" ]; do
	sleep 1
	echo "Waiting for $MOUNT_POINT to be unmounted..."
done

echo "Done flashing!"