{
  lib,
  config,
  pkgs,
  ...
}:
let
  # Claude Code の personal skill は ~/.claude/skills から、Codex の user skill は
  # ~/.agents/skills から、Antigravity CLI (agy) の global skill は ~/.gemini/config/skills
  # から読まれる。1 つの skill を 3 つ全部へ配る。
  #
  # agy は ~/.agents/skills を見ない (.agents/ を探すのは作業ディレクトリから
  # リポジトリルートまでだけ)。~/.gemini/config/skills.json で ~/.agents/skills を
  # 登録する手もあるが、そちらは組み込み skill より優先度が低いので symlink で並べる。
  # nix store を指す symlink の skill も agy は読む (1.5.14 で `agy -p /skills` により確認)。
  targetsFor = name: [
    ".claude/skills/${name}"
    ".agents/skills/${name}"
    ".gemini/config/skills/${name}"
  ];

  # home.file は source が存在しなくても黙ってリンク切れの symlink を作る。
  # upstream がディレクトリ構成を変えたときに気付けるよう、SKILL.md が
  # 無ければビルドを失敗させる。
  checked =
    name: source:
    pkgs.runCommandLocal "agent-skill-${name}" { } ''
      if [ ! -f ${source}/SKILL.md ]; then
        echo "agent skill '${name}': ${source}/SKILL.md が存在しない" >&2
        exit 1
      fi
      ln -s ${source} $out
    '';
in
{
  # skill は 1 つ 1 ファイルでこのディレクトリに置く。
  imports = [
    ./archify.nix
    ./d2-diagrams.nix
    ./herdr.nix
    ./mattpocock.nix
    ./stack-diagram.nix
    ./ui-ux-pro-max.nix
    ./yomiyasu.nix
  ];

  # skill の配布先はどれも同じなので、配布ロジックはここに1つだけ置き、
  # 各 skill は my.agentSkills に source を宣言するだけにする。
  options.my.agentSkills = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = { };
    example = lib.literalExpression ''
      { archify = "''${inputs.archify-skill}/archify"; }
    '';
    description = ''
      Claude Code / Codex / Antigravity CLI へ配布する skill。属性名が skill dir 名、値がその source。

      skill 本体が自身のディレクトリへ書き込まないことが前提。nix store への
      symlink (read-only) として配るため、書き込むものは home.activation など
      別の手段が必要になる。
    '';
  };

  config.home.file = lib.mkMerge (
    lib.mapAttrsToList (
      name: source:
      lib.genAttrs (targetsFor name) (_: {
        source = checked name source;
      })
    ) config.my.agentSkills
  );
}
