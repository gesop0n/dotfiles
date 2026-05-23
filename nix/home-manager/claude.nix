{ lib, pkgs, ... }:
let
  managedMcpServers = {
    codegraph = {
      type = "stdio";
      command = "/Users/gesopon/.local/share/mise/shims/codegraph";
      args = [ "serve" "--mcp" ];
      env = { };
    };
  };

  managedPlugins = {
    "gopls-lsp@claude-plugins-official" = true;
  };

  initialSettings = {
    effortLevel = "high";
    theme = "dark";
    enabledPlugins = managedPlugins;
    permissions = {
      allow = [
        "mcp__codegraph__codegraph_search"
        "mcp__codegraph__codegraph_context"
        "mcp__codegraph__codegraph_callers"
        "mcp__codegraph__codegraph_callees"
        "mcp__codegraph__codegraph_impact"
        "mcp__codegraph__codegraph_node"
        "mcp__codegraph__codegraph_status"
        "mcp__codegraph__codegraph_files"
      ];
    };
  };
in
{
  # Claude Code 2.x の設定ファイルの役割:
  # - ~/.claude/settings.json : theme, effortLevel, enabledPlugins, permissions
  # - ~/.claude.json          : user-scope MCP サーバー (mcpServers キー)
  #
  # home.file ではなく home.activation を使う理由:
  # home.file は nixストアへのシンボリックリンクを作成する（読み取り専用）。
  # Claude Code はこれらのファイルに書き込むため、通常ファイルである必要がある。

  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="$HOME/.claude/settings.json"
    mkdir -p "$HOME/.claude"

    # 以前の home.file が作ったシンボリックリンクを削除
    [ -L "$SETTINGS_FILE" ] && rm "$SETTINGS_FILE"

    if [ ! -f "$SETTINGS_FILE" ]; then
      printf '%s\n' '${builtins.toJSON initialSettings}' > "$SETTINGS_FILE"
    else
      ${pkgs.jq}/bin/jq '. * {
        "enabledPlugins": ((.enabledPlugins // {}) + ${builtins.toJSON managedPlugins})
      }' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
        && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    fi
  '';

  # user-scope MCP は ~/.claude.json の mcpServers キーに保存される
  home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_JSON="$HOME/.claude.json"

    if [ ! -f "$CLAUDE_JSON" ]; then
      printf '%s\n' '${builtins.toJSON { mcpServers = managedMcpServers; }}' > "$CLAUDE_JSON"
    else
      ${pkgs.jq}/bin/jq '.mcpServers = ((.mcpServers // {}) + ${builtins.toJSON managedMcpServers})' \
        "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
        && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
    fi
  '';
}
