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
        # PFN の日英翻訳 CLI。中身は uv tool install。python を省くと nix の python3 を
        # 掴み、nixpkgs 更新後の GC で venv が壊れうるので mise 専用の runtime を使わせる。
        # mise は X.Y.Z.postN を X.Y.Z より古いと並べるので latest は post リリースを拾わない。
        "pypi:plamo-translate" = {
          version = "latest";
          python = "3.14";
        };
      };
    };
  };
}
