{
  self,
  system,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
}
