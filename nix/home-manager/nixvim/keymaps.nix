{ ... }:
{
  programs.nixvim.keymaps = [
    # NOTE: flash.nvim — 画面上の任意の場所へ高速ジャンプ
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash treesitter";
    }
    {
      mode = "o";
      key = "r";
      action.__raw = "function() require('flash').remote() end";
      options.desc = "Flash remote";
    }
    {
      mode = [
        "o"
        "x"
      ];
      key = "R";
      action.__raw = "function() require('flash').treesitter_search() end";
      options.desc = "Flash treesitter search";
    }

    # NOTE: fzf-lua — ファジーファインダー
    {
      mode = "n";
      key = "<Leader>ff";
      action = "<cmd>FzfLua files<cr>";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<Leader>fg";
      action = "<cmd>FzfLua live_grep<cr>";
      options.desc = "Live grep";
    }
    {
      mode = "n";
      key = "<Leader>fb";
      action = "<cmd>FzfLua buffers<cr>";
      options.desc = "Find buffers";
    }
    {
      mode = "n";
      key = "<Leader>fh";
      action = "<cmd>FzfLua help_tags<cr>";
      options.desc = "Help tags";
    }
    {
      mode = "n";
      key = "<Leader>fr";
      action = "<cmd>FzfLua oldfiles<cr>";
      options.desc = "Recent files";
    }

    # NOTE: バッファ移動
    {
      mode = "n";
      key = "]b";
      action = "<cmd>bnext<cr>";
      options.desc = "Next buffer";
    }
    {
      mode = "n";
      key = "[b";
      action = "<cmd>bprev<cr>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<Leader>bd";
      action = "<cmd>bdelete<cr>";
      options.desc = "Close buffer";
    }

    # NOTE: peek.nvim — Markdownのブラウザプレビュー
    {
      mode = "n";
      key = "<Leader>mp";
      action.__raw = "function() require('peek').open() end";
      options.desc = "Markdown Preview Open";
    }
    {
      mode = "n";
      key = "<Leader>mc";
      action.__raw = "function() require('peek').close() end";
      options.desc = "Markdown Preview Close";
    }

    # NOTE: lazygit をフローティングターミナルで開く
    {
      mode = "n";
      key = "<Leader>gg";
      action = "<cmd>lua _lazygit_toggle()<cr>";
      options.desc = "Toggle lazygit";
    }

    # NOTE: ウィンドウ間移動（neo-treeサイドバー含む）
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w>h";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w>j";
      options.desc = "Move to lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w>k";
      options.desc = "Move to upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w>l";
      options.desc = "Move to right window";
    }
  ];
}
