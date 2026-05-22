{ ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./plugins/lsp.nix
    ./plugins/ui.nix
    ./plugins/editor.nix
    ./plugins/git.nix
    ./plugins/explorer.nix
    ./plugins/terminal.nix
    ./plugins/custom.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };
}
