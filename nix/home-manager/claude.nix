{ lib, pkgs, ... }:
let
  managedMcpServers = {
    codegraph = {
      type = "stdio";
      command = "/Users/gesopon/.local/share/mise/installs/npm-colbymchenry-codegraph/latest/bin/codegraph";
      args = [
        "serve"
        "--mcp"
      ];
      env = { };
    };
    context7 = {
      type = "stdio";
      command = "npx";
      args = [
        "-y"
        "@upstash/context7-mcp"
      ];
      env = {};
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
        "mcp__codegraph__codegraph_explore"
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

  # アカウント別設定ディレクトリに permissions と MCP サーバーを反映する
  # user-scope MCP は ~/.claude-config/<account>/.claude.json の mcpServers キーに保存される
  home.activation.claudeAccountSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _apply_account_settings() {
      local SETTINGS_FILE="$1"
      [ -L "$SETTINGS_FILE" ] && rm "$SETTINGS_FILE"
      if [ ! -f "$SETTINGS_FILE" ]; then
        printf '%s\n' '${
          builtins.toJSON {
            permissions = initialSettings.permissions;
          }
        }' > "$SETTINGS_FILE"
      else
        ${pkgs.jq}/bin/jq \
          --argjson perms '${builtins.toJSON initialSettings.permissions}' \
          '.permissions = ((.permissions // {}) + $perms)' \
          "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
          && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
      fi
    }

    _apply_account_mcp() {
      local CLAUDE_JSON="$1"
      if [ ! -f "$CLAUDE_JSON" ]; then
        printf '%s\n' '${builtins.toJSON { mcpServers = managedMcpServers; }}' > "$CLAUDE_JSON"
      else
        ${pkgs.jq}/bin/jq '.mcpServers = ((.mcpServers // {}) + ${builtins.toJSON managedMcpServers})' \
          "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" \
          && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      fi
    }

    for ACCOUNT_DIR in "$HOME/.claude-config/gesop0n" "$HOME/.claude-config/KotaIshikuro"; do
      [ -d "$ACCOUNT_DIR" ] && _apply_account_settings "$ACCOUNT_DIR/settings.json"
      [ -d "$ACCOUNT_DIR" ] && _apply_account_mcp "$ACCOUNT_DIR/.claude.json"
    done
  '';
}
