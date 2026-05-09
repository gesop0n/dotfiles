{ ... }:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.font_size = 16.0

      return config
    '';
  };
}
