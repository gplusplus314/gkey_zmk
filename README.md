# Gerry's ZMK Keyboards

At this time, I don't really intend on other people using my bespoke keyboard,
so I don't have much of a README. But here are some notes for my future self
before I forget how to use this repo again (because it has happened):

First, set up [gdot dotfiles](https://github.com/gplusplus314/gdot). Then:

```sh
gclone https://github.com/gplusplus314/gkey_zmk.git
cd ~/src/github.com/gplusplus314/gkey_zmk/
cd gkey_zmk
./bin/build.sh
```

It will automagically set up the [Zephyr
SDK](https://docs.zephyrproject.org/latest/develop/toolchains/zephyr_sdk.html)
and the [ZMK Firmwary Repository](https://github.com/zmkfirmware/zmk) along with
a local, native toolchain. By default, with no arguments, `./bin/build.sh`
builds and flashes the left-side split of my `vibraphone` keyboard.
