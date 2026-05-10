{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../../wezterm/wezterm.lua;
  };

  xdg.configFile."wezterm/appearance.lua".source = ../../wezterm/appearance.lua;
  xdg.configFile."wezterm/tabbar.lua".source = ../../wezterm/tabbar.lua;
}
