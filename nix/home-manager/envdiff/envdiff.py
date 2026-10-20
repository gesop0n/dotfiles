#!/usr/bin/env python3
"""2 つの dotenv ファイル (.env と .env.local など) をキー単位で比べる。

普通の diff だと並び順・コメント・引用符の書き方の違いまで差分に出るうえ、
秘密情報の値がそのまま画面 (や AI エージェントの会話ログ) に残る。
envdiff はキーごとに「片方にしか無い / 値が違う / 一致」と「空かどうか」だけを示し、
値そのものは決して表示しない。表示させるオプションも作らない。

値を出さないことは「表示しないよう気を付ける」ではなく、作りで保証する:
  - 生の値は _scan と parse_text の中でしか扱わない。外へ渡すのは「空かどうか」と、
    実行ごとのランダムな鍵で取ったハッシュだけ。表示する側には値が届かない。
  - 警告・エラーのメッセージに行の中身を入れない (ファイル名・行番号・キー名だけ)。
  - 想定外の例外はメッセージを出さず、例外の型名だけを出す。

ただしキー名は表示する。引用符で囲まずに複数行の値を書いた壊れたファイルでは、
値の断片が `XXXX=` の形 (base64 のパディングなど) になってキーと区別できず、
キー名として表示されうる。これは dotenv の書式上どうにもならない。
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import secrets
import sys
from collections import Counter
from dataclasses import dataclass, field

# --help に出す解釈のしかた。dotenv には標準仕様が無く、Node の dotenv /
# python-dotenv / docker compose で細部が違うので、どれでもほぼ同じに読める範囲に絞る。
_RULES = """\
解釈のしかた:
  KEY=VALUE        先頭の `export ` と `=` 前後の空白は許す
                   キーは英数字と _ だけ (先頭は数字以外)
  # ...            `#` で始まる行はコメント
  KEY=value # ...  引用符なしの値は「空白 + #」以降がコメント。前後の空白は落とす
  KEY='...'        書いたまま。複数行にまたがってよい
  KEY="..."        \\n \\r \\t \\" \\\\ を解釈する。複数行にまたがってよい
  ${VAR}           展開しない (書かれたまま比べる)
  同じキーが複数回あれば後ろの定義を使い、警告を出す。読めない行は警告を出して飛ばす。

