{ self, nix-darwin, home-manager, nix-homebrew }:
nix-darwin.lib.darwinSystem {
  modules = [
    ({ pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [ pkgs.vim ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    })

    # Home Manager module for darwin.
    home-manager.darwinModules.home-manager
    {
      # NOTE: Unable to build flake without home.homeDirectory error
      # https://github.com/nix-community/home-manager/issues/6036
      users.users.gesopon.home = "/Users/gesopon";

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.gesopon = import ../home-manager/default.nix;
    }

    nix-homebrew.darwinModules.nix-homebrew
    ./homebrew.nix
  ];
}
