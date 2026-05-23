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
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
    };

    autoGroups.FileTypeIndent.clear = true;
    autoCmd = [
      {
        event = "FileType";
        pattern = "go";
        group = "FileTypeIndent";
        command = "setlocal tabstop=4 shiftwidth=4 noexpandtab";
      }
    ];

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
