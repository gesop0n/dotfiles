{ lib, ... }:
{
  home.file.".claude/settings.json" = {
    force = true;
    text = builtins.toJSON {
      effortLevel = "high";
      theme = "dark";
      enabledPlugins = {
        "gopls-lsp@claude-plugins-official" = true;
      };
      mcpServers = {
        codegraph = {
          type = "stdio";
          command = "/Users/gesopon/.local/share/mise/shims/codegraph";
          args = [ "serve" "--mcp" ];
        };
      };
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
  };
}
