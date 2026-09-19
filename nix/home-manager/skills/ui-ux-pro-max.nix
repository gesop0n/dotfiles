{ inputs, ... }:
{
  # ui-ux-pro-max: UI/UX の設計判断を data/ の CSV から検索して組み立てる skill。
  #
  # upstream は `npx ui-ux-pro-max-cli init` でのインストールを案内しているが、
  # あれはプロジェクトへ skill をコピーする用途。user-level skill を宣言的に
  # 持ちたいので、リポジトリ自体を flake input で pin して直接配置する。
  # 更新は `nix flake update ui-ux-pro-max-skill` のみ。
  #
  # scripts/*.py は stdlib だけで動き、書き込み先も Path.cwd() 配下
  # (design-system/<project>/) なので、skill dir 自体は read-only でよい。
  # スクリプトが呼ぶ python3 の実体は packages.nix で固定している。
  #
  # upstream は skill 本体を .claude/skills/ui-ux-pro-max にのみ持つ
  # (.agents/ はリポジトリには無く、公式 CLI が配布時に生成する側のレイアウト)。
  # SKILL.md のほかに data/ references/ scripts/ を含むのでディレクトリごと配る。
  my.agentSkills.ui-ux-pro-max = "${inputs.ui-ux-pro-max-skill}/.claude/skills/ui-ux-pro-max";
}
