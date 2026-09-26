{ ... }:
{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    settings = {
      direction = "float";
      # ノーマル/インサート/ターミナルモードでターミナルを開閉する。
      # 2<C-\> のようにカウントを付けると別番号のターミナルを開ける。
      open_mapping = "[[<C-\\>]]";
      size = ''
        function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
        end
      '';
      # ターミナル内では <C-\> を開閉に使うので標準の <C-\><C-n> が効かなくなる。
      # 代わりに <Esc><Esc> でノーマルモードに戻す。lazygit など独自コマンドの
      # ターミナルは Esc をアプリ側で使うので対象外にする。
      on_create = ''
        function(term)
          if term.cmd then return end
          vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = term.bufnr, desc = "Exit terminal mode" })
        end
      '';
    };
  };

  programs.nixvim.extraConfigLua = ''
    -- NOTE: lazygit 用フローティングターミナル
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
    function _lazygit_toggle() lazygit:toggle() end
  '';
}
