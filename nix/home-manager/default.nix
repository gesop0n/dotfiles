# NOTE: https://nix-community.github.io/home-manager/index.xhtml#sec-usage-configuration
{ config, pkgs, ... }:
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gesopon";
  home.homeDirectory = "/Users/gesopon";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # git
  programs.git = {
    enable = true;
    userName = "gesop0n";
    userEmail = "ishikuro6.2@gmail.com";  # ← 変更してください
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
