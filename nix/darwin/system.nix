{
  inputs,
  system,
  lib,
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

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
  system.stateVersion = 6;

  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  # redis 8.10.3 は Makefile の SDK パスを `xcrun --show-sdk-path` に変えたため、
  # nixpkgs の Darwin 向け postPatch (--replace-fail) が一致せずビルドが落ちる。
  # 上流は postPatch を消して直した (NixOS/nixpkgs#580069) ので同じことをする。
  # lock の nixpkgs に修正が届くと、古い postPatch が無くなるので素通しして
  # (キャッシュが効く) 評価時に警告を出す。警告が出たら overlay ごと消す。
  nixpkgs.overlays = [
    (_final: prev: {
      redis =
        if lib.hasInfix "CommandLineTools" (prev.redis.postPatch or "") then
          prev.redis.overrideAttrs { postPatch = ""; }
        else
          lib.warn "nixpkgs の redis は修正済み (NixOS/nixpkgs#580069)。nix/darwin/system.nix の redis overlay を消してよい" prev.redis;
    })
  ];

  programs.zsh.enable = true;
}
