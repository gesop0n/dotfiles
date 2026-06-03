# NOTE: programs.zsh
# https://mynixos.com/nixpkgs/options/programs.zsh
{ ... }:
{
  programs.zsh = {
    enable = true;

    # Homebrew を PATH に通す（従来 ~/.zprofile に手書きしていた内容）。
    # home-manager が ~/.zprofile を管理するようになったためここへ移動。
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

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
