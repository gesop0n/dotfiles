{ inputs, ... }:
{
  # stack-diagram: 公式ロゴ入りの構成図を、自己完結した HTML (PNG / TSX はそこから派生) で
  # 生成する skill。
  #
  # upstream は `npx skills add caru-ini/stack-diagram` を案内しているが、これは
  # skill dir へコピーするだけの手順。宣言的に持ちたいので、リポジトリを
  # flake input で pin して直接配置する。
  #
  # fetch_icons.py / build.py / share.py は stdlib だけで動く。python3 の実体は
  # packages.nix で固定している。render_png.py だけ Playwright が要るが、nix の
  # python3 には pip install できないので `uv run --no-project --with playwright` で動かす。
  #
  # 生成物の出力先はすべて引数で指定するパスなので、skill dir 自体は read-only でよい。
  # ただし assets/template.html を cp すると写しも read-only になるので、編集前に chmod が要る。
  #
  # share.py は図を公開ギャラリー (stacks.caru.moe) へ投稿する。SKILL.md は作図後に
  # 投稿を 1 度提案し、送信前に利用者の同意を 2 回取る手順になっている。
  my.agentSkills.stack-diagram = "${inputs.stack-diagram-skill}/skills/stack-diagram";
}
