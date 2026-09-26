{ pkgs, inputs, ... }:
let
  # git-gtr は nixpkgs に無いので、flake input で pin したソースから組み立てる。
  # 中身は bash スクリプト群で、bin/git-gtr が symlink を辿って
  # 自身の置き場所 ($out) を GTR_DIR とし、$out/lib や $out/adapters を読む。
  # そのため Homebrew の formula と同じレイアウトで $out へ置けば動く。
  # 補完は `git gtr completion` が $out/share 以下を探すので、そこへ置く。
  git-gtr = pkgs.stdenvNoCC.mkDerivation {
    pname = "git-gtr";
    version = "2.11.1";
    src = inputs.git-worktree-runner;

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 -t $out/bin bin/git-gtr bin/gtr
      cp -r lib adapters $out/

      install -Dm644 completions/gtr.bash $out/share/bash-completion/completions/git-gtr
      install -Dm644 completions/_git-gtr $out/share/zsh/site-functions/_git-gtr
      install -Dm644 completions/git-gtr.fish $out/share/fish/vendor_completions.d/git-gtr.fish

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/git-gtr version | grep -F "$version"
    '';
  };
in
{
  home.packages = [ git-gtr ];

  # git-gtr のシェル統合。
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
