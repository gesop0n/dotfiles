{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      claude-code-nix,
    }:
    let
      system = "aarch64-darwin";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      darwinConfigurations = {
        "Kotas-MacBook-Pro" = import ./nix/darwin/default.nix {
          inherit
            self
            nix-darwin
            home-manager
            nix-homebrew
            claude-code-nix
            system
            ;
        };
      };
    };
}
