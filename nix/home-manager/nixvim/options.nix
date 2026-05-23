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
      clipboard = "unnamedplus";
    };

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha"; # latte / frappe / macchiato / mocha
    };
  };
}
