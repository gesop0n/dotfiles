{ inputs, ... }:
{
  # yomiyasu: AI が生成した日本語の不自然な比喩、曖昧な主述関係、不要な装飾を
  # 意味を変えずに直す skill。名前を出して頼んだとき (/yomiyasu など) だけ動く。
  #
  # upstream は `npx skills add nanaism/yomiyasu` などを案内しているが、どれも
  # skill dir へコピーするだけの手順。宣言的に持ちたいので、リポジトリを
  # flake input で pin して直接配置する。
  #
  # リポジトリ直下の scripts/ references/ は開発用の写しで、SKILL.md を含む
  # 配布用の skill 本体は skills/yomiyasu/ にある。
  #
  # scripts/*.py は stdlib だけで動く (Python 3.8 以上)。python3 の実体は
  # packages.nix で固定している。検査の記録は git の最上位 (なければ作業
  # ディレクトリ) の .yomiyasu/ に書き、そこに自分を無視する .gitignore も置く。
  # sys.dont_write_bytecode で __pycache__ も作らないので、skill dir 自体は
  # read-only でよい。
  #
  # 同梱の yomiyasu_hook.py は settings.json に貼ったときだけ動く任意のフックで、
  # ここでは入れていない。
  my.agentSkills.yomiyasu = "${inputs.yomiyasu-skill}/skills/yomiyasu";
}
