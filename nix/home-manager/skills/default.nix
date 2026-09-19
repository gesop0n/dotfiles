{
  lib,
  config,
  claudeConfigDirs,
  ...
}:
let
  # Claude Code の personal skill は user config dir (claude.nix の
  # claudeConfigDirs) 配下から、Codex の user skill は ~/.agents/skills から
  # 読まれる。1 つの skill をその全てへ配る。
  targetsFor =
    name: map (dir: "${dir}/skills/${name}") claudeConfigDirs ++ [ ".agents/skills/${name}" ];
in
{
  # skill は 1 つ 1 ファイルでこのディレクトリに置く。
  imports = [
    ./archify.nix
    ./d2-diagrams.nix
    ./herdr.nix
    ./ui-ux-pro-max.nix
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
      Claude Code / Codex へ配布する skill。属性名が skill dir 名、値がその source。

      skill 本体が自身のディレクトリへ書き込まないことが前提。nix store への
      symlink (read-only) として配るため、書き込むものは home.activation など
      別の手段が必要になる。
    '';
  };

  config.home.file = lib.mkMerge (
    lib.mapAttrsToList (
      name: source:
      lib.genAttrs (targetsFor name) (_: {
        inherit source;
      })
    ) config.my.agentSkills
  );
}
