{ ... }:
{
  programs.nixvim.plugins = {
    lualine.enable = true;
    bufferline.enable = true;
    indent-blankline.enable = true;

    # ファイルアイコンは mini.icons に任せる。
    # nvim-web-devicons が nf-dev-* 中心なのに対し、mini.icons は
    # nf-md-* (Material Design Icons) を優先するため Material 寄りの見た目になる。
    # mockDevIcons で nvim-web-devicons を emulate するので、
    # neo-tree / bufferline / lualine / fzf-lua もそのまま追従する。
    mini-icons = {
      enable = true;
      mockDevIcons = true;
      settings.style = "glyph";
    };
  };
}
