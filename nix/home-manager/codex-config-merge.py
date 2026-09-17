#!/usr/bin/env python3
"""~/.codex/config.toml を「dotfiles のベース + codex が書いたマシン固有テーブル」で再生成する。

codex は config.toml を自分でも書き換える (ディレクトリの trust、TUI のカウンタ等)。
dotfiles の実ファイルへ symlink するとその追記が git の差分として出てしまい、
さらに codex が設定マイグレーションでファイルを丸ごと書き直すとベースごと失われる。

そこで ~/.codex/config.toml は git 管理外の実ファイルとして扱い、activation のたびに

    出力 = ベース (dotfiles, 逐語) + 既存ファイルから抜き出したマシン固有テーブル

で組み立て直す。ベースは逐語コピーなので解説コメントが消えることはなく、
trust 済みディレクトリのようなローカル状態は rebuild をまたいで残る。

ベースにもマシン固有リストにも属さないテーブルが既存ファイルにあった場合は、
黙って捨てずに警告する (codex が新しいキーを書き始めたことに気付けるように)。
"""

from __future__ import annotations

import argparse
import sys
import tomllib
from pathlib import Path


def split_first_segment(key: str) -> str:
    """ドット区切りのテーブル名から最初のセグメントを取り出す。

    [projects."/Users/me/repo"] のように引用符の中にドットやカッコが入りうるので
    単純な split(".") は使えない。
    """
    key = key.strip()
    if not key:
        return ""
    if key[0] in "\"'":
        quote = key[0]
        end = key.find(quote, 1)
        return key[1:end] if end != -1 else key[1:]
    head = key.split(".", 1)[0]
    return head.strip()


def parse_blocks(text: str) -> tuple[list[str], list[tuple[str, str, str]]]:
    """テキストを「先頭のテーブル外部分」と「テーブルごとのブロック」へ分割する。

    返り値は (preamble 行, [(トップレベル名, 完全なテーブル名, ブロック本文)])。
    複数行文字列の中の [ を見出しと誤認しないよう、三重引用符の開閉を追う。
    """
    preamble: list[str] = []
    blocks: list[tuple[str, str, str]] = []
    current: list[str] | None = None
    current_top = ""
    current_full = ""
    delim: str | None = None

    for line in text.splitlines(keepends=True):
        if delim is not None:
            # 複数行文字列の内側。閉じ記号が出るまで見出し判定をしない。
            if delim in line:
                delim = None
            (current if current is not None else preamble).append(line)
            continue

        stripped = line.lstrip()
        if stripped.startswith("["):
            inner = stripped[1:]
            if inner.startswith("["):
                inner = inner[1:]
                close = inner.find("]]")
            else:
                close = inner.find("]")
            if close != -1:
                full = inner[:close].strip()
                if current is not None:
                    blocks.append((current_top, current_full, "".join(current)))
                current = [line]
                current_top = split_first_segment(full)
                current_full = full
                continue

        for quote in ('"""', "'''"):
            if line.count(quote) % 2 == 1:
                delim = quote
                break

        (current if current is not None else preamble).append(line)

    if current is not None:
        blocks.append((current_top, current_full, "".join(current)))
    return preamble, blocks


def trim_block(body: str) -> str:
    """テーブルブロックの末尾にぶら下がった空行とコメントを落とす。

    見出しから次の見出しまでを一括で取るので、ファイル末尾のテーブルには
    そのあとに続く解説コメントまで含まれてしまう。それを引き継ぐとベースの
    コメントが二重になるため、最後の実キーより後ろは捨てる。
    """
    lines = body.splitlines()
    last = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped and not stripped.startswith("#"):
            last = i
    return "\n".join(lines[: last + 1])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", type=Path, help="dotfiles 側のベース config.toml")
    parser.add_argument("live", type=Path, help="生成先の ~/.codex/config.toml")
    parser.add_argument(
        "--local",
        default="",
        help="マシン固有として保全するトップレベルテーブル名 (カンマ区切り)",
    )
    args = parser.parse_args()

    local_names = {n.strip() for n in args.local.split(",") if n.strip()}

    base_text = args.base.read_text(encoding="utf-8")
    try:
        tomllib.loads(base_text)
    except tomllib.TOMLDecodeError as exc:
        print(f"codex: ベースの TOML が壊れている ({args.base}): {exc}", file=sys.stderr)
        return 1

    if not args.live.exists():
        args.live.parent.mkdir(parents=True, exist_ok=True)
        write_atomic(args.live, base_text)
        return 0

    live_text = args.live.read_text(encoding="utf-8")
    try:
        tomllib.loads(live_text)
    except tomllib.TOMLDecodeError as exc:
        # 壊れたファイルを解析して混ぜると被害が広がるので、触らずに知らせる。
        print(f"codex: {args.live} が TOML として壊れているので再生成を中止した: {exc}", file=sys.stderr)
        print(f"codex: 中身を確認してから `rm {args.live}` で作り直せる。", file=sys.stderr)
        return 1

    base_data = tomllib.loads(base_text)
    live_data = tomllib.loads(live_text)

    # テーブル以外のトップレベルキー (model など) はベースを正とする。
    # codex が書き換えていたら黙って戻さず、戻したことを知らせる。
    for key, value in live_data.items():
        if isinstance(value, dict):
            continue
        if key not in base_data:
            print(
                f"codex: トップレベルの {key} は dotfiles のベースに無いので捨てた。"
                " 残したいならベースに書く。",
                file=sys.stderr,
            )
        elif base_data[key] != value:
            print(
                f"codex: {key} が codex 側で {value!r} に変わっていたので"
                f" ベースの {base_data[key]!r} に戻した。",
                file=sys.stderr,
            )

    _, base_blocks = parse_blocks(base_text)
    base_tables = {full for _, full, _ in base_blocks}

    _, live_blocks = parse_blocks(live_text)
    kept: list[str] = []
    unknown: list[str] = []
    for top, full, body in live_blocks:
        if top not in local_names:
            if full not in base_tables:
                unknown.append(full)
            continue
        if full in base_tables:
            # ベースが同名テーブルを持つと重複定義になって TOML が壊れる。
            print(f"codex: [{full}] はベースにもあるので既存ファイル側を捨てた", file=sys.stderr)
            continue
        kept.append(trim_block(body))

    for full in unknown:
        print(
            f"codex: [{full}] は dotfiles のベースにもマシン固有リストにも無いので捨てた。"
            " 残したいならベースに書くか --local に追加する。",
            file=sys.stderr,
        )

    parts = [base_text.rstrip("\n")]
    if kept:
        parts.append(
            "# ------------------------------------------------------------------\n"
            "# ここから下は codex 自身が書いたマシン固有の設定。\n"
            "# dotfiles には載せず、home-rebuild のたびにこのファイルから引き継ぐ。\n"
            "# ------------------------------------------------------------------"
        )
        parts.extend(kept)

    merged = "\n\n".join(parts) + "\n"
    try:
        tomllib.loads(merged)
    except tomllib.TOMLDecodeError as exc:
        print(f"codex: 合成結果が TOML として不正なので書き込みを中止した: {exc}", file=sys.stderr)
        return 1

    if merged != live_text:
        write_atomic(args.live, merged)
    return 0


def write_atomic(path: Path, text: str) -> None:
    """codex が読んでいる最中でも壊れないよう一時ファイル + rename で置く。"""
    tmp = path.with_name(path.name + ".hm-tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


if __name__ == "__main__":
    sys.exit(main())
