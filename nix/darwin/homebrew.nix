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

    brews = [ ];

    casks = [
      "maccy"
    ];
  };
}
