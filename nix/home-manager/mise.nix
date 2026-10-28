{ ... }:
{
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    # NOTE: package は上書きしないこと。overrideAttrs で checkFlags を足すと
    # derivation hash が変わって cache.nixos.org の aarch64-darwin バイナリを
    # 引けなくなり、ローカルでのソースビルド = 全 test 実行になる。mise の
    # http::tests のダウンロード再開テストは sandbox 内で不安定で落ちる。
    globalConfig = {
      tools = {
        node = "latest";
        "npm:@colbymchenry/codegraph" = "latest";
        "npm:vercel" = "latest";
        # Markdown をブラウザで開くビューア。nixpkgs の mo は同名の別ツールなので mise で入れる。
        "aqua:k1LoW/mo" = "latest";
      };
    };
  };
}
