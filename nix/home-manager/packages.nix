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

    # AstroNvim dependencies
    # ----------
    ripgrep
    fd
    lazygit
    tree-sitter

    # LSPs
    # ----------
    nixd

    # Agents
    # ----------
    claude-code-nix.packages.${system}.claude-code
  ];
}
