# flake.nix から inputs を丸ごと受け取り、以降は specialArgs /
# extraSpecialArgs で各モジュールへ素通しする。
# input を1つ増やしても、この受け渡しの記述は変更不要。
{ inputs, system }:
inputs.nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit inputs system; };

  modules = [
    ./system.nix
    ./packages.nix
    ./defaults.nix

    inputs.home-manager.darwinModules.home-manager
    ./home-manager.nix

    inputs.nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
  ];
}
