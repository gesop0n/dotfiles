{ ... }:
let
  # NOTE: nvim-treesitter-textobjects — 関数・クラス・引数単位の選択/移動
  selectTextobject = key: query: desc: {
    mode = [
      "x"
      "o"
    ];
    inherit key;
    action.__raw = "function() require('nvim-treesitter-textobjects.select').select_textobject('${query}', 'textobjects') end";
    options.desc = desc;
  };
  moveTextobject = key: fn: query: desc: {
    mode = [
      "n"
      "x"
      "o"
    ];
    inherit key;
    action.__raw = "function() require('nvim-treesitter-textobjects.move').${fn}('${query}', 'textobjects') end";
    options.desc = desc;
  };
in
{
  programs.nixvim.keymaps = [
    (selectTextobject "af" "@function.outer" "Around function")
    (selectTextobject "if" "@function.inner" "Inside function")
    (selectTextobject "ac" "@class.outer" "Around class")
    (selectTextobject "ic" "@class.inner" "Inside class")
    (selectTextobject "aa" "@parameter.outer" "Around argument")
    (selectTextobject "ia" "@parameter.inner" "Inside argument")
    (moveTextobject "]f" "goto_next_start" "@function.outer" "Next function start")
    (moveTextobject "[f" "goto_previous_start" "@function.outer" "Previous function start")
    (moveTextobject "]F" "goto_next_end" "@function.outer" "Next function end")
    (moveTextobject "[F" "goto_previous_end" "@function.outer" "Previous function end")

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

    # NOTE: trouble.nvim — 診断・シンボル・参照の一覧
    {
      mode = "n";
      key = "<Leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<Leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
      options.desc = "Buffer diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<Leader>xL";
      action = "<cmd>Trouble loclist toggle<cr>";
      options.desc = "Location list (Trouble)";
    }
    {
      mode = "n";
      key = "<Leader>xQ";
      action = "<cmd>Trouble qflist toggle<cr>";
      options.desc = "Quickfix list (Trouble)";
    }
    {
      mode = "n";
      key = "<Leader>cs";
      action = "<cmd>Trouble symbols toggle focus=false<cr>";
      options.desc = "Symbols (Trouble)";
    }
    {
      mode = "n";
      key = "<Leader>cl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
      options.desc = "LSP definitions / references (Trouble)";
    }

    # NOTE: conform.nvim — 手動フォーマット (保存時は自動)
    {
      mode = "n";
      key = "<Leader>cf";
      action.__raw = "function() require('conform').format({ async = true }) end";
      options.desc = "Format buffer";
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

    # NOTE: toggleterm — 向きを指定してターミナルを開閉する (<C-\> でも開閉できる)
    {
      mode = "n";
      key = "<Leader>tf";
      action = "<cmd>ToggleTerm direction=float<cr>";
      options.desc = "Toggle floating terminal";
    }
    {
      mode = "n";
      key = "<Leader>th";
      action = "<cmd>ToggleTerm direction=horizontal<cr>";
      options.desc = "Toggle horizontal terminal";
    }
    {
      mode = "n";
      key = "<Leader>tv";
      action = "<cmd>ToggleTerm direction=vertical<cr>";
      options.desc = "Toggle vertical terminal";
    }
    {
      mode = "n";
      key = "<Leader>ts";
      action = "<cmd>TermSelect<cr>";
      options.desc = "Select terminal";
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
