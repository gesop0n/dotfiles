{
  pkgs,
  inputs,
  system,
  ...
}:
let
  # jacopone/antigravity-nix の agy は公式バイナリを置くだけで、自己更新を止めていない。
  # store は read-only なので cask 版 (antigravity-cli) と同じく AGY_CLI_DISABLE_AUTO_UPDATE で止め、
  # 更新は `nix flake update antigravity-nix` に任せる (grok / codex のラッパーと同じ扱い)。
  # wrapProgram だと実プロセス名が .agy-wrapped になり herdr のエージェント判定から外れうるため、
  # 元の bin/agy を直接 exec するラッパーを makeWrapper で作る。
  agy =
    let
      unwrapped = inputs.antigravity-nix.packages.${system}.google-antigravity-cli;
    in
    pkgs.runCommand "agy-${unwrapped.version}"
      {
        nativeBuildInputs = [ pkgs.makeWrapper ];
        inherit (unwrapped) meta;
      }
      ''
        makeWrapper ${unwrapped}/bin/agy $out/bin/agy --set AGY_CLI_DISABLE_AUTO_UPDATE true
      '';
in
{
  home.packages = with pkgs; [
    # CLI Tools
    eza
    ripgrep
    fd
    fzf # git-gtr の `gtr cd` 引数なし時のコマンドパレットに必要
    inputs.envdiff.packages.${system}.default # .env 系ファイルを値を出さずにキー単位で比べる (自作)
    inputs.neondburl.packages.${system}.default # .env 系ファイルの DATABASE_URL の Neon endpoint を差し替える (自作)

    # Development Tools
    gh
    nixd
    d2
    ccusage
    actionlint # GitHub Actions の workflow を検査する (run: 内のシェルは wrapProgram で同梱の shellcheck が見る)

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
    inputs.claude-code-nix.packages.${system}.claude-code
    inputs.codex-cli-nix.packages.${system}.codex # OpenAI Codex CLI (native Rust, 毎時自動更新)
    inputs.grok-build-nix.packages.${system}.grok # xAI Grok Build (公式リリースバイナリを pin, 毎時自動更新)
    agy # Google Antigravity CLI (jacopone/antigravity-nix, 毎日自動更新)

    # Cloud / Network
    # google-cloud-sdk: コンポーネントを追加する場合は以下のように記述する
    # (pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin bq ]))
    google-cloud-sdk
    google-cloud-sql-proxy # Cloud SQL への接続 (バイナリ名は cloud-sql-proxy)
    postgresql_17 # psql クライアント
    redis # redis-server / redis-cli (ローカル開発用)
    ngrok # ローカルサーバーの外部公開トンネル
    firebase-tools
    gws # Google Workspace CLI (Drive / Gmail / Calendar / Sheets など)

  ];
}
