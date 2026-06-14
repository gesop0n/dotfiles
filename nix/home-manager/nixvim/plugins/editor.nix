{ ... }:
{
  programs.nixvim.plugins = {
    fzf-lua.enable = true;

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        ensure_installed = [
          "typescript"
          "tsx"
          "javascript"
        ];
      };
    };

    flash.enable = true;
    which-key.enable = true;
    comment.enable = true;
    nvim-autopairs.enable = true;
    ts-autotag.enable = true;
  };
}
