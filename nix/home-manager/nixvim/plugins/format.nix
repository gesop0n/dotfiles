{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        # biome / prettier / stylua は設定ファイルがあるプロジェクトでのみ使う
        # (require_cwd)。無いプロジェクトで既定スタイルに全面整形されるのを防ぐ。
        # どれも使えない場合や未指定の filetype (go, cpp など) は LSP で整形する。
        formatters_by_ft =
          let
            # biome 優先、無ければ prettier (どちらも node_modules/.bin を優先して探す)
            biomeOrPrettier = {
              __unkeyed-1 = "biome";
              __unkeyed-2 = "prettier";
              stop_after_first = true;
            };
          in
          {
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
            javascript = biomeOrPrettier;
            javascriptreact = biomeOrPrettier;
            typescript = biomeOrPrettier;
            typescriptreact = biomeOrPrettier;
            json = biomeOrPrettier;
            jsonc = biomeOrPrettier;
            css = biomeOrPrettier;
            html = [ "prettier" ];
            yaml = [ "prettier" ];
            markdown = [ "prettier" ];
          };
        formatters = {
          biome.require_cwd = true;
          prettier.require_cwd = true;
          stylua.require_cwd = true;
        };
        default_format_opts = {
          lsp_format = "fallback";
          timeout_ms = 3000;
        };
      };
    };

    extraConfigLua = ''
      -- format on save (Go は gopls で import 整理してから整形する)
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
          if vim.bo[args.buf].filetype == "go" then
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf, name = "gopls" })) do
              local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
              params.context = { only = { "source.organizeImports" } }
              local res = client:request_sync("textDocument/codeAction", params, 3000, args.buf)
              for _, r in pairs((res or {}).result or {}) do
                if r.edit then
                  vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
                end
              end
            end
          end
          require("conform").format({ bufnr = args.buf })
        end,
      })
    '';

    # biome / prettier はプロジェクトの node_modules のものを使うのでここには入れない
    extraPackages = with pkgs; [
      nixfmt
      stylua
    ];
  };
}
