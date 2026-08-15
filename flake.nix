{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zmk-nix,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);

      src = nixpkgs.lib.sourceFilesBySuffices self [
        ".board"
        ".cmake"
        ".conf"
        ".defconfig"
        ".dts"
        ".dtsi"
        ".json"
        ".keymap"
        ".overlay"
        ".shield"
        ".yml"
        "_defconfig"
      ];

      zephyrDepsHash = "sha256-WxYxNWBxm9zv5LFtr/l0AzudvKl3VtRadz75vcQxTwg=";
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zmkLib = zmk-nix.legacyPackages.${system};

          # Shared west-update FOD so firmware + firmware-reset reuse a single
          # fetch. Without this they'd produce two store paths with identical
          # content under different names.
          westDeps = zmkLib.fetchZephyrDeps {
            name = "gkey_vibraphone-west-deps";
            inherit src;
            westRoot = "config";
            hash = zephyrDepsHash;
          };
        in
        rec {
          default = firmware;

          firmware = zmkLib.buildSplitKeyboard {
            name = "gkey_vibraphone";
            inherit src westDeps zephyrDepsHash;

            board = "nice_nano";
            shield = "gkey_vibraphone_%PART%";

            meta = {
              description = "gkey_vibraphone ZMK firmware";
              license = nixpkgs.lib.licenses.mit;
              platforms = nixpkgs.lib.platforms.all;
            };
          };

          firmware-reset = zmkLib.buildKeyboard {
            name = "gkey_vibraphone-settings-reset";
            inherit src westDeps zephyrDepsHash;

            board = "nice_nano";
            shield = "settings_reset";

            meta = {
              description = "ZMK settings_reset firmware for nice_nano";
              license = nixpkgs.lib.licenses.mit;
              platforms = nixpkgs.lib.platforms.all;
            };
          };

          flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };

          # Settings reset is destructive (wipes BT pairings etc). Wrap the
          # underlying flasher in a y/N prompt so `nix run` can't trigger it
          # accidentally.
          flash-reset = pkgs.writeShellApplication {
            name = "flash-reset";
            text =
              let
                inner = zmk-nix.packages.${system}.flash.override {
                  firmware = firmware-reset;
                };
              in
              ''
                echo "This will clear ZMK settings (BT pairings, etc) on the side you plug in next."
                read -r -p "Continue? (y/N): " ans
                case "$ans" in
                  y|Y) ;;
                  *) echo "Canceled."; exit 1 ;;
                esac
                exec ${inner}/bin/zmk-uf2-flash "$@"
              '';
          };

          update = zmk-nix.packages.${system}.update;

          # Renders the keymap diagram
          keymap-image =
            pkgs.runCommand "gkey_vibraphone-keymap"
              {
                nativeBuildInputs = [
                  pkgs.keymap-drawer
                  pkgs.yq-go
                ];
                config = ./keymap_drawer.config.yaml;
                keymap = ./boards/shields/gkey_vibraphone/gkey_vibraphone.keymap;
                keyLayout = "33333+3>> 3<<+33333";
              }
              ''
                keymap -c "$config" parse -z "$keymap" --columns 10 -o keymap.yaml

                drawn="base nav/sym media-F macro settings game1 game2"
                hidden="template game-gate"

                parsed=$(yq -r '.layers | keys | .[]' keymap.yaml | sort)
                listed=$(printf '%s\n' $drawn $hidden | sort)
                if [ "$parsed" != "$listed" ]; then
                  echo "layer lists in flake.nix are out of date" >&2
                  echo "parsed: $parsed" >&2
                  echo "listed: $listed" >&2
                  exit 1
                fi

                json=$(printf '%s\n' $drawn | sed 's/.*/"&"/' | paste -sd, -)
                yq -i ".layers |= pick([$json])" keymap.yaml

                mkdir -p $out

                KEYMAP_dark_mode=false keymap -c "$config" draw \
                  -n "$keyLayout" keymap.yaml -o $out/keymap.svg
                KEYMAP_dark_mode=true keymap -c "$config" draw \
                  -n "$keyLayout" keymap.yaml -o $out/keymap-dark.svg
              '';

          diagram = pkgs.writeShellApplication {
            name = "diagram";
            runtimeInputs = [ pkgs.git ];
            text = ''
              root="$(git rev-parse --show-toplevel)"
              for svg in keymap.svg keymap-dark.svg; do
                install -Dm644 "${keymap-image}/$svg" "$root/img/$svg"
                echo "Wrote $root/img/$svg"
              done
            '';
          };
        }
      );

      devShells = forAllSystems (system: {
        default = zmk-nix.devShells.${system}.default.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
            nixpkgs.legacyPackages.${system}.keymap-drawer
          ];
        });
      });
    };
}
