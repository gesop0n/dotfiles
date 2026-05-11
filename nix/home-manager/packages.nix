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

    # LazyVim dependencies
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
