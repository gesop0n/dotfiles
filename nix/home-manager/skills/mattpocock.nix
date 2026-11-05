{ inputs, lib, ... }:
let
  src = inputs.mattpocock-skills;
  paths = map (lib.removePrefix "./") (lib.importJSON "${src}/.claude-plugin/plugin.json").skills;
  skills = lib.listToAttrs (map (path: lib.nameValuePair (baseNameOf path) "${src}/${path}") paths);
in
{
  # mattpocock/skills: 要件の詰めから spec / ticket への分割、TDD での実装、振り返りまでの
  # 流れを支える skill 集。迷ったら /ask-matt がどの skill を使うか案内する。
  #
  # upstream は plugin か `npx skills add` を案内しているが、plugin は自動で更新され、
  # npx は skill dir へコピーするだけの手順。宣言的に持ちたいので、リポジトリを
  # flake input で pin して直接配置する。
  #
  # 配る skill は upstream が plugin.json で公開対象に選んだものに揃える
  # (misc/ と in-progress/ は含まない)。タグを上げると新しい skill も配られる。
  #
  # 実行時の依存は bash と、tracker に応じて gh / glab だけ。生成物の出力先は作業
  # ディレクトリと OS の一時ディレクトリなので、skill dir 自体は read-only でよい。
  # ただし wizard は template.sh を cp して編集するので、写しには chmod が要る。
  #
  # to-spec / to-tickets / triage / wayfinder は設定した issue tracker へ書き込み、
  # setup-matt-pocock-skills は tracker にラベルを作る。implement は現在のブランチへ
  # コミットする。
  my.agentSkills = removeAttrs skills [ "code-review" ];

  # personal skill は同名の組み込みコマンドを置き換えるので、code-review を Claude Code へ
  # 配ると、effort 指定や --fix を持つ組み込みの /code-review が使えなくなる。Codex にだけ
  # 配り、Claude Code の /implement が最後に呼ぶレビューは組み込み版に任せる。
  home.file.".agents/skills/code-review".source = skills.code-review;
}
