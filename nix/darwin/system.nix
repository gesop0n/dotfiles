{
  self,
  system,
  ...
}:
{
  nix.settings.experimental-features = "nix-command flakes";

  # codex-cli-nix の Cachix バイナリキャッシュ。
  # これがないと codex の native Rust バイナリをソースからビルドすることになる。
  # extra-* を使い、既定の cache.nixos.org を置き換えず追記する。
  nix.settings.extra-substituters = [ "https://codex-cli.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "codex-cli.cachix.org-1:1Br3H1hHoRYG22n//cGKJOk3cQXgYobUel6O8DgSing="
  ];

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
}
