{ ... }:
{
  programs.nixvim.keymaps = [
    # NOTE: バッファ移動
    { mode = "n"; key = "]b"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
    { mode = "n"; key = "[b"; action = "<cmd>bprev<cr>"; options.desc = "Previous buffer"; }
    { mode = "n"; key = "<Leader>bd"; action = "<cmd>bdelete<cr>"; options.desc = "Close buffer"; }

    # NOTE: peek.nvim — Markdownのブラウザプレビュー
    { mode = "n"; key = "<Leader>mp"; action.__raw = "function() require('peek').open() end"; options.desc = "Markdown Preview Open"; }
    { mode = "n"; key = "<Leader>mc"; action.__raw = "function() require('peek').close() end"; options.desc = "Markdown Preview Close"; }

    # NOTE: lazygit をフローティングターミナルで開く
    { mode = "n"; key = "<Leader>gg"; action = "<cmd>lua _lazygit_toggle()<cr>"; options.desc = "Toggle lazygit"; }

    # NOTE: ウィンドウ間移動（neo-treeサイドバー含む）
    { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Move to left window"; }
    { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Move to lower window"; }
    { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Move to upper window"; }
    { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Move to right window"; }
  ];
}
