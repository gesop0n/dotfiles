# システム全体 (全ユーザー共通) に入れるパッケージ
# 個人用ツールは home-manager/packages.nix へ
{ pkgs, ... }:
{
  environment.systemPackages = [ ];

  fonts.packages = with pkgs; [
    nerd-fonts.meslo-lg
  ];
}
