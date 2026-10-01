# アイコン付きの構成図 (カード型)

白いカードにサービスのアイコンを置き、その下に説明を入れたカードを矢印でつなぐ構成図・データフロー図の作り方。役割ごとに色付きの枠で列を囲む。

- テンプレート: `assets/icon-cards.d2` (楽天 RMS 商品 API → BigQuery の例)
- アイコン: `assets/icons/`

## 進め方

1. **範囲を決める。** 参考画像は見た目の参考として扱い、図に載せる要素は依頼文や説明文から取る。参考画像にだけ写っているサービス (S3、ETL ツールなど) を勝手に足さない。範囲がはっきりしなければ先に確認する。
2. **同じ構造の行を何段も並べない。** 対象が違うだけで流れが同じなら、代表の 1 行に絞る方が読みやすい。
3. **列数から横幅を見積もる** (下の「横幅の見積もり」)。1400px を大きく超えるなら、列をまとめるか説明を短くする。
4. **テンプレートと必要なアイコンをプロジェクトにコピーする。** `.d2` と同じ階層に `icons/` を置き、`vars` から相対パスで参照する。
5. **SVG と PNG を出力し、PNG を画像として開いて確認する。** 行のずれ、アイコンと説明の距離、枠同士の隙間は、viewBox の幅だけでは分からない。

## レイアウト: 列ごとのコンテナを並べたグリッド

```d2
grid-columns: 5      # 列の数
horizontal-gap: 32   # 枠同士の隙間

search: "search：探す" {
  class: column
  style: {fill: "#eff6ff"; stroke: "#93c5fd"; border-radius: 16; font-color: "#1d4ed8"}
  item: "items.search\nキーワード等で\n商品を探す" {class: card; icon: ${rms}}
}
found: 検索結果 {
  class: column   # 色を付けない列は透明のまま見出しだけ出す
  item: "商品の一覧\n※商品情報も含む" {class: card; icon: ${list}}
}

search.item -> found.item: {class: flow}
```

- 最上位を `grid-columns: N` のグリッドにし、各列をコンテナにする。コンテナの中も `grid-rows: <行数>` のグリッドにする。
- 役割のある列 (search / get / Bronze / Silver など) は色付きの枠にし、それ以外は `fill` と `stroke` を `transparent` にする。
- **全列に同じ文字サイズの見出しを付け、全カードを同じ大きさにする。** 見出しの高さやカードの高さが列ごとに違うと、カードの縦位置がずれて矢印が斜めになる。
- **矢印は同じ行のカード同士だけをつなぐ。** グリッド内の矢印は中心と中心を結ぶ直線で、迂回しない。
- 行を増やすときは `column` クラスの `grid-rows` を増やし、全列に同じ数のカードを置く。行の名前を出したいときは、透明な列を左端に足して名前だけのノードを置く (列 1 つ分、約 200px 広がる)。
- 一部の列の間だけ隙間を変えたいときは、透明な空の列を挟む。

  ```d2
  gap: "" {
    width: 32
    style: {fill: transparent; stroke: transparent}
  }
  ```

## カード

```d2
classes: {
  column: {
    grid-rows: 1
    style: {fill: transparent; stroke: transparent; font-size: 16; bold: true; font-color: "#64748b"}
  }
  card: {
    width: 150
    height: 120
    label.near: bottom-center
    icon.near: top-center
    style: {fill: "#ffffff"; stroke: "#e2e8f0"; border-radius: 14; shadow: true; font-size: 14; font-color: "#1e293b"}
  }
  flow: {
    style: {stroke: "#64748b"; stroke-width: 2}
  }
}
```

- 説明はカードの**内側**に置く (`label.near: bottom-center`)。`outside-bottom-center` はグリッドのセルの高さに含まれるため、説明の行数が違うだけで行がずれる。
- 150 × 120 なら、アイコンと 3 行までの説明が詰まりすぎずに収まる。高さを 150 にするとアイコンと説明が離れすぎる。
- 1 行の目安は全角 9 文字まで (幅 150、文字サイズ 14 のとき)。長い説明は改行するか、下のポイント欄に回す。

