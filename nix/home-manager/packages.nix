{
  pkgs,
  claude-code-nix,
  system,
  ...
}:
{
  home.packages = with pkgs; [
    # CLI Tools
    eza
    ripgrep
    fd 
    rtk

    # Development Tools
    gh 
    nixd

    # AI Agents
    claude-code-nix.packages.${system}.claude-code

    # Cloud / Network
    # google-cloud-sdk: コンポーネントを追加する場合は以下のように記述する
    # (pkgs.google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [ gke-gcloud-auth-plugin bq ]))
    google-cloud-sdk
    ngrok # ローカルサーバーの外部公開トンネル

  ];
}
