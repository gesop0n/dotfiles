{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # Zed は migration や UI トグルで settings.json / keymap.json を自分で書き換える。
  # store へコピーする方式（read-only symlink）だとその書き戻しが毎回失敗するため、
  # store を経由せず dotfiles の実ファイルへ直接 symlink する（Zed が in-place で書き込める）。
  xdg.configFile."zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/zed/settings.json";
  xdg.configFile."zed/keymap.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/zed/keymap.json";
}
