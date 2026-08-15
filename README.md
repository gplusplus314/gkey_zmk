# Gerry's Keyboards

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

![](./img/vibraphonePhoto.png)

It's called Vibraphone because:
- I'm a percussionist. 🥁
- A vibraphone is a *keyboard instrument*.
- It has fewer keys than a marimba.
- It is flat, unlike a marimba.

The Vibraphone is my daily driver keyboard and also acts as my core, reference
keymap. It runs on ZMK firmware and is a no-nonsense, serious keyboard,
heavily customized for my keyboard-centric workflow. All of my other keyboards
use the Vibraphone keymap as their base layer.

The PCB was designed by [Cyboard](https://www.cyboard.digital/) based on scans
of my hands and several iterations of printed mockups. The PCB features zero
diodes and hard-soldered keys for maximum durability. It can be thrown caseless
into a bag without any worry. The reset buttons and power toggle switches are
guarded by the PCB to reduce accidental operation, too.

One neat thing about this design is the non-uniform spacing. This is to minimize
movement effort without cramping fingers too close to each other. Horizontally,
keys are spaced apart to separate each finger, other than the index finger
clusters. Otherwise, the keys are as close to each other as possible. The net
effect is that I can type without moving my hands; only my digits move.

The combination of PCB layout and keymap completely eliminates tucking a thumb
under my palm while typing. That is a painful movement for me, so eliminating
it was a design goal.

The Vibraphone keymap is actually for 34 keys. The two extra thumb keys are
intentionally out of the way and are only used for gaming layers. That said,
gaming is a non-goal with the Vibraphone. There will eventually be a revision
that eliminates these keys.

The Vibraphone is actually based on another custom keyboard I no longer use: the
Marimba. It's almost identical, except the Marima was a bit larger, had more
keys, and wasn't flat.

#### Goals
- Purple: the best color
- Minimal, low effort movement
- Portable
- Durable: designed for rough wear and tear
- Fits on top of a laptop keyboard
- Wireless (Bluetooth)
- Support multiple devices concurrently (up to 5)
- Optional support for wired interface over USB-C
- No thumb tucking while typing normally

#### Keymap

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="img/keymap-dark.svg">
  <img alt="gkey_vibraphone keymap" src="img/keymap.svg">
</picture>
