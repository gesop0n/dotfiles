{
  pkgs,
  claude-code-nix,
  codex-cli-nix,
  grok-build-nix,
  system,
  ...
}:
{
  home.packages = with pkgs; [
    # CLI Tools
    eza
    ripgrep
    fd
    fzf # git-gtr の `gtr cd` 引数なし時のコマンドパレットに必要

    # Development Tools
    gh
    nixd
    d2

    # Claude Code / Codex は python を同梱せず PATH の python3 を spawn する
    # (ui-ux-pro-max のような skill 同梱スクリプトがこれを使う)。
    # 宣言しないと Command Line Tools の /usr/bin/python3 (3.9系, EOL) に
    # 暗黙依存するので、nix profile 側で実体を固定する。
    python3
    # nix の python3 には pip install できない (store が read-only)。
    # 3rd-party 依存のあるスクリプト用の逃げ道として入れておく
    # (uv run --with ... / PEP 723 inline metadata)。
    uv

    # AI Agents
    claude-code-nix.packages.${system}.claude-code
    codex-cli-nix.packages.${system}.codex # OpenAI Codex CLI (native Rust, 毎時自動更新)
    grok-build-nix.packages.${system}.grok # xAI Grok Build (公式リリースバイナリを pin, 毎時自動更新)

    # Cloud / Network
    # google-cloud-sdk: コンポーネントを追加する場合は以下のように記述する
    # (pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin bq ]))
    google-cloud-sdk
    google-cloud-sql-proxy # Cloud SQL への接続 (バイナリ名は cloud-sql-proxy)
    postgresql_17 # psql クライアント
    redis # redis-server / redis-cli (ローカル開発用)
    ngrok # ローカルサーバーの外部公開トンネル
    firebase-tools

  ];
}
