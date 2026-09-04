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
      env = { };
    };
  };

  managedPlugins = {
    "gopls-lsp@claude-plugins-official" = true;
    "rust-analyzer-lsp@claude-plugins-official" = true;
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
  # スキルは Claude が読むだけ（書き込まない）ので、settings.json と違い
  # nixストアへのシンボリックリンク（home.file）で配ってよい。
  # CLAUDE_CONFIG_DIR 未設定時(~/.claude)と各アカウント dir の両方に同じスキルを配る。
  # recursive = true で各ファイルを個別にリンクし、手動追加スキルとも共存できるようにする。
  home.file = builtins.listToAttrs (
    map
      (root: {
        name = "${root}/skills";
        value = {
          source = ../../.config/claude/skills;
          recursive = true;
        };
      })
      [
        ".claude"
        ".claude-config/gesop0n"
        ".claude-config/KotaIshikuro"
      ]
  );

  # settings.json / .claude.json で home.file ではなく home.activation を使う理由:
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

  # permissions と MCP サーバーを各設定ディレクトリに反映する。
  # user-scope MCP は設定ディレクトリごとの .claude.json の mcpServers キーに保存される。
  #
  # settings.json はアカウント dir のみを対象にする（デフォルトの
  # ~/.claude/settings.json は上の claudeSettings が担当）。
  # 一方 MCP は CLAUDE_CONFIG_DIR 未設定時に ~/.claude.json が読まれるため、
  # デフォルト($HOME)とアカウント dir の両方へ配る必要がある。
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
      if [ -d "$ACCOUNT_DIR" ]; then
        _apply_account_settings "$ACCOUNT_DIR/settings.json"
      fi
    done

    for CONFIG_ROOT in "$HOME" "$HOME/.claude-config/gesop0n" "$HOME/.claude-config/KotaIshikuro"; do
      if [ -d "$CONFIG_ROOT" ]; then
        _apply_account_mcp "$CONFIG_ROOT/.claude.json"
      fi
    done
  '';
}
