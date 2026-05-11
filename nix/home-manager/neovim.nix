{ config, lib, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ln -sfn "${config.home.homeDirectory}/dotfiles/nvim" "${config.xdg.configHome}/nvim"
  '';
}
