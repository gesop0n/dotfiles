---
name: global-japanese-math-writing
description: 日本語で数学を書く／訳すときの記述規範。定理環境・見出しの標準訳語と体裁、数式と和文の組版（間隔・句読点・全角半角）、数学日本語の定型表現、論理接続語（thus/hence/therefore/indeed…）の訳し分け、証明の運び、分野別（グラフ理論・パーフェクトグラフ／解析・代数・位相）の訳語集と誤訳の罠を定める。一般の文章品質は global-japanese-tech-writing に従い、本スキルは数学固有の層だけを扱う。数学書・論文・講義ノートの日本語執筆、および英語数学文書の和訳のときに使う。
---

# 日本語 数学記述の規範

数学を日本語で書く・英語から訳すときの、**数学固有**の規範。
一般の文章品質（段落構成、論証の厳密さ、冗長の排除、LLM っぽい空句の禁止、見出しの付け方）は `global-japanese-tech-writing` に従う。本スキルはそれに**加えて**適用する数学固有の層であり、両者が触れる箇所では数学の慣用（本スキル）を優先する。

## 語調と基本

- 地の文は「である」調で統一する。「です・ます」調は使わない。
- 数式・記号（変数、演算子、集合、`$\square$` など）は言語に依存しない。訳しても記号は原文のまま保つ。日本語版で記号を変えたり全角にしたりしない。
- 記号を主語・目的語にするときは、記号の直後に和文の助詞を続ける（「$x$ を」「$G$ は」「$f$ について」）。数式と和文の境界は luatexja が自動で空きを作るので、助詞を詰めて書いてよい。
- 全角の読点「、」句点「。」を使う。文末が数式で終わるときも、文の終わりには「。」を置く。
- 数式は文の一部として読める形にする。別行立ての数式でも、直後を「。」や助詞で受けて文を完成させる。

## 定理環境・見出しの訳語と体裁

英語の定理系見出しは次の定訳を使う。番号は原著に合わせる。

| 英語 | 日本語 | 英語 | 日本語 |
|---|---|---|---|
| Theorem | 定理 | Definition | 定義 |
| Proposition | 命題 | Axiom | 公理 |
| Lemma | 補題 | Conjecture | 予想 |
| Corollary | 系 | Claim | 主張 |
| Proof | 証明 | Remark / Note | 注意（注） |
| Example | 例 | Notation | 記法 |
| Exercise | 演習（問） | Convention | 約束 |
| Observation | 観察 | Fact | 事実 |

LaTeX では `\newtheorem` の**表示名だけ**差し替える。環境名（`theorem` 等）・カウンタ・番号設定は変えず、`\ref`/`\label` を壊さない。

```latex
\newtheorem{theorem}{定理}
\newtheorem{proposition}[theorem]{命題}
\newtheorem{lemma}[theorem]{補題}
\newtheorem{corollary}[theorem]{系}
\newtheorem{definition}[theorem]{定義}
\newtheorem{example}[theorem]{例}
\theoremstyle{remark}\newtheorem*{remark}{注意}
```

証明終わりの記号は環境の `\qed`（`$\square$` か `$\blacksquare$`）に任せる。本文で「証明終わり」と書かない。

## 数学日本語の定型

英語の定型を、対応する日本語の定型に写す。逐語訳しない。

- Let $x$ be … → 「$x$ を〜とする」。Let $G$ be a graph → 「$G$ をグラフとする」
- Suppose / Assume (that) … → 「〜と仮定する」「〜であるとする」
- Define … by … → 「〜を〜で定める（定義する）」
- We say that … is … if … → 「〜が〜であるとは、〜が成り立つことをいう」（定義の常套句）
- There exists … such that … → 「〜を満たす〜が存在する」
- For all / for every … → 「任意の〜に対して」「すべての〜について」
- if and only if → 「〜であるとき、かつそのときに限り」（略記が要るなら「⟺」）
- without loss of generality → 「一般性を失わず」
- We have … / It follows that … → 「〜が成り立つ」「〜となる」「〜を得る」
- as desired / this completes the proof → 「以上より（示された）」「これで証明が完了する」
- Recall that … → 「〜であったことを思い出す」
- Note that … → 「〜に注意する」
- It suffices to show … → 「〜を示せば十分である」

## 論理接続語の訳し分け

英語では別語でも同義に見えるものを、日本語では**論理の役割**で訳し分ける。機械的に1対1にしない（`global-japanese-tech-writing` の「接続の型」も参照し、連打を避ける）。

