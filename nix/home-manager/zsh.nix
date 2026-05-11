# NOTE: programs.zsh
# https://mynixos.com/nixpkgs/options/programs.zsh
{ ... }:
{
  programs.zsh = {
    enable = true;

    # Syntax highlighting
    # https://mynixos.com/nixpkgs/options/programs.zsh.syntaxHighlighting
    syntaxHighlighting = {
      enable = true;
    };

    # autosuggestion
    # https://mynixos.com/nixpkgs/options/programs.zsh.autosuggestion
    autosuggestion = {
      enable = true;
      highlight = "fg=#666666";
    };
  };
}
