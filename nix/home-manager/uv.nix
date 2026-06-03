# NOTE: uv は単体のパッケージとしてインストールし、
# CLIツールは `uv tool` で管理する。
# uv tool のインストール自体は宣言的に書けないため、
# home-manager の activation スクリプトで冪等に実行する。
{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.uv ];

  # `uv tool install` が配置するバイナリは ~/.local/bin に入る
  home.sessionPath = [ "$HOME/.local/bin" ];

  # headroom-ai[proxy,code] を uv tool でインストール
  # （既にインストール済みなら uv が即座にスキップする）
  # macOS のシステム Python は 3.9 だが headroom-ai は 3.10+ を要求するため、
  # --python で uv 管理の Python を明示する（無ければ uv が自動 DL する）。
  home.activation.uvToolHeadroom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.uv}/bin/uv tool install --python 3.12 'headroom-ai[proxy,code]'
  '';
}
