{ ... }:
{
  programs.nixvim.plugins.neo-tree = {
    enable = true;
    # サイドバーの幅（デフォルトは40）
    settings.window.width = 30;
    # フォルダアイコンは devicons 経由ではなく neo-tree のハードコード値なので、
    # nf-md-* (Material Design Icons) に揃えて明示的に上書きする。
    settings.default_component_configs.icon = {
      folder_closed = "󰉋";
      folder_open = "󰝰";
      folder_empty = "󰉖";
      folder_empty_open = "󰷏";
    };
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
