{ ... }:
{
  imports = [
    ./packages.nix
    ./aliases.nix
    ./git.nix
    ./nixvim
    ./zsh.nix
    ./oh-my-posh.nix
    ./wezterm.nix
    ./mise.nix
    ./uv.nix
    ./hammerspoon.nix
    ./direnv.nix
    ./lazygit.nix
    ./claude.nix
    ./zed.nix
  ];

  home.username = "gesopon";
  home.homeDirectory = "/Users/gesopon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
