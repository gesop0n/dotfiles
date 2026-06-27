{ pkgs, ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    # Build mise from source skipping the setuid test, which can't pass in the
    # macOS Nix sandbox (it strips setuid bits, so 0o4755 comes back as 0o755).
    # This is also why cache.nixos.org has no aarch64-darwin binary for this
    # version. Drop this override once nixpkgs disables the test on darwin.
    package = pkgs.mise.overrideAttrs (old: {
      checkFlags = (old.checkFlags or [ ]) ++ [
        "--skip=oci::layer::tests::preserve_metadata_dir_layer_keeps_special_permission_bits"
      ];
    });
    globalConfig = {
      tools = {
        node = "latest";
        "npm:@colbymchenry/codegraph" = "latest";
        "npm:vercel" = "latest";
      };
    };
  };
}
