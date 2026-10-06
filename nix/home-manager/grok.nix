{
  lib,
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
  };
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
      lib.mapAttrsToList (name: server: ''
        ${grok}/bin/grok mcp add --scope user ${lib.escapeShellArg name} -- \
          ${lib.escapeShellArgs ([ server.command ] ++ server.args)} > /dev/null \
          || echo "grok: MCP サーバー ${name} の登録に失敗した"
      '') managedMcpServers
    )
  );
}