| 英語 | 日本語 | 役割 |
|---|---|---|
| therefore / hence / thus | よって／したがって／ゆえに | 結論の導出 |
| so | だから／そこで | 軽い帰結 |
| indeed / in fact | 実際 | 直前の主張の根拠を示す |
| in particular | 特に | 特殊化 |
| in general | 一般に | 一般化 |
| however / but | しかし／一方 | 逆接 |
| conversely | 逆に | 逆向きの含意 |
| on the other hand | 他方／一方 | 対比 |
| moreover / furthermore | さらに／その上 | 追加（乱用しない） |
| consequently | その結果 | 因果 |
| by Theorem X | 定理 X により／から | 根拠の引用 |

## 証明の運び

- 冒頭で示す対象を明示する：「〜を示す」。方針があれば「〜を〜によって示す」。
- 背理法：「〜と仮定して矛盾を導く」「……これは〜に矛盾する」。
- 数学的帰納法：「〜に関する帰納法で示す」「基底段階」「帰納段階」「帰納法の仮定より」。
- 場合分け：「〜の場合」「(i) …／(ii) …」。
- 結び：「以上より（主張が示された）」。証明終わりの記号は環境に任せる。

## 訳語集（分野別）

訳語はその分野で慣用されている語を選ぶ。以下は誤訳の頻出点。プロジェクト固有の語や、章内で統一したい揺れは、プロジェクト側の用語ファイル（例 `work/<name>-ja/glossary.md`）に追記して一貫させる。

### 一般（解析・代数・位相）

| 英語 | 日本語 | 英語 | 日本語 |
|---|---|---|---|
| continuous | 連続 | mapping / map | 写像 |
| convergence | 収束 | injective | 単射 |
| bounded | 有界 | surjective | 全射 |
| compact | コンパクト | bijective | 全単射 |
| neighborhood | 近傍 | sequence | 列 |
| open / closed | 開／閉 | series | 級数 |
| dense | 稠密 | measure | 測度 |
| group / ring / field | 群／環／体 | metric | 距離 |
| module | 加群 | norm | ノルム |
| ideal | イデアル | inner product | 内積 |
| homomorphism | 準同型 | eigenvalue | 固有値 |
| isomorphism | 同型 | determinant | 行列式 |
| kernel / image | 核／像 | rank | 階数 |
| subspace | 部分空間 | basis / dimension | 基底／次元 |
| span | 張る（生成する） | closure | 閉包 |

### グラフ理論・パーフェクトグラフ

| 英語 | 日本語 | 英語 | 日本語 |
|---|---|---|---|
| vertex / edge | 頂点／辺 | clique | クリーク |
| graph | グラフ | clique number ω | クリーク数 |
| directed graph | 有向グラフ | independent / stable set | 独立集合（安定集合） |
| subgraph | 部分グラフ | coloring | 彩色 |
| induced subgraph | 誘導部分グラフ | chromatic number χ | 彩色数 |
| adjacent | 隣接 | proper coloring | 真の彩色 |
| incident | 接続 | perfect graph | パーフェクトグラフ |
| degree | 次数 | chordal graph | 弦グラフ |
| path | 道（パス） | interval graph | 区間グラフ |
| cycle | 閉路（サイクル） | complement | 補グラフ |
| connected | 連結 | hole / odd hole | 穴（ホール）／奇穴 |
| component | 連結成分 | antihole | 反穴 |
| tree | 木 | complete graph | 完全グラフ |
| bipartite | 二部 | matching | マッチング |

**誤訳の罠**

- **perfect graph は「完全グラフ」ではない**。「完全グラフ」は complete graph。perfect graph は**パーフェクトグラフ**（音写が定着している）。
- stable set と independent set はどちらも「独立集合（安定集合）」。原著が使い分けていなければ訳語も統一する。
- clique number `ω` と chromatic number `χ` は記号ごと保つ。地の文でも「$\omega(G)$」「$\chi(G)$」を用いる。
- path / cycle は文脈で「道・閉路」か「パス・サイクル」かが揺れる。章内で一方に統一する。
- normal は「正規」（正規部分群、正規空間）だが、norm 由来の文脈では別語になる。原文の分野を見て選ぶ。

## LaTeX 上の注意（和訳・執筆時）

- コンパイルは LuaLaTeX + luatexja（`ltjsarticle` など）を前提にする。和文が入るとこれらが必要。
- `$...$`・`\[...\]`・`align` の中は訳さない。`\label`・`\ref`・`\cite`・`\eqref` の引数、環境名、カウンタ名は保存する。
- `\newtheorem{...}{表示名}` の**表示名だけ**和訳する（環境名は保存）。
- 図（TikZ）内のラベルに英語テキストがあれば、そのラベルだけ必要に応じて和訳し、座標・構造は変えない。
