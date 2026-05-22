{ pkgs, ... }:
let
  peekBuilt = pkgs.stdenvNoCC.mkDerivation {
    name = "peek-nvim-built";
    src = pkgs.fetchFromGitHub {
      owner = "toppair";
      repo = "peek.nvim";
      rev = "5820d937d5414baea5f586dc2a3d912a74636e5b";
      hash = "sha256-hGIPxHwTSXTHFJ3JiVATMjEmoFhZ87fWElj1AMPMbQU=";
    };
    nativeBuildInputs = [ pkgs.deno ];
    buildPhase = ''
      export HOME=$TMPDIR
      export DENO_DIR=$TMPDIR/deno-cache
      FAST=true deno run --allow-run --allow-net --allow-read --allow-write --allow-env --no-check scripts/build.js
    '';
    installPhase = "cp -r . $out";
    outputHash = "sha256-76CqBF09Ai8tEgRr0JxOdYAz2BtXmdzHhe888cazTug=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    opts = {
      relativenumber = true;
      number = true;
      spell = false;
      signcolumn = "yes";
      wrap = false;
      exrc = true;
      secure = true;
    };

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    keymaps = [
      { mode = "n"; key = "]b"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
      { mode = "n"; key = "[b"; action = "<cmd>bprev<cr>"; options.desc = "Previous buffer"; }
      { mode = "n"; key = "<Leader>bd"; action = "<cmd>bdelete<cr>"; options.desc = "Close buffer"; }
      { mode = "n"; key = "<Leader>mp"; action.__raw = "function() require('peek').open() end"; options.desc = "Markdown Preview Open"; }
      { mode = "n"; key = "<Leader>mc"; action.__raw = "function() require('peek').close() end"; options.desc = "Markdown Preview Close"; }
    ];

    plugins = {
      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      lsp = {
        enable = true;
        servers = {
          nixd.enable = true;
          lua_ls.enable = true;
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

      gitsigns.enable = true;
      lualine.enable = true;
      bufferline.enable = true;
      which-key.enable = true;
      comment.enable = true;
      nvim-autopairs.enable = true;
      indent-blankline.enable = true;

      toggleterm = {
        enable = true;
        settings.direction = "float";
      };

      neo-tree = {
        enable = true;
        filesystem.filteredItems = {
          visible = true;
          hideDotfiles = false;
          hideGitignored = false;
          neverShow = [
            ".DS_Store"
            ".git"
          ];
        };
      };
    };

    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "peek-nvim";
        src = peekBuilt;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "dataform-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "magal1337";
          repo = "dataform.nvim";
          rev = "43a5f9e17275325ae32e5248c6f21636418e2018";
          hash = "sha256-HA6E9L6U37Btb/dDgtm7du97/fae5IawCSg/nmB/tqg=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "wmnusmv-vim";
        src = pkgs.fetchFromGitHub {
          owner = "wannesm";
          repo = "wmnusmv.vim";
          rev = "a9fa46eea8e667aa6413267a27209be18cae6622";
          hash = "sha256-otXUPzzabsjXiOvhCieO1d9TYpIrxyNwjxydx7dU+MQ=";
        };
      })
    ];

    extraPackages = with pkgs; [ stylua ];

    extraConfigLua = ''
      require("peek").setup({ app = "browser" })
    '';
  };
}
