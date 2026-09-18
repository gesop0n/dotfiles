{ inputs, ... }:
{
  # archify: 型付き JSON IR を検証してから、自己完結した HTML の構成図
  # (architecture / workflow / sequence / dataflow / lifecycle) へ
  # 決定的にコンパイルする skill。
  #
  # upstream は `npx skills add tt-a1i/archify -g` を案内しているが、これは
  # ~/.claude/skills へコピーするだけの手順。宣言的に持ちたいので
  # ui-ux-pro-max と同様にリポジトリを flake input で pin して直接配置する。
  #
  # 依存は Node.js >= 18 のみ (mise の node が実体)。package.json の
  # ajv / parse5 / saxes / simple-icons は devDependencies で、コード生成と
  # テストからしか使われない。実行側は node: 標準モジュールだけで動き、
  # ajv 由来の検証器は generated-validators.mjs としてコミット済みなので
  # npm install は不要。
  #
  # 生成物の出力先はユーザー指定パス、update check の state は
  # ~/.cache/archify-skill なので skill dir 自体への書き込みは無く、
  # nix store への symlink で配れる。
  # visual-check サブコマンドのみ Chrome を必要とする (自動検出、任意)。
  my.agentSkills.archify = "${inputs.archify-skill}/archify";
}
