{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);

    src = nixpkgs.lib.sourceFilesBySuffices self [
      ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi"
      ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig"
    ];

    zephyrDepsHash = "sha256-WxYxNWBxm9zv5LFtr/l0AzudvKl3VtRadz75vcQxTwg=";
  in {
    packages = forAllSystems (system: let
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
    in rec {
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
      # underlying flasher in a y/N prompt so a stray `nix run` can't trigger
      # it accidentally.
      flash-reset = pkgs.writeShellApplication {
        name = "flash-reset";
        text = let
          inner = zmk-nix.packages.${system}.flash.override {
            firmware = firmware-reset;
          };
        in ''
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
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
