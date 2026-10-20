"""dotenv の解釈のテスト。

生の値を確かめるため、ここでは内部関数の _scan を直接呼ぶ。
本体で生の値を受け取るのは parse_text だけで、表示する側には届かない。
"""

import dataclasses
import hashlib

import pytest

import envdiff


def values(text: str) -> dict[str, str]:
    assignments, _ = envdiff._scan(text, "t.env")
    return {key: value for _, key, value in assignments}


def warnings(text: str) -> list[str]:
    _, found = envdiff._scan(text, "t.env")
    return found


def digest_of(text: str) -> bytes:
    entries, _ = envdiff.parse_text(text, "t.env")
    return entries["FOO"].digest


@pytest.mark.parametrize(
    ("line", "expected"),
    [
        ("FOO=bar", "bar"),
        ("export FOO=bar", "bar"),
        ("  FOO = bar  ", "bar"),
        ("FOO=bar # コメント", "bar"),
        ("FOO=a#b", "a#b"),
        ("FOO=#fff", "#fff"),
        ("FOO=a=b", "a=b"),
        ("FOO=${BAR}", "${BAR}"),
        ("FOO=", ""),
        ("FOO= # コメント", ""),
        ("FOO=''", ""),
        ('FOO=""', ""),
        ("FOO=' bar '", " bar "),
        ("FOO='a # b' # コメント", "a # b"),
        ('FOO="a # b"# コメント', "a # b"),
        ("FOO='a\\nb'", "a\\nb"),
        ('FOO="a\\nb"', "a\nb"),
        ('FOO="a\\tb"', "a\tb"),
        ('FOO="say \\"hi\\""', 'say "hi"'),
        ('FOO="a\\\\nb"', "a\\nb"),
        ('FOO="a\\xb"', "a\\xb"),
    ],
)
def test_value(line, expected):
    assert values(line) == {"FOO": expected}
    assert warnings(line) == []


def test_quoted_value_can_span_lines():
    text = 'CERT="-----BEGIN-----\nAB==\nKEY=not-a-key\n-----END-----"\nNEXT=1\n'
    assert values(text) == {"CERT": "-----BEGIN-----\nAB==\nKEY=not-a-key\n-----END-----", "NEXT": "1"}


def test_single_quoted_value_can_span_lines():
    assert values("FOO='a\nb'\nNEXT=1\n") == {"FOO": "a\nb", "NEXT": "1"}


def test_comments_and_blank_lines_are_skipped():
    text = "# FOO=1\n\n   \n  # BAR=2\nBAZ=3\n"
    assert values(text) == {"BAZ": "3"}
    assert warnings(text) == []


def test_crlf_line_endings():
    assert values("FOO=bar\r\nBAZ='qux'\r\n") == {"FOO": "bar", "BAZ": "qux"}


@pytest.mark.parametrize(
    ("line", "message"),
    [
        ("just text", "t.env:1: KEY=VALUE の形になっていない行を飛ばした"),
        ("1FOO=bar", "t.env:1: KEY=VALUE の形になっていない行を飛ばした"),
        ("my.key=bar", "t.env:1: KEY=VALUE の形になっていない行を飛ばした"),
        ('FOO="bar', "t.env:1: FOO の値を読めないので飛ばした (閉じ引用符が無い)"),
        ("FOO='bar' baz", "t.env:1: FOO の値を読めないので飛ばした (閉じ引用符の後ろに余分な文字がある)"),
    ],
)
def test_unreadable_line_is_skipped_with_warning(line, message):
    # 閉じ引用符が無くても、後ろの行まで飲み込まずに読み続ける
    text = line + "\nOK=1\n"
    assert values(text) == {"OK": "1"}
    assert warnings(text) == [message]


def test_duplicate_key_uses_last_definition():
    entries, found = envdiff.parse_text("FOO=first\nBAR=1\nFOO=\n", "t.env")
    assert list(entries) == ["FOO", "BAR"]
    assert entries["FOO"].lineno == 3
    assert entries["FOO"].empty
    assert found == ["t.env:3: FOO が 1 行目にもあるので、後ろの定義を使う"]


@pytest.mark.parametrize("line", ["FOO='bar'", 'FOO="bar"', "export FOO=bar", "FOO = bar # コメント"])
def test_same_value_written_differently_is_equal(line):
    assert digest_of(line) == digest_of("FOO=bar")


def test_different_values_are_not_equal():
    assert digest_of("FOO=bar") != digest_of("FOO=baz")


@pytest.mark.parametrize(
    ("line", "empty"),
    [("FOO=", True), ("FOO=''", True), ('FOO=""', True), ("FOO= # c", True), ("FOO=x", False), ("FOO=' '", False)],
)
def test_empty(line, empty):
    entries, _ = envdiff.parse_text(line, "t.env")
    assert entries["FOO"].empty is empty


def test_entry_does_not_hold_raw_value():
    # 値を持つフィールドを足したら、このテストで気付けるようにする
    assert [f.name for f in dataclasses.fields(envdiff.Entry)] == ["lineno", "empty", "digest"]

    entries, _ = envdiff.parse_text("FOO=SENTINEL_parse\n", "t.env")
    entry = entries["FOO"]
    assert "SENTINEL" not in repr(entry)
    # 鍵なしのハッシュと一致したら、短い値は総当たりで割り出せてしまう
    assert entry.digest != hashlib.blake2b(b"SENTINEL_parse").digest()
