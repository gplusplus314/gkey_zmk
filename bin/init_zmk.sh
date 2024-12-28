#!/usr/bin/env bash

set -e
set -x

ZEPHYR_VERSION='0.16.3'
ZEPHYR_ARCH='aarch64'
ZEPHYR_OS='macos'
ZEPHYR_SDK_DIR="$HOME/.local/opt/${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}"

if [ -z "$ZMK_ZEPHYR" ]; then
  ZMK_ZEPHYR="$HOME/src/github.com/zmkfirmware/zmk/zephyr"
fi

if [ ! -d "$ZMK_ZEPHYR/../.git" ]; then
  mkdir -p "$ZMK_ZEPHYR"
  cd "$ZMK_ZEPHYR/../.."
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
  cd "$ZMK_ZEPHYR/.."
  source .venv/bin/activate
fi

if [ ! -d "$ZEPHYR_SDK_DIR" ]; then
  cd ~
  mkdir -p "$HOME/.local/opt"
  cd "$HOME/.local/opt"
  wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_VERSION}/zephyr-sdk-${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}.tar.xz
  wget -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_VERSION}/sha256.sum | shasum --check --ignore-missing
  tar xvf zephyr-sdk-${ZEPHYR_VERSION}_${ZEPHYR_OS}-${ZEPHYR_ARCH}.tar.xz
fi
