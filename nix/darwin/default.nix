{
  self,
  nix-darwin,
  home-manager,
  nix-homebrew,
  claude-code-nix,
  system,
}:
nix-darwin.lib.darwinSystem {
  inherit system;
  specialArgs = { inherit self system; };

  modules = [
    ./system.nix

    home-manager.darwinModules.home-manager
    {
      # NOTE: Unable to build flake without home.homeDirectory error
      # https://github.com/nix-community/home-manager/issues/6036
      users.users.gesopon.home = "/Users/gesopon";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit claude-code-nix system; };
      home-manager.users.gesopon = import ../home-manager/default.nix;
    }

    nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
  ];
}
