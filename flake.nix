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

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # UI/UX 設計用の Claude Code / Codex skill。
    # flake ではないリポジトリなので flake = false で生ソースとして取得し、
    # ui-ux-pro-max.nix が各 skill dir へ配布する。
    ui-ux-pro-max-skill = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
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
      codex-cli-nix,
      nixvim,
      ui-ux-pro-max-skill,
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
            codex-cli-nix
            nixvim
            ui-ux-pro-max-skill
            system
            ;
        };
      };
    };
}
