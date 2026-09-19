{ ... }:
{
  # d2-diagrams: D2 (宣言的ダイアグラム言語) でソースを書き、d2 CLI で
  # SVG / PNG へレンダリングするまでを案内する skill。
  #
  # 依存は d2 バイナリのみで、packages.nix で入れている。そのため SKILL.md に
  # ある brew / install.sh でのインストール手順は踏まなくてよい。
  #
  # 書き込むのは .d2 ソースとレンダリング結果 (どちらもユーザー指定のパス) で、
  # skill dir 自身へは書き込まない。
  my.agentSkills.d2-diagrams = ../../../.config/agents/skills/d2-diagrams;
}
