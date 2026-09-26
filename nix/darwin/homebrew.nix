{ ... }:
{
  system.primaryUser = "gesopon";

  nix-homebrew = {
    enable = true;
    user = "gesopon";

    # apple シリコン搭載の Mac 限定の設定。
    # 古い Intel Mac でしか動かないパッケージを利用する場合、有効にする
    # ----------
    enableRosetta = false;

    # 既存の Homebrew から自動移行
    # ----------
    autoMigrate = true;
  };

  # Homebrew settings
  # https://nix-darwin.github.io/nix-darwin/manual/#opt-homebrew.enable
  # ----------
  homebrew = {
    enable = true;

    # 宣言にない formula / cask / tap は switch 時にアンインストールする。
    # 宣言したものの依存として入ったものは対象外。
    # "zap" にするとアプリの設定ファイルまで消えるので "uninstall" に留める。
    onActivation.cleanup = "uninstall";

    # CLI ツールは nix (home-manager) で管理し、Homebrew は GUI アプリ (cask) 専用にする。
    # brew の formula は依存として git なども引き込み、`brew shellenv` により
    # /opt/homebrew/bin が PATH の先頭に来るため、nix 側の同名コマンドを隠してしまう。
    casks = [
      "maccy"
      "hammerspoon"
      "karabiner-elements"
      "docker-desktop"
      "skim"
      "zed"
    ];
  };
}
