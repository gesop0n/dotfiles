{
  pkgs,
  claude-code-nix,
  system,
  ...
}:
{
  home.packages = with pkgs; [
    # Commands
    # ----------
    eza

    # LSPs
    # ----------
    nixd

    # Agents
    # ----------
    claude-code-nix.packages.${system}.claude-code
  ];
}
