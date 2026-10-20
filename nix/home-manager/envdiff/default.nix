{ pkgs, ... }:
{
  # .env 系ファイルをキー単位で比べる自作コマンド。値は絶対に表示しない。
  # 単体でのビルド (テスト込み) は `nix build .#envdiff`。
  home.packages = [ (pkgs.callPackage ./package.nix { }) ];
}
