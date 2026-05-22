{ claude-code-nix, nixvim, system, ... }:
{
  # NOTE: Unable to build flake without home.homeDirectory error
  # https://github.com/nix-community/home-manager/issues/6036
  users.users.gesopon.home = "/Users/gesopon";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit claude-code-nix system; };
  home-manager.sharedModules = [ nixvim.homeManagerModules.nixvim ];
  home-manager.users.gesopon = import ../home-manager/default.nix;
}