## タイトルとポイント欄

```d2
title: 図のタイトル {
  shape: text
  near: top-center
  style: {font-size: 24; bold: true; font-color: "#1e293b"}
}

notes: ポイント {
  near: bottom-center
  style: {fill: "#f8fafc"; stroke: "#cbd5e1"; border-radius: 12; font-size: 15; bold: true; font-color: "#1e293b"}
  body: |md
    - 補足 1
    - 補足 2
  | {
    style.fill: transparent
    style.stroke: transparent
  }
}
```

- タイトルは `near: top-center` にする。`top-left` は図の外側の左に置かれ、その分だけ図全体が横に広がる。
- ポイント欄は「タイトル付きコンテナ + 透明な md 子ノード」にする (md ラベルを直接持たせると角丸が消える)。

## 出力設定

`.d2` の `vars` に `d2-config` を書いておくと、オプションなしの `d2 file.d2 file.svg` で同じ結果になる。

```d2
vars: {
  d2-config: {
    pad: 40
  }
}
```

## 横幅の見積もり

- グリッドのコンテナには内側に左右 60px ずつの余白が付く。この余白は変えられず、`width` を小さく指定しても縮まずに中身がはみ出る。
- 1 列 ≒ カード幅 + 120
- 全体 ≒ 列の合計 + `horizontal-gap` × (列数 − 1) + 80 (`pad: 40` の両側)
- 例: 5 列、カード幅 150、隙間 32 → 270 × 5 + 32 × 4 + 80 ≒ 1560px
- 縮める方法: 列をまとめる、行の名前の列をなくす、カード幅を 140 程度にして文字サイズを 13 にする。

## グリッドを選ぶ理由

同じ内容で試した結果。

| レイアウト | 結果 |
|---|---|
| dagre (`direction: right`) | 矢印のラベルが列 1 つ分として扱われ、横幅が倍近く (約 2400px) になった |
| ELK (`--layout=elk`) | 2 行の流れが段違いになり、矢印が折れた |
| グリッドなしで 1 行だけ | dagre でも ELK でもグリッドより広くなった |
| 列ごとのコンテナを並べたグリッド | 行がそろい、いちばん狭かった |

行がそろった流れや複数行のパイプラインにはグリッドを使う。枝分かれが多い図は dagre か ELK を使う。

## 配色の例

| 用途 | fill | stroke | 見出しの文字色 |
|---|---|---|---|
| search (探す) | `#eff6ff` | `#93c5fd` | `#1d4ed8` |
| get (取得する) | `#ecfdf5` | `#6ee7b7` | `#047857` |
| Bronze | `#fdf6ee` | `#e0b285` | `#9a5b1e` |
| Silver | `#f3f4f6` | `#a3abb8` | `#4b5563` |
| 色なしの列 | `transparent` | `transparent` | `#64748b` |

## アイコン

### 入手先

まず `assets/icons/` (下の一覧) にあるものを使う。ないものは次から取る。

| 種類 | 入手先 |
|---|---|
| GCP | Google Cloud 公式の製品アイコン: `https://raw.githubusercontent.com/AwesomeLogos/google-cloud-icons/main/docs/images/<name>.svg` (例: `cloud_run`、`secret_manager`)。`<style>` のクラス指定を `scripts/inline-svg-css.mjs` で展開してから使う |
| AWS | `https://icons.terrastruct.com/` (例: `aws%2FStorage%2FAmazon-Simple-Storage-Service-S3.svg`) |
| ブランドロゴ・言語ロゴ (単色) | simple-icons: `https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/<slug>.svg`。色が付いていないので、`data/simple-icons.json` の `hex` を見て `<svg` に `fill="#<hex>"` を足す |
| ブランドロゴ (カラー) | `https://www.vectorlogo.zone/logos/<name>/<name>-icon.svg`、または SVG Repo の `https://www.svgrepo.com/show/<id>/<name>.svg` (`/download/` の URL はタイムアウトしやすい。先頭の `<?xml ...?>` とコメントは消す) |
| 上で見つからないサービス | 公式サイトのファビコンや連携アイコンの画像 |

