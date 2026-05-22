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

    # AstroNvim dependencies
    # ----------
    ripgrep
    fd
    lazygit
    tree-sitter

    # LSPs
    # ----------
    nixd

    # Neovim plugin dependencies
    # ----------
    deno

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
