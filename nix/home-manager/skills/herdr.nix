{ config, ... }:
{
  # skill は herdr パッケージ自身が share/herdr/skills/herdr に同梱している。
  # npx skills add や fetchurl で別取得せず同じ derivation から引くことで、
  # バイナリと SKILL.md のバージョンが必ず一致する。
  #
  # SKILL.md は Herdr pane 内 (HERDR_ENV=1) のエージェントが他 pane を
  # 操作するための手順書。どちらのエージェントも書き換えない。
  my.agentSkills.herdr = "${config.programs.herdr.package}/share/herdr/skills/herdr";
}
