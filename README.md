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
nix run .#diagram          # redraw the keymap images below
```

Flashing is Linux-only (zmk-nix uses udisks). On macOS, do a `nix build
.#firmware` and copy the `.uf2` file to the bootloader by hand.

## Vibraphone

My main keyboard is what I call the _Vibraphone_. It's flat and has fewer keys
than a marimba. Since I'm a percussionist, a keyboard percussion instrument is a
cool name.

The outer-most thumb keys (the ones labeled "macro" on the base layer) are
rarely used, intentionally out of the way, and don't have keycaps on the
physical keyboard.

Here's the keymap:

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="img/keymap-dark.svg">
  <img alt="gkey_vibraphone keymap" src="img/keymap.svg">
</picture>
