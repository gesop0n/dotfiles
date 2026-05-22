{ ... }:
{
  programs.nixvim.plugins = {
    fzf-lua.enable = true;

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    flash.enable = true;
    which-key.enable = true;
    comment.enable = true;
    nvim-autopairs.enable = true;
  };
}
