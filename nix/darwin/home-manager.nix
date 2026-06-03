{
  claude-code-nix,
  nixvim,
  system,
  ...
}:
{
  # NOTE: Unable to build flake without home.homeDirectory error
  # https://github.com/nix-community/home-manager/issues/6036
  users.users.gesopon.home = "/Users/gesopon";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  # 既存の手書きファイル（例: ~/.zprofile）を上書きする際、エラーにせず
  # <name>.backup に退避してから管理下に置く。
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = { inherit claude-code-nix system; };
  home-manager.sharedModules = [ nixvim.homeModules.nixvim ];
  home-manager.users.gesopon = import ../home-manager/default.nix;
}
