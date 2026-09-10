{ config, ... }:
let
  hooksDir = "${config.home.homeDirectory}/.config/git/hooks";

  # core.hooksPath を設定すると git はこのディレクトリしか見なくなり、
  # リポジトリ側の .git/hooks が動かなくなる。そのため git が呼びうるフック名を
  # すべて dispatch へリンクし、dispatch 側からリポジトリ固有のフックへ
  # 引き継ぐ。
  #
  # 除外しているもの:
  # - fsmonitor-watchman / push-to-checkout: 存在するだけで git の既定動作を
  #   置き換えてしまい、素通しの実装では壊れる
  # - pre-receive などサーバー側フック / p4-*: クライアントでは使わない
  hookNames = [
    "applypatch-msg"
    "pre-applypatch"
    "post-applypatch"
    "pre-commit"
    "pre-merge-commit"
    "prepare-commit-msg"
    "commit-msg"
    "post-commit"
    "pre-rebase"
    "post-checkout"
    "post-merge"
    "pre-push"
    "post-rewrite"
    "pre-auto-gc"
    "sendemail-validate"
    "post-index-change"
    "reference-transaction"
  ];

  hookFiles = builtins.listToAttrs (
    map (hook: {
      name = ".config/git/hooks/${hook}";
      value = {
        source = ../../.config/git/hooks/dispatch;
        executable = true;
      };
    }) hookNames
  );
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "gesop0n";
        email = "ishikuro6.2@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      core.hooksPath = hooksDir;
    };

    # NOTE: .gitconfig の includeIf の指定
    # github.com/⚪︎⚪︎ のフォルダでユーザーを自動的に切り替える.
    # https://www.reddit.com/r/NixOS/comments/1atp50v/generate_string_to_file_without_double_quotes_in/
    includes = [
      {
        condition = "gitdir:~/github.com/gesop0n/";
        path = "~/.gitconfig-gesop0n";
      }
      {
        condition = "gitdir:~/github.com/KotaIshikuro/";
        path = "~/.gitconfig-KotaIshikuro";
      }
    ];
  };

  home.file = hookFiles // {
    # includeIf で読み込む追加 gitconfig ファイルを生成
    ".gitconfig-gesop0n".text = ''
      [user]
        name = gesop0n
        email = ishikuro6.2@gmail.com
    '';

    ".gitconfig-KotaIshikuro".text = ''
      [user]
        name = KotaIshikuro
        email = 173035841+KotaIshikuro@users.noreply.github.com
    '';
  };
}
