{ ... }:
{
  home.shellAliases = {
    home-rebuild = "sudo darwin-rebuild switch --flake ~/dotfiles";
    reload = "exec $SHELL -l";

    ls = "eza ";
    ll = "eza --long";
    la = "eza --long --all";
    lt = "eza --tree";
  };
}
