{ config, ... }:
let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
in
{
  # Codex CLI (codex-cli) の設定。中身は dotfiles の .config/.codex/config.toml を参照。
  # codex は XDG ではなく ~/.codex を見るため、リポジトリ側も .config/.codex として
  # ホームのディレクトリ名をそのままミラーする。
  #
  # codex は config.toml を自分でも書き換える:
  #   - [projects."<path>"].trust_level : ディレクトリを信頼したとき
  #   - [features]                      : `codex features enable/disable`
  #   - [tui.*]                         : TUI の操作や NUX カウンタ
  # しかも書き込みは「一時ファイル + rename」なので、home.file (nix store への
  # read-only symlink) だと rename 先が store になって失敗する。
  # そのため store を経由せず dotfiles の実ファイルへ直接 symlink する
  # (zed.nix と同じ方式)。codex の TOML 編集はフォーマット保持なのでコメントは
  # 消えないが、codex が書き足した分は dotfiles 側の差分として出る。
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/.config/.codex/config.toml";
}
