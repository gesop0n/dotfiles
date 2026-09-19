---
name: d2-diagrams
description: D2 CLI を使用して、D2ダイアグラムの作成・編集・レンダリングを行う。ユーザーが次のような図や可視化を求めた場合に使用する。ダイアグラムの作成、アーキテクチャ図、ER図(ERD)、シーケンス図、フローチャート、グリッドレイアウト、その他宣言的に記述できる図表。次のようなフレーズが含まれているリクエストをトリガーとする。「D2ダイアグラム」「図を作成して」「アーキテクチャ図」「シーケンス図」「ERD」「フローチャート」「描画して」「可視化して」
---

# D2 Diagrams

[D2 宣言的ダイアグラム言語](https://d2lang.com) を用いて図の作成・編集・レンダリングを行う。

## 概要

D2 (Declarative Diagramming) はテキストから図を生成するスクリプト言語。描画したい内容を記述すると、D2 CLI が SVG または PNG を生成する。本スキルが扱う範囲は以下のとおり。

- D2 CLI のインストール
- D2 ソースファイル (`.d2`) の記述
- SVG / PNG へのレンダリング
- D2 の全機能: シェイプ、コネクション、コンテナ、SQL テーブル、UML クラス、シーケンス図、グリッド図、アイコン、テーマ、スタイル、変数、グロブ、レイヤー、シナリオ、ステップ

## 使用する場面

- あらゆる種類の図の作成・編集を求められた場合
- アーキテクチャ図、システム設計図、ネットワークトポロジ
- SQL テーブルを用いた ER 図 (ERD)
- UML クラス図
- API フローやプロトコルのシーケンス図
- フローチャートやプロセス図
- ダッシュボードや比較表のためのグリッドレイアウト
- 「d2」「ダイアグラム」「可視化」「描画」「アーキテクチャ」に言及するリクエスト全般

## 前提条件: D2 のインストール

図を作成する前に、D2 がインストール済みかを確認する。

```bash
d2 version
```

未インストールの場合は、ユーザーにインストールを促して終了する

## ワークフロー

### ステップ 1: D2 ソースの記述

図の定義を記述した `.d2` ファイルを作成する。構文の詳細は `references/D2_LANGUAGE_REFERENCE.md` の言語リファレンスを参照する。

### ステップ 2: 図のレンダリング

```bash
# SVG へレンダリング (デフォルト、パディング付き)
d2 --pad=40 input.d2 output.svg

# 幅が妥当か検証する (ノート PC 向けには 1400px 未満)
rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg

# PNG へレンダリング
d2 --pad=40 input.d2 output.png

# テーマを指定する (ID は 0 始まり。一覧は `d2 themes` で確認)
d2 --theme=200 input.d2 output.svg

# ダークテーマ対応
d2 --dark-theme=200 input.d2 output.svg

# 手書き風 (スケッチ) スタイル
d2 --sketch input.d2 output.svg

# レイアウトエンジンを指定する (dagre, elk, tala)
d2 --layout=elk input.d2 output.svg

# パディングの指定 (推奨デフォルトは 40)
d2 --pad=60 input.d2 output.svg

# ウォッチモード (ライブリロード付きでブラウザを開く)
d2 --watch input.d2 output.svg
```

### ステップ 3: 反復

`.d2` ファイルを修正して再レンダリングする。対話的に開発する場合は `--watch` を使う。

## クイックリファレンス

### シェイプ
```d2
# 基本シェイプ (デフォルトは矩形)
my_shape
labeled_shape: My Label

# シェイプの種類指定
db: Database {shape: cylinder}
user: User {shape: person}
decision: Choice {shape: diamond}
q: Queue {shape: queue}
pg: Package {shape: package}
doc: Document {shape: document}
oval_shape: Oval {shape: oval}
circle_shape: Circle {shape: circle}
hexagon_shape: Hex {shape: hexagon}
cloud_shape: Cloud {shape: cloud}
```

### コネクション
```d2
# 矢印の種類
a -> b: forward
b <- a: backward
a <-> b: bidirectional
a -- b: undirected

# チェイン
a -> b -> c -> d

# 同じ組み合わせを繰り返すと並列のエッジになる
a -> b: first
a -> b: second
```

### コンテナ (ネスト)
```d2
server: Backend Server {
  api: REST API
  db: Database {shape: cylinder}
  api -> db: queries
}
```

### スタイル
```d2
x: Shape {
  style: {
    fill: "#f0f0f0"
    stroke: "#333333"
    stroke-width: 2
    stroke-dash: 5
    border-radius: 8
    shadow: true
    opacity: 0.9
    font-size: 16
    font-color: "#000"
    bold: true
    italic: false
    animated: true
    3d: true
    multiple: true
    double-border: true
    fill-pattern: dots
  }
}
```

### アイコン
```d2
server: Backend {
  icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}

# アイコン単体のシェイプ
github: GitHub {
  shape: image
  icon: https://icons.terrastruct.com/dev%2Fgithub.svg
}
```

### SQL テーブル
```d2
users: {
  shape: sql_table
  id: int {constraint: primary_key}
  name: varchar(255)
  email: varchar(255) {constraint: unique}
  created_at: timestamp
}
```

### シーケンス図
```d2
shape: sequence_diagram
alice -> bob: Hello
bob -> alice: Hi back
alice -> bob: How are you?
bob -> alice: Good, thanks!
```

### グリッド図
```d2
grid: {
  grid-rows: 2
  grid-columns: 3
  cell1: A
  cell2: B
  cell3: C
  cell4: D
  cell5: E
  cell6: F
}
```

### 変数
```d2
vars: {
  primary-color: "#4A90D9"
  server-icon: https://icons.terrastruct.com/essentials%2F112-server.svg
}
server: Backend {
  icon: ${server-icon}
  style.fill: ${primary-color}
}
```

### グロブ (グローバルパターン)
```d2
# すべてのシェイプにスタイルを適用する
*.style.fill: "#f0f0f0"
*.style.border-radius: 8

# すべてのコネクションにスタイルを適用する
(* -> *)[*].style.stroke-dash: 3

# 再帰グロブ
**.style.font-size: 14
```

### 方向 (direction)
```d2
direction: down  # 推奨デフォルト。図が横に広がりにくい
# 指定可能な値: up, down, left, right
# 'right' は明示的に横方向のフロー (タイムライン、パイプライン) にのみ使う

a -> b -> c
```

### テーマ

利用可能なテーマは `d2 themes` で一覧できる。代表的なテーマ ID は以下のとおり。

- `0` - Default
- `1` - Neutral default
- `3` - Mixed berry blue
- `4` - Grape soda
- `5` - Aubergine
- `6` - Colorblind clear
- `8` - Vanilla nitro cola
- `100` - Origami
- `200` - Dark Mauve (ターミナル風)
- `300` - Terminal (ダーク、等幅、大文字)
- `301` - Terminal Grayscale
- `302` - Retro

ダークテーマ:

- `200` - Dark Mauve
- `201-208` - 各種ダークテーマ

### コンポジション (マルチボード)
```d2
# ルートボード
a -> b

# レイヤー (独立したボード)
layers: {
  detail: {
    x -> y -> z
  }
}

# シナリオ (ベースを継承する)
scenarios: {
  error: {
    a.style.fill: red
    a -> c: error path
  }
}

# ステップ (直前のステップを継承する)
steps: {
  step1: {
    a -> b
  }
  step2: {
    b -> c
  }
}
```

### クラス (再利用可能なスタイル)
```d2
classes: {
  server: {
    shape: rectangle
    style: {
      fill: "#dceefb"
      stroke: "#4A90D9"
      border-radius: 8
    }
  }
  database: {
    shape: cylinder
    style: {
      fill: "#e8f5e9"
      stroke: "#66bb6a"
    }
  }
}

api: API Server {class: server}
db: PostgreSQL {class: database}
api -> db
```

### 矢印の先端 (arrowhead)
```d2
a -> b: {
  source-arrowhead: {
    shape: diamond
  }
  target-arrowhead: {
    shape: arrow
    label: "1..*"
  }
}

# arrowhead のシェイプ: triangle, arrow, diamond, circle, cf-one, cf-one-required, cf-many, cf-many-required
```

### ラベル内の Markdown とコード
```d2
explanation: |md
  # Architecture Overview
  - **Frontend**: React SPA
  - **Backend**: Go microservices
  - **Database**: PostgreSQL
|

code_block: |go
  func main() {
    fmt.Println("Hello")
  }
|
```

## 幅のコントロール

図の幅は最も頻出する問題。D2 の dagre レイアウトは兄弟ノードを横並びに配置するため、図はすぐに画面幅を超える。**常に 1400px 未満を目標**にし、ノート PC でも読めるようにする。

### 基本原則

1. **`direction: down` を使う** (`right` ではなく)。縦方向に積む方が幅は狭くなる。
2. **同じ深さの兄弟ノードを減らす。** ピアノードが 1 つ増えるごとに横幅が増える。兄弟として宣言するのではなく、コネクション (`a -> b -> c`) で縦につなぐ。
3. **レンダリングのたびに SVG の幅を検証する。** D2 は出力が横に広すぎても警告しない。
   ```bash
   # viewBox の幅を確認する ("0 0" の次の最初の数値が幅)
   rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg
   ```

### コンテナの幅問題

子を複数持つネストしたコンテナが、幅の肥大化の最大の原因。dagre はコンテナ内の子を横に並べるため、子が 4 つあるコンテナは 4 カラム分の幅になる。

**悪い例** — 子が 4 つ横並びになり、非常に横長になる。
```d2
services: Backend {
  api: API Gateway
  auth: Auth Service
  core: Core API
  worker: Worker
}
```

**良い例** — 「タイトル付きコンテナ + 透明な markdown 子ノード」パターンを使う。コンテナのラベルが適切な `border-radius` を持つ見出しとして機能し、単一の不可視の子が markdown の本文を保持する。
```d2
services: Backend Services {
  style.fill: "#e8f5e9"
  style.stroke: "#4caf50"
  style.border-radius: 10

  details: |md
- API Gateway (:3000)
- Auth Service (JWT)
- Core API (business logic)
- Background Worker (cron)
| {
    style.fill: transparent
    style.stroke: transparent
  }
}
```

このパターンにより、角丸コンテナの見た目を保ったまま、内容を 1 つの細いボックスにまとめられる。

### Markdown ラベルと border-radius

**落とし穴:** ノードのラベルが markdown (`|md ... |`) の場合、D2 は内容を `foreignObject` 内にレンダリングし、SVG の `<rect>` は `rx="0"` になる。つまりクラスやインラインスタイルで指定しても、**外側のシェイプで `border-radius` が無視される**。プレーンテキストのラベルであれば `border-radius` は正しく反映される。

**回避策:** 上記のタイトル付きコンテナパターンを使う。親コンテナにはプレーンテキストのラベル (これは `border-radius` が正しく効く) を与え、markdown は内側の透明な子ノードに置く。

### シーケンス図の幅

シーケンス図の幅はアクター数に比例し、`direction` やレイアウトでは制御できない。幅を減らす唯一の方法は**関連するアクターをまとめる**こと。

```d2
# 横長 — アクター 5 つ
shape: sequence_diagram
user: User
ios: iOS App
llm: On-Device LLM
server: Server
db: Database

# 幅を抑えた形 — アクター 3 つ (ios+llm、server+db をマージ)
shape: sequence_diagram
user: User
ios: iOS (App + LLM)
server: Server (+ DB)
```

### その他の幅対策

- **ラベルを短くする。** 1 文字単位で効いてくる。略称を使う。
- **`--pad=40` を使う。** レイアウト幅を変えずに余白を確保できる。
- **ノードを直線的につなぐ** (`a -> b -> c`)。dagre が横並びではなく縦積みに配置するよう仕向ける。
- あらゆる最適化を施してもまだ横長な場合は、レイアウトエンジンと戦うのではなく**図を 2 つに分割する**。

## 既知の落とし穴

- **`@` プレフィックスは D2 の import 構文。** `@github/copilot-sdk` や `@MainActor` のようなラベルは import として解釈される。クォートで囲むか、表現を変える: `"@github/copilot-sdk"` あるいは単に `Copilot SDK`。
- **シーケンス図はコネクションへの `style` ブロックをサポートしない。** 通常の図と異なり、シーケンス図では個々の矢印にスタイルを付けられず、レンダリングが失敗する。シーケンス図のコネクションからは `style.stroke`、`style.stroke-width` などを削除する。
- **Markdown ラベルでは `border-radius` が失われる** (上記「幅のコントロール」を参照)。
- **dagre レイアウトはピアノードに対して非決定的。** 同じ `.d2` ファイルを再レンダリングすると幅がわずかに変わることがある。再レンダリング後は必ず検証する。

## ベストプラクティス

1. **意味のあるキーを使う**: `box1` ではなく `api_server`。キーはデフォルトのラベルになる。
2. **`direction: down` をデフォルトにする**: 縦方向のレイアウトの方が画面に収まりやすい。`right` は明示的に横方向のフロー (タイムライン、パイプライン) にのみ使う。
3. **タイトル付きコンテナ + 透明な md 子ノードパターンを使う**: 角丸とリッチな内容の両方が必要なノードに適用する (「幅のコントロール」を参照)。
4. **一貫性のためにクラスを使う**: `classes:` で再利用可能なスタイルを定義する。
5. **デフォルト値にはグロブを使う**: 個々のシェイプにスタイルを書くのではなく `*.style.border-radius: 8` を設定する。
6. **色には変数を使う**: `vars:` にパレットを定義しておくとテーマ変更が容易になる。
7. **アイコンを使う**: https://icons.terrastruct.com のアイコンを使うと図がプロフェッショナルに仕上がる。
8. **適切なレイアウトを選ぶ**: 階層構造には `dagre` (デフォルト)、複雑なグラフには `elk`。
9. **可読性を保つ**: 複雑な図ではネスト構文とインデントを使う。
10. **コンポジションを使う**: 複雑な図はレイヤー、シナリオ、ステップに分割する。
11. **常に `--pad=40` でレンダリングする**: 図に余白を与える。デフォルトのパディングは狭すぎる。
12. **レンダリングのたびに幅を検証する**: SVG の viewBox を確認する。ノート PC 向けには 1400px 未満を目標にする。

## レンダリングのコツ

- **常に `--pad=40` を使う**: 図の周囲に十分な余白を確保する。デフォルトは狭すぎる。
- **レンダリング後は必ず幅を検証する**:
  ```bash
  d2 --pad=40 input.d2 output.svg
  rg -o 'viewBox="0 0 ([0-9]+)' -r '$1' output.svg  # 1400 未満であること
  ```
- **SVG がデフォルトかつ最適な形式**: Web への埋め込みとスケーラビリティに向く。
- **PNG** はドキュメントや Slack などへの埋め込みに向く。
- **`--theme` を使う**: プレゼンテーションに耐える仕上がりになる。
- **`--sketch` を使う**: 手書き風のカジュアルな見た目になる。
- **アニメーション SVG**: コンポジションと組み合わせて `--animate-interval=1200` を使う。

## トラブルシューティング

- **"d2: command not found"**: D2 が未インストール。上記のインストール手順に従う。
- **レイアウトが崩れる**: 別のレイアウトエンジンを試す (`--layout=elk` または `--layout=tala`)。
- **ラベルが重なる**: ラベルを短くする、`font-size` を調整する、別のレイアウトを使う。
- **図が横に広すぎる**: 「幅のコントロール」を参照。最も可能性が高い原因は、子を多数持つネストしたコンテナ。
- **markdown ボックスの角が角張る**: `border-radius` は `|md ... |` ラベルには適用されない。タイトル付きコンテナ + 透明な md 子ノードパターンを使う。
- **シーケンス図のスタイルでレンダリングが失敗する**: シーケンス図はコネクションへの `style` ブロックをサポートしない。削除する。
- **`@` が import として解釈される**: `@` を含むラベルはクォートするか表現を変える (例: `"@MainActor"`)。

## 追加リファレンス

- `references/D2_LANGUAGE_REFERENCE.md` - 完全な言語構文リファレンス
- `references/D2_PATTERNS.md` - よくある図のパターンとテンプレート
- `assets/` - すぐに使える `.d2` テンプレートの例
- 公式ドキュメント: https://d2lang.com/tour/intro/
- プレイグラウンド: https://play.d2lang.com
- アイコン: https://icons.terrastruct.com
