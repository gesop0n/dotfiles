{ ... }:
{
  # git-gtr (Homebrew の coderabbitai/tap/git-gtr) のシェル統合。
  #
  # `gtr cd <branch>` / `gtr new <branch> --cd` / `gtr pr <number> --cd` は
  # シェル自身のカレントディレクトリを移動するため、シェル関数として
  # 定義されていないと動かない。あわせて gtr 用の補完も入る。
  #
  # `eval "$(git gtr init zsh)"` を直接書くとシェル起動ごとに ~60ms かかるので、
  # 公式推奨どおり ~/.cache/gtr/init-gtr.zsh を source する形にする。
  # キャッシュが無い、または init のフォーマット版数が変わったとき
  # (先頭行の `init=6`) だけ生成し直す。
  # git-gtr 未インストール時は `|| true` で黙って何もしない。
  programs.zsh.initContent = ''
    _gtr_init="''${XDG_CACHE_HOME:-$HOME/.cache}/gtr/init-gtr.zsh"
    [[ -f "$_gtr_init" ]] && head -n 1 "$_gtr_init" | grep -q ' init=6 ' || eval "$(git gtr init zsh)" || true
    source "$_gtr_init" 2>/dev/null || true
    unset _gtr_init
  '';
}
