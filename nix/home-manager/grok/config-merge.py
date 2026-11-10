#!/usr/bin/env python3
"""~/.grok/config.toml に dotfiles で管理する値を深いマージで流し込む。

grok は config.toml を自分でも書き換える ([marketplace] や [ui]、`grok mcp add` の
[mcp_servers.*] など) ので、dotfiles の実ファイルへ symlink にはできない。
claude.nix が ~/.claude/settings.json に `jq '. * managed'` で値を重ねるのと同じ発想で、
activation のたびに

    出力 = 既存ファイル (grok が書いたものを全部残す) + 管理する値 (管理する側が勝つ)

を作り直す。管理する値は Nix の attrset を JSON にしたものを引数で受け取る。
テーブル同士は再帰的に合成し、それ以外の値は管理する側で上書きする。
解析した結果が既存と同じなら書き込まない (grok 側の整形を無駄に崩さないため)。

管理をやめた値は消さない (claude.nix と同じ)。消したいときは手で config.toml を直す。
"""

from __future__ import annotations

import argparse
import json
import sys
import tomllib
from pathlib import Path

import tomli_w


def deep_merge(base: dict, override: dict) -> dict:
    """base に override を重ねた新しい dict を返す。両方テーブルのキーだけ再帰する。"""
    merged = dict(base)
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = deep_merge(merged[key], value)
        else:
            merged[key] = value
    return merged


def write_atomic(path: Path, text: str) -> None:
    """grok が読んでいる最中でも壊れないよう一時ファイル + rename で置く。"""
    tmp = path.with_name(path.name + ".hm-tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("live", type=Path, help="更新先の ~/.grok/config.toml")
    parser.add_argument("managed_json", help="重ねる値 (JSON オブジェクト)")
    args = parser.parse_args()

    try:
        managed = json.loads(args.managed_json)
    except json.JSONDecodeError as exc:
        print(f"grok: 管理する値の JSON が壊れている: {exc}", file=sys.stderr)
        return 1
    if not isinstance(managed, dict):
        print("grok: 管理する値は JSON オブジェクトでなければならない", file=sys.stderr)
        return 1

    if args.live.exists():
        live_text = args.live.read_text(encoding="utf-8")
        try:
            live_data = tomllib.loads(live_text)
        except tomllib.TOMLDecodeError as exc:
            # 壊れたファイルを解析して混ぜると被害が広がるので、触らずに知らせる。
            print(f"grok: {args.live} が TOML として壊れているので更新を中止した: {exc}", file=sys.stderr)
            return 1
    else:
        live_data = {}

    merged = deep_merge(live_data, managed)
    if merged == live_data:
        return 0

    try:
        text = tomli_w.dumps(merged)
        tomllib.loads(text)
    except (TypeError, ValueError, tomllib.TOMLDecodeError) as exc:
        print(f"grok: 合成結果を TOML にできないので書き込みを中止した: {exc}", file=sys.stderr)
        return 1

    args.live.parent.mkdir(parents=True, exist_ok=True)
    write_atomic(args.live, text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
