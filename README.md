# Gerry's ZMK Keyboards

At this time, I don't really intend on other people using my bespoke keyboard,
so I don't have much of a README. But here are some notes for my future self
before I forget how to use this repo again (because it has happened):

You need [Nix](https://nixos.org/download/) with flakes enabled. Then:

```sh
git clone https://github.com/gplusplus314/gkey_zmk.git
cd gkey_zmk
nix run .#flash -- left    # build + flash left half
nix run .#flash -- right   # right half
nix run .#flash            # both halves, in sequence
nix run .#flash-reset      # clear ZMK settings (prompts to confirm)
nix run .#update           # bump the pinned ZMK / Zephyr / HAL versions
```

Flashing is Linux-only (zmk-nix uses udisks). On macOS, do a `nix build
.#firmware` and copy the `.uf2` file to the bootloader by hand.
