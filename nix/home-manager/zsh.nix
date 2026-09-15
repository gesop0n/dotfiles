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

    # atcli の shell 統合（atcd / atcli cd / atcli new --cd）。
    # 関数の実体は atcli 側の `atcli init zsh` が出力する。
    # atcli は direnv 経由で atcoder リポジトリ内でしか PATH に乗らないため、
    # shell 起動時に eval はできない。初回呼び出し時に本物へ差し替える。
    initContent = ''
      _atcli_bootstrap() {
        local _atcli_init
        _atcli_init="$(command atcli init zsh)" || return
        unfunction atcli atcd _atcli_bootstrap 2>/dev/null
        eval "$_atcli_init"
      }
      atcli() { _atcli_bootstrap || return; atcli "$@"; }
      atcd()  { _atcli_bootstrap || return; atcd  "$@"; }
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
