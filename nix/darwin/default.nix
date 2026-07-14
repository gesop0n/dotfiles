{
  self,
  nix-darwin,
  home-manager,
  nix-homebrew,
  claude-code-nix,
  codex-cli-nix,
  nixvim,
  system,
}:
nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = {
    inherit
      self
      system
      claude-code-nix
      codex-cli-nix
      nixvim
      ;
  };

  modules = [
    ./system.nix
    ./packages.nix
    ./defaults.nix

    home-manager.darwinModules.home-manager
    ./home-manager.nix

    nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
  ];
}