- terrastruct にも GCP のアイコン (六角形の旧デザイン) があるが、Secret Manager などの新しい製品がなく、`<desc>` や重複した id で PNG 出力が通らないものが多い。GCP は上の公式アイコンでそろえる。
- 同じ図の中では、GCP は GCP の公式アイコン、ブランドは simple-icons、のように入手先をそろえると見た目が統一される。

ダウンロードしてプロジェクトの `icons/` に置き、`vars` から参照する。出力した SVG にはアイコンが埋め込まれるので、SVG だけを配っても表示できる。スキルに足すときは、PNG 出力でエラーが出ないことを確かめてから `assets/icons/` に入れる。

### PNG 出力での制約

PNG 出力ではアイコンの SVG を d2 が読み込み直すため、次のものがあるとエラーになる。SVG 出力では起きないので、**早めに PNG も出力して確かめる**。

| エラーメッセージ | 原因と対処 |
|---|---|
| `element <text> has unsupported attribute "x"` | 文字が `<text>` のまま。パスに変換する (下のスクリプト) |
| `unsupported stylesheet selector` | `<style>` に `.a,.b{...}` のような複数セレクタがある。`node scripts/inline-svg-css.mjs <file>.svg` でクラス指定を各要素の `style` に展開する |
| `unsupported style property "isolation"` | 見た目に関係ないプロパティ。消す |
| `unknown element <desc>` | `<desc>` 要素を消す |
| `duplicate id` | 同じ id が複数ある。別のアイコンを探す方が早い |

文字をパスに変換するスクリプト (作業用ディレクトリで `npm install opentype.js@1` してから実行する)。

```js
// topath.mjs: 中央揃えの文字列を SVG の path データにして出力する
import opentype from 'opentype.js';
const font = opentype.loadSync('/System/Library/Fonts/Supplemental/Arial Bold.ttf');
const text = 'RMS', size = 36, centerX = 50, baselineY = 50;
const width = font.getAdvanceWidth(text, size);
console.log(font.getPath(text, centerX - width / 2, baselineY, size).toPathData(2));
```

### 大きさ

- カードの中のアイコンの大きさは d2 が決める。アイコンの SVG に余白が多いと小さく見えるので、`viewBox` を中身ぎりぎりに詰める。

### 同梱しているアイコン (`assets/icons/`)

すべて PNG 出力で確認済み。

| 種類 | ファイル | 入手先・加工 |
|---|---|---|
| GCP | `cloud-run.svg`、`cloud-sql.svg`、`cloud-scheduler.svg`、`cloud-tasks.svg`、`cloud-logging.svg`、`secret-manager.svg`、`bigquery.svg` | Google Cloud 公式の製品アイコン。`<style>` を展開済み |
| ホスティング・データストア | `firebase.svg`、`vercel.svg`、`upstash.svg` (Upstash Redis) | simple-icons にブランド色を付けたもの |
| | `redis.svg` | SVG Repo の旧ロゴ (赤い積み重ね)。simple-icons の新ロゴ「R」より Redis とわかりやすいため |
| 監視・IaC | `sentry.svg`、`terraform.svg` | 同上 |
| 言語 | `typescript.svg`、`go.svg`、`rust.svg` | 同上 |
| 楽天 | `rakuten-rms.svg` | 自作。「RMS」の文字はパス化済み、R マークは simple-icons |
| 汎用 | `id-list.svg` | 自作の線画 (一覧・リスト) |
