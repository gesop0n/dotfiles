{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ../../.config/wezterm/wezterm.lua;
  };

  xdg.configFile."wezterm/appearance.lua".source = ../../.config/wezterm/appearance.lua;
  xdg.configFile."wezterm/tabbar.lua".source = ../../.config/wezterm/tabbar.lua;
  xdg.configFile."wezterm/keys.lua".source = ../../.config/wezterm/keys.lua;
}
