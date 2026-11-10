{
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  grok = inputs.grok-build-nix.packages.${system}.grok;

  # MCP サーバーは PATH を絞られた状態で起動されうるので、command は絶対パスで指定する
  # (nix/home-manager/claude.nix と .config/.codex/config.toml も同じパスを指している)。
  managedMcpServers = {
    # codegraph : コードベースの symbol / 呼び出し関係を SQLite の知識グラフとして引く。
    # 実体は mise 管理の npm パッケージ (mise.nix の tools."npm:@colbymchenry/codegraph")。
    codegraph = {
      command = "/Users/gesopon/.local/share/mise/installs/npm-colbymchenry-codegraph/latest/bin/codegraph";
      args = [
        "serve"
        "--mcp"
      ];
    };
    # plamo-translate : PFN の PLaMo で訳す (mise.nix の tools."pypi:plamo-translate")。
    # `plamo-translate server` が localhost:30000 で立てる streamable HTTP のサーバーに
    # つなぐだけなので、サーバーは別に起動しておく。
    plamo-translate = {
      url = "http://localhost:30000/mcp";
    };
  };

  # ~/.grok/config.toml に深いマージで重ねる値 (claude.nix の managedSettings に相当)。
  # MCP 以外で grok に CLI の設定手段が無いものをここに書く。
  managedConfig = {
    # 組み込みモデルの context window を 500K にする。
    #
    # grok-4.7 はサーバーから 256000 と 500000 の 2 つの窓が配られ、既定は 256000。
    # auto-compact はこの窓の auto_compact_threshold_percent (grok-4.7 は 80%) で走るので、
    # 既定のままだと約 205K トークンで会話が圧縮される。500000 にすると約 400K まで伸びる
    # (512K という選択肢は無い)。
    #
    # TUI の `/context-window 500k` でも切り替えられるが、そのセッション限りなので
    # 新しいセッションの既定値として config に書いておく。
    # 効いているかは新しいセッションで `/context` か `/session-info` の総トークン数で分かる。
    # 窓を広げた分、長いセッションでは 1 リクエストあたりの入力トークンと料金が増える。
    model."grok-4.7" = {
      context_window = 500000;
    };
  };

  # tomllib (読み) は標準ライブラリだが、書き出しには tomli_w が要る。
  python = pkgs.python3.withPackages (ps: [ ps.tomli-w ]);
in
{
  # Grok Build の user-scope MCP サーバーを ~/.grok/config.toml の [mcp_servers.*] に反映する。
  #
  # ~/.grok/config.toml は grok 自身が [marketplace] や [ui] を書き込む実ファイルなので、
  # home.file で symlink にはできない。また grok の宣言的レイヤーは MCP に使えない:
  #   - GROK_CONFIG_PATH の overlay は allowlist 外の [mcp_servers] を捨てる
  #   - $GROK_HOME/managed_config.toml は console 同期で上書きされうる
  # そこで `grok mcp add` (同名があれば更新する) で該当テーブルだけを書き換える。
  #
  # なお grok は ~/.claude.json も互換ソースとして読むので claude.nix 側の設定でも
  # 見えはするが、[compat.claude] mcps に依存しないよう grok ネイティブにも登録する
  # (同名の場合は config.toml 側が優先される)。
  home.activation.grokMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatStrings (
      lib.mapAttrsToList (
        name: server:
        let
          # url があれば streamable HTTP、無ければ stdio のサーバーとして登録する。
          target =
            if server ? url then
              "--transport http ${lib.escapeShellArg name} ${lib.escapeShellArg server.url}"
            else
              "${lib.escapeShellArg name} -- ${lib.escapeShellArgs ([ server.command ] ++ server.args)}";
        in
        ''
          ${grok}/bin/grok mcp add --scope user ${target} > /dev/null \
            || echo "grok: MCP サーバー ${name} の登録に失敗した"
        ''
      ) managedMcpServers
    )
  );

  # managedConfig を ~/.grok/config.toml に重ねる。
  #
  # codex/ と違ってベースを丸ごと持たないのは、grok の config.toml がほぼ grok 自身の
  # 書き込み ([marketplace]、[ui]、`grok mcp add` の結果) で出来ていて、dotfiles 側で
  # 持ちたい値が数個しか無いため。既存の内容は全部残し、管理する値だけ上書きする。
  # 既存ファイルが壊れていたら触らずにメッセージだけ出して先へ進む (codex/ と同じ方針)。
  # grokMcp の後に走らせて、同じファイルへの書き込みを直列にする。
  home.activation.grokConfig = lib.hm.dag.entryAfter [ "writeBoundary" "grokMcp" ] ''
    ${python}/bin/python3 ${./config-merge.py} "$HOME/.grok/config.toml" \
      ${lib.escapeShellArg (builtins.toJSON managedConfig)} \
      || echo "grok: ~/.grok/config.toml の更新に失敗した (上のメッセージを参照)"
  '';
}
