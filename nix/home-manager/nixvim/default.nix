{ pkgs, ... }:
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

    # ホスト (システム) の pkgs インスタンスを再利用する。
    # これにより nixvim が独自に nixpkgs を import しなくなり、
    # follows による nixpkgs revision のずれ警告が出なくなる。
    nixpkgs.pkgs = pkgs;
  };
}
