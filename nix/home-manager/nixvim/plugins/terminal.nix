{ ... }:
{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    settings.direction = "float";
  };

  programs.nixvim.extraConfigLua = ''
    -- NOTE: lazygit 用フローティングターミナル
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({ cmd = "lazygit", direction = "float", hidden = true })
    function _lazygit_toggle() lazygit:toggle() end
  '';
}
