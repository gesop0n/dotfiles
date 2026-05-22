{ ... }:
{
  programs.nixvim = {
    opts = {
      relativenumber = true;
      number = true;
      spell = false;
      signcolumn = "yes";
      wrap = false;
      exrc = true;
      secure = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };
  };
}
