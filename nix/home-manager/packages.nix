{
  pkgs,
  claude-code-nix,
  system,
  ...
}:
{
  home.packages = with pkgs; [
    nixd
    claude-code-nix.packages.${system}.claude-code
  ];
}
