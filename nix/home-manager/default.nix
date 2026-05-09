{ ... }:
{
  imports = [
    ./packages.nix
    ./aliases.nix
    ./git.nix
    ./neovim.nix
    ./zsh.nix
    ./wezterm.nix
    ./mise.nix
  ];

  home.username = "gesopon";
  home.homeDirectory = "/Users/gesopon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
