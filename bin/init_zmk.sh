#!/usr/bin/env bash

set -e
set -x

if [ -z "$ZMK_REPO" ]; then
	ZMK_REPO="$HOME/src/github.com/zmkfirmware/zmk"
fi

if [ ! -d "$ZMK_REPO/.git" ]; then
	mkdir -p $(dirname "$ZMK_REPO")
	cd $(dirname "$ZMK_REPO")
	pwd
	rm -rf zmk
	git clone https://github.com/zmkfirmware/zmk.git
	cd zmk
	pwd
	python3 -m venv .venv
	source .venv/bin/activate
	pip install west
	west init -l app/
	west update
	west zephyr-export
	pip install -r zephyr/scripts/requirements-base.txt
fi

if [[ -z "$VIRTUAL_ENV" ]]; then
	cd "$ZMK_REPO"
	source .venv/bin/activate
fi

ZEPHYR_VERSION=$(cat "$ZMK_REPO/zephyr/SDK_VERSION")
ZEPHYR_ARCH=$(uname -m)
OS=$(uname -s)
OS=${OS,,} # to lowercase
case "$OS" in
darwin)
	OS="macos"
	;;
*) ;;
esac
ZEPHYR_OS="$OS"
ZEPHYR_SDK_DIR="$HOME/.local/opt/${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}"

if [ ! -d "$ZEPHYR_SDK_DIR" ]; then
	cd ~
	mkdir -p "$HOME/.local/opt"
	cd "$HOME/.local/opt"
	wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_VERSION}/zephyr-sdk-${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}.tar.xz
	wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_VERSION}/sha256.sum | shasum --check --ignore-missing
	tar xvf zephyr-sdk-${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}.tar.xz
	rm zephyr-sdk-${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}.tar.xz
fi
