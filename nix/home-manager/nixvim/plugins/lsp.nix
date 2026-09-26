{ ... }:
{
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
          gopls.enable = true;
          clangd = {
            # プロジェクトの devShell が用意する clangd ラッパー
            # (--query-driver で g++ のシステム include を拾う) を優先したいので、
            # nixvim 側の clang-tools は PATH の末尾に置いてフォールバックにする。
            enable = true;
            packageFallback = true;
          };
          vtsls = {
            enable = true;
            packageFallback = true;
          };
        };

        # Neovim 0.12 の既定で入っていないものだけ足す。既定のキーマップ:
        #   K: hover / grn: rename / gra: code action / grr: references
        #   gri: implementation / grt: type definition / gO: document symbols
        #   grx: codelens / <C-s>(insert): signature help
        #   ]d [d: 次/前の診断 / <C-w>d: 診断をフロート表示
        keymaps.lspBuf = {
          gd = {
            action = "definition";
            desc = "Go to definition";
          };
          gD = {
            action = "declaration";
            desc = "Go to declaration";
          };
        };
      };

      cmp = {
        enable = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<C-n>" = "cmp.mapping.select_next_item()";
            "<C-p>" = "cmp.mapping.select_prev_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };
      luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      cmp_luasnip.enable = true;
    };

    highlight = {
      DiagnosticError = {
        fg = "#f38ba8";
      }; # red
      DiagnosticWarn = {
        fg = "#f9e2af";
      }; # yellow
      DiagnosticInfo = {
        fg = "#89b4fa";
      }; # blue
      DiagnosticHint = {
        fg = "#94e2d5";
      }; # teal

      DiagnosticVirtualTextError = {
        fg = "#f38ba8";
        bg = "#302030";
      };
      DiagnosticVirtualTextWarn = {
        fg = "#f9e2af";
        bg = "#302a20";
      };
      DiagnosticVirtualTextInfo = {
        fg = "#89b4fa";
        bg = "#202035";
      };
      DiagnosticVirtualTextHint = {
        fg = "#94e2d5";
        bg = "#20302e";
      };
    };

    extraConfigLua = ''
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix = function(diagnostic)
            local icons = {
              [vim.diagnostic.severity.ERROR] = "󰅚",
              [vim.diagnostic.severity.WARN]  = "󰀪",
              [vim.diagnostic.severity.INFO]  = "󰋽",
              [vim.diagnostic.severity.HINT]  = "󰌶",
            }
            return icons[diagnostic.severity] or "●"
          end,
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚",
            [vim.diagnostic.severity.WARN]  = "󰀪",
            [vim.diagnostic.severity.INFO]  = "󰋽",
            [vim.diagnostic.severity.HINT]  = "󰌶",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    '';
  };
}
