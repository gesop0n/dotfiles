{ ... }:
{
  # herdr: AI エージェントの状態 (作業中 / 入力待ち / 完了) を認識する
  # ターミナルマルチプレクサ。
  #
  # home-manager モジュールが settings を TOML 化して
  # ~/.config/herdr/config.toml へ書き出し、変更時に
  # `herdr server reload-config` を自動実行する。
  #
  # 注意: ~/.config/herdr にはログ (herdr*.log)・ソケット・セッション状態が
  # 同居する。wezterm や hammerspoon のようにディレクトリ単位で symlink すると
  # 実行時状態を dotfiles に引きずり込むため、config.toml 単体のみを管理する。
  programs.herdr = {
    enable = true;

    settings = {
      # herdr は初回起動時に onboarding = false を config.toml へ書き戻す。
      # nix store 経由の symlink は read-only でこの書き込みが失敗するため、
      # 最初から false にしてオンボーディングをスキップする。
      onboarding = false;

      # WezTerm 側の color_scheme (Tokyo Night) と揃える。
      theme.name = "tokyo-night";

      update = {
        # バイナリは nixpkgs 管理なので `herdr update` は使えない。
        # 更新は `nix flake update nixpkgs` 経由で行うため、
        # 対処できない新バージョン通知は止める。
        version_check = false;
      };

      ui.toast = {
        # エージェントがブロック/完了したら macOS の通知として出す。
        # 既定は "off" だが、これが herdr を使う主目的なので有効にする。
        delivery = "system";
      };

      experimental = {
        # prefix キー押下中だけ ASCII 入力ソースへ切り替える。
        # 日本語 IME が有効なままでも prefix コマンドが効くようになる。
        switch_ascii_input_source_in_prefix = true;

        # Claude Code / Codex は自前でカーソルを描画するため、macOS の
        # IME 変換候補ウィンドウがカーソル位置を追従できない。
        # フォーカス中ペインのカーソルを外側の端末へ伝えて追従させる。
        reveal_hidden_cursor_for_cjk_ime = true;
        cjk_ime_agents = [
          "claude"
          "codex"
        ];
      };
    };
  };
}
