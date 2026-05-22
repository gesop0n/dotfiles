{ ... }:
{
  programs.nixvim.plugins.neo-tree = {
    enable = true;
    settings.filesystem.filtered_items = {
      visible = true;
      hide_dotfiles = false;
      hide_gitignored = false;
      never_show = [
        ".DS_Store"
        ".git"
      ];
    };
  };
}
