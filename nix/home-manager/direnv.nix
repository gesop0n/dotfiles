{ ... }:
{
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;

    # fkale の devShells を自動ロードするために推奨
    nix-direnv.enable = true;
  };
}