終了コード: 0 差分なし / 1 差分あり / 2 エラー
"""

# 値の比較にだけ使うハッシュの鍵。実行ごとに作り直すので、万一ハッシュが表示に
# 紛れ込んでも、短い値を総当たりして元の値を割り出すことはできない。
_RUN_KEY = secrets.token_bytes(32)

# キーはシェルの変数名と同じ規則に絞る。Node の dotenv は . や - も許すが、
# 許す文字を増やすほど、壊れた行に入っている値の断片をキーと誤認しやすくなる。
_ASSIGNMENT = re.compile(r"\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=(.*)")

# "..." の中で解釈するエスケープ。どの実装でも同じ意味になるものだけ。
_ESCAPES = {"n": "\n", "r": "\r", "t": "\t", '"': '"', "\\": "\\"}

_COLORS = {"-": "31", "+": "32", "~": "33", "=": "2"}


class EnvdiffError(Exception):
    """利用者に見せて終了するエラー。メッセージに値の中身を入れないこと。"""


class _BadValue(Exception):
    """値を読めなかった。メッセージは固定の文言で、値の中身は入れない。"""


@dataclass(frozen=True)
class Entry:
    """1 つのキーについて、比較と表示に要るものだけを持つ。生の値は持たない。"""

    lineno: int
    empty: bool
    digest: bytes = field(repr=False)


@dataclass(frozen=True)
class Change:
    """1 つのキーの比較結果。mark は - (左にだけある) + (右にだけある) ~ (値が違う) = (一致)。"""

    mark: str
    key: str
    note: str = ""


def _digest(value: str) -> bytes:
    return hashlib.blake2b(value.encode("utf-8"), key=_RUN_KEY).digest()


def _closing_quote(segment: str, quote: str) -> int | None:
    r"""segment の中で値を閉じる引用符の位置を返す。無ければ None。

    '...' はエスケープを持たないので次の ' で閉じる。
    "..." は \ の直後の文字を飛ばす (\" では閉じない)。
    """
    if quote == "'":
        end = segment.find("'")
        return None if end == -1 else end
    i = 0
    while i < len(segment):
        if segment[i] == "\\":
            i += 2
        elif segment[i] == '"':
            return i
        else:
            i += 1
    return None


def _read_value(rest: str, lines: list[str], start: int) -> tuple[str, int]:
    """`=` より後ろ (rest) を値として読む。返り値は (値, 使った行数)。

    引用符で囲まれた値は複数行にまたがってよいので、閉じ引用符が見つかるまで
    lines[start] より後ろの行も読み進める。
    """
    body = rest.lstrip()
    if not body or body[0] not in "'\"":
        # 「空白 + #」以降はコメント。`COLOR=#fff` のように値の先頭に直接付いた
        # # はコメントとみなさない (python-dotenv / docker compose と同じ)。
        comment = re.search(r"\s#", rest)
        return (rest[: comment.start()] if comment else rest).strip(), 1

    quote = body[0]
    chunks: list[str] = []
    segment = body[1:]
    i = start
    while (end := _closing_quote(segment, quote)) is None:
        chunks.append(segment)
        i += 1
        if i == len(lines):
            raise _BadValue("閉じ引用符が無い")
        segment = lines[i]
    chunks.append(segment[:end])

    trailing = segment[end + 1 :].lstrip()
    if trailing and not trailing.startswith("#"):
        raise _BadValue("閉じ引用符の後ろに余分な文字がある")

    value = "\n".join(chunks)
    if quote == '"':
        value = re.sub(r"\\(.)", lambda m: _ESCAPES.get(m[1], m[0]), value, flags=re.DOTALL)
    return value, i - start + 1


def _scan(text: str, path: str) -> tuple[list[tuple[int, str, str]], list[str]]:
    """テキストを (行番号, キー, 生の値) の並びに分解し、警告と一緒に返す。

    生の値を返すのはここだけで、受け取ってよいのは parse_text (とテスト) だけ。
    読めない行は警告を積んで飛ばす。警告には行の中身を入れない。
    """
    lines = text.replace("\r\n", "\n").split("\n")
    assignments: list[tuple[int, str, str]] = []
    warnings: list[str] = []
    defined_at: dict[str, int] = {}
    i = 0
    while i < len(lines):
        lineno = i + 1
        stripped = lines[i].strip()
        if not stripped or stripped.startswith("#"):
            i += 1
            continue

        match = _ASSIGNMENT.fullmatch(lines[i])
        if match is None:
            warnings.append(f"{path}:{lineno}: KEY=VALUE の形になっていない行を飛ばした")
            i += 1
            continue

        key, rest = match[1], match[2]
        try:
            value, used = _read_value(rest, lines, i)
        except _BadValue as exc:
            # 閉じ引用符が無いときに残り全部を値として飲み込まないよう、次の行から読み直す。
            warnings.append(f"{path}:{lineno}: {key} の値を読めないので飛ばした ({exc})")
            i += 1
            continue

        if key in defined_at:
            warnings.append(
                f"{path}:{lineno}: {key} が {defined_at[key]} 行目にもあるので、後ろの定義を使う"
            )
        defined_at[key] = lineno
        assignments.append((lineno, key, value))
        i += used
    return assignments, warnings


def parse_text(text: str, path: str) -> tuple[dict[str, Entry], list[str]]:
    """dotenv のテキストをキーごとの Entry にする。生の値はここで捨てる。

    同じキーが複数回あれば後ろの定義を使う。並び順は最初に出てきた位置のまま。
    """
    assignments, warnings = _scan(text, path)
    entries = {
        key: Entry(lineno, value == "", _digest(value)) for lineno, key, value in assignments
    }
    return entries, warnings


def read_env(path: str) -> tuple[dict[str, Entry], list[str]]:
    try:
        # utf-8-sig: 先頭に BOM があれば落とす (Windows のエディタで保存したファイルなど)
        with open(path, encoding="utf-8-sig") as f:
            text = f.read()
    except UnicodeDecodeError:
        raise EnvdiffError(f"{path}: UTF-8 として読めない") from None
    except OSError as exc:
        raise EnvdiffError(f"{path}: 読めない ({exc.strerror or type(exc).__name__})") from None
    return parse_text(text, path)


def compare(
    left: dict[str, Entry], right: dict[str, Entry], *, keys_only: bool = False
) -> list[Change]:
    """キーごとに比べ、削除 → 追加 → 変更 → 一致 の順に並べる。各グループ内はファイルの並び順。"""
    removed: list[Change] = []
    changed: list[Change] = []
    same: list[Change] = []
    for key, a in left.items():
        b = right.get(key)
        if b is None:
            removed.append(Change("-", key, "（空）" if a.empty else ""))
        elif keys_only or a.digest == b.digest:
            same.append(Change("=", key, "（空）" if a.empty and b.empty else ""))
        elif a.empty:
            changed.append(Change("~", key, "空 → 値あり"))
        elif b.empty:
            changed.append(Change("~", key, "値あり → 空"))
        else:
            changed.append(Change("~", key, "値が違う"))
    added = [Change("+", key, "（空）" if b.empty else "") for key, b in right.items() if key not in left]
    return removed + added + changed + same


def render(
    left_path: str, right_path: str, changes: list[Change], *, show_same: bool, color: bool
) -> str:
    """比較結果を表示用の文字列にする。"""

    def paint(code: str, text: str) -> str:
        return f"\033[{code}m{text}\033[0m" if color else text

    shown = [c for c in changes if show_same or c.mark != "="]
    width = max((len(c.key) for c in shown), default=0)
    lines = [paint("1", f"--- {left_path}"), paint("1", f"+++ {right_path}")]
    for c in shown:
        lines.append("  " + paint(_COLORS[c.mark], f"{c.mark} {c.key.ljust(width)}  {c.note}".rstrip()))

    counts = Counter(c.mark for c in changes)
    total = counts["+"] + counts["-"] + counts["~"]
    if total:
        summary = f"差分 {total}（追加 {counts['+']} / 削除 {counts['-']} / 変更 {counts['~']}）"
    else:
        summary = "差分なし"
    if show_same:
        summary += f"、一致 {counts['=']}"
    if shown:
        lines.append("")
    lines.append(summary)
    return "\n".join(lines) + "\n"


def _run(argv: list[str] | None) -> int:
    parser = argparse.ArgumentParser(
        prog="envdiff",
        description="2 つの dotenv ファイルをキー単位で比べる。値は表示しない。",
        epilog=_RULES,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("left", metavar="FILE_A", help="比べる元 (例: .env)")
    parser.add_argument("right", metavar="FILE_B", help="比べる先 (例: .env.local)")
    parser.add_argument("-a", "--all", action="store_true", help="一致したキーも表示する")
    parser.add_argument(
        "-k", "--keys-only", action="store_true", help="キーの有無だけ比べる (値の違いは無視する)"
    )
    args = parser.parse_args(argv)

    try:
        left, left_warnings = read_env(args.left)
        right, right_warnings = read_env(args.right)
    except EnvdiffError as exc:
        print(f"envdiff: {exc}", file=sys.stderr)
        return 2
    for warning in left_warnings + right_warnings:
        print(f"envdiff: 警告: {warning}", file=sys.stderr)

    changes = compare(left, right, keys_only=args.keys_only)
    color = sys.stdout.isatty() and not os.environ.get("NO_COLOR")
    sys.stdout.write(render(args.left, args.right, changes, show_same=args.all, color=color))
    return 1 if any(c.mark != "=" for c in changes) else 0


def main(argv: list[str] | None = None) -> int:
    try:
        return _run(argv)
    except Exception as exc:
        # 想定外の例外のメッセージには値の断片が入っているかもしれない。型名だけ出す。
        print(f"envdiff: 内部エラー ({type(exc).__name__})", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
