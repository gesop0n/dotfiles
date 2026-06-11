{
  pkgs,
  claude-code-nix,
  system,
  ...
}:
{
  home.packages = with pkgs; [
    # Commands
    # ----------
    eza

    # Git関連
    gh

    # telescope dependencies
    ripgrep
    fd

    # nixvim LSP / formatter (CLIとしても使用)
    nixd

    # Agents
    # ----------
    claude-code-nix.packages.${system}.claude-code

    # Google Cloud
    # コンポーネントを追加する場合:
    # (pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin bq ]))
    google-cloud-sdk

    # 他ツール
    obsidian
  ];
}
