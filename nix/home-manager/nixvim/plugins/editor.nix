{ ... }:
{
  programs.nixvim.plugins = {
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

    which-key.enable = true;
    comment.enable = true;
    nvim-autopairs.enable = true;
  };
}
