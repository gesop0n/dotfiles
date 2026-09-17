{
  lib,
  pkgs,
  ...
}:
let
  # codex が自分で書き込むテーブルのうち、マシン固有なので dotfiles に載せず、
  # かつ rebuild をまたいで残したいもの。
  #   [projects."<path>"] : ディレクトリを信頼したとき (絶対パスが入る)
  #   [tui.*]             : TUI の操作や NUX カウンタ
  # ここに無いテーブルを codex が書いていた場合は、捨てたことを警告する。
  localTables = [
    "projects"
    "tui"
  ];

  # ホーム側の実ファイルと区別するため、リポジトリ側は「ベース」として扱う。
  # 置き場所は ~/.codex をそのままミラーした .config/.codex のまま。
  baseConfig = ../../.config/.codex/config.toml;
in
{
  # Codex CLI (codex-cli) の設定。
  #
  # ~/.codex/config.toml を dotfiles の実ファイルへ symlink すると 2 つ問題が出る:
  #   1. codex が trust や TUI カウンタを追記するたびリポジトリに差分が出る。
  #      絶対パスを含むのでそのまま commit もできない。
  #   2. codex は設定マイグレーション時に config.toml を丸ごと書き直すことがある。
  #      実際 ~/.codex/config.toml.bak.20260916102856 は解説コメントが全部消えた
  #      693 バイトになっており、symlink のままだとベースごと失われていた。
  #
  # そこで ~/.codex/config.toml は git 管理外の実ファイルとし、activation のたびに
  # 「ベース + 既存ファイルから抜き出したマシン固有テーブル」で組み立て直す。
  # codex は好きに書き込めて、リポジトリは常にクリーンなまま保たれる。
  #
  # なお codex 側に宣言的設定を分離する仕組みは無い (実測):
  #   - $CODEX_HOME/managed_config.toml は読まれない (MDM のシステムパス専用)
  #   - <name>.config.toml プロファイルは `-p` 必須で、常時適用する環境変数が無い
  home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CODEX_CONFIG="$HOME/.codex/config.toml"
    mkdir -p "$HOME/.codex"

    # 以前の symlink 方式 (home.file / mkOutOfStoreSymlink) の名残を外す。
    # 実ファイルはそのまま残し、マシン固有テーブルの引き継ぎ元にする。
    if [ -L "$CODEX_CONFIG" ]; then
      rm "$CODEX_CONFIG"
    fi

    # 既存ファイルが壊れていると再生成を中止する。無関係な rebuild まで
    # 巻き込んで失敗させたくないので、メッセージだけ出して先へ進む。
    ${pkgs.python3}/bin/python3 ${./codex-config-merge.py} \
      ${baseConfig} "$CODEX_CONFIG" \
      --local ${lib.concatStringsSep "," localTables} \
      || echo "codex: ~/.codex/config.toml の再生成に失敗した (上のメッセージを参照)"
  '';
}
