{ ... }:
{
  programs.nixvim.plugins.neo-tree = {
    enable = true;
    # サイドバーの幅（デフォルトは40）
    settings.window.width = 30;
    settings.filesystem = {
      filtered_items = {
        visible = true;
        hide_dotfiles = false;
        hide_gitignored = false;
        never_show = [
          ".DS_Store"
          ".git"
        ];
      };
      use_libuv_file_watcher = true;
    };
  };

  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        if package.loaded["neo-tree"] then
          require("neo-tree.sources.manager").refresh("filesystem")
          require("neo-tree.sources.manager").refresh("git_status")
        end
      end,
    })
  '';
}
