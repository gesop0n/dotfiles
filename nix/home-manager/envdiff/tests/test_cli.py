"""コマンドとしての振る舞いのテスト。

どのテストも run() でコマンドを実行し、run() は毎回「標準出力にも標準エラーにも
値が出ていないこと」を確かめる。テスト用の値には必ず SENTINEL を含めること。
"""

import os
import subprocess
import sys
from pathlib import Path
from textwrap import dedent

import pytest

import envdiff

# nix のビルドではインストールした $out/bin/envdiff を実行する。
# 手元では envdiff.py をそのまま実行する。
COMMAND = (
    [os.environ["ENVDIFF_BIN"]]
    if "ENVDIFF_BIN" in os.environ
    else [sys.executable, str(Path(__file__).resolve().parent.parent / "envdiff.py")]
)

LEFT = """\
SAME=SENTINEL_same
CHANGED=SENTINEL_old
REMOVED=SENTINEL_removed
FILLED=
EMPTIED=SENTINEL_emptied
BOTH_EMPTY=
"""

RIGHT = """\
# 並び順・引用符・export の違いは差分にしない
BOTH_EMPTY=''
export SAME="SENTINEL_same"
CHANGED=SENTINEL_new
ADDED=SENTINEL_added
ADDED_EMPTY=
FILLED=SENTINEL_filled
EMPTIED=
"""


def run(*args: object) -> subprocess.CompletedProcess[str]:
    result = subprocess.run([*COMMAND, *map(str, args)], capture_output=True, encoding="utf-8")
    assert "SENTINEL" not in result.stdout
    assert "SENTINEL" not in result.stderr
    return result


@pytest.fixture
def env_file(tmp_path):
    def write(name: str, content: str | bytes) -> Path:
        path = tmp_path / name
        if isinstance(content, bytes):
            path.write_bytes(content)
        else:
            path.write_text(content, encoding="utf-8")
        return path

    return write


def test_shows_only_differences(env_file):
    left, right = env_file(".env", LEFT), env_file(".env.local", RIGHT)
    result = run(left, right)
    assert result.returncode == 1
    assert result.stdout == dedent(f"""\
        --- {left}
        +++ {right}
          - REMOVED
          + ADDED
          + ADDED_EMPTY  （空）
          ~ CHANGED      値が違う
          ~ FILLED       空 → 値あり
          ~ EMPTIED      値あり → 空

        差分 6（追加 2 / 削除 1 / 変更 3）
        """)
    assert result.stderr == ""


def test_all_option_also_shows_matching_keys(env_file):
    left, right = env_file(".env", LEFT), env_file(".env.local", RIGHT)
    result = run("-a", left, right)
    assert result.returncode == 1
    lines = result.stdout.splitlines()
    assert "  = SAME" in lines
    assert "  = BOTH_EMPTY   （空）" in lines
    assert lines[-1] == "差分 6（追加 2 / 削除 1 / 変更 3）、一致 2"


def test_no_difference(env_file):
    left = env_file(".env", "A=SENTINEL_a\nB='SENTINEL_b'\n")
    right = env_file(".env.local", '# コメント\nexport B=SENTINEL_b\n\nA="SENTINEL_a"\n')
    result = run(left, right)
    assert result.returncode == 0
    assert result.stdout == f"--- {left}\n+++ {right}\n差分なし\n"


def test_keys_only_ignores_values(env_file):
    left = env_file(".env.example", "API_KEY=\nURL=SENTINEL_example\n")
    right = env_file(".env", "API_KEY=SENTINEL_real\nURL=SENTINEL_real_url\n")
    assert run(left, right).returncode == 1

    result = run("-k", left, right)
    assert result.returncode == 0
    assert result.stdout.endswith("差分なし\n")


def test_keys_only_still_reports_missing_keys(env_file):
    left = env_file(".env.example", "API_KEY=\nNEW_KEY=\n")
    right = env_file(".env", "API_KEY=SENTINEL_real\n")
    result = run("-k", left, right)
    assert result.returncode == 1
    assert "  - NEW_KEY  （空）" in result.stdout.splitlines()


def test_multiline_value(env_file):
    left = env_file(".env", 'CERT="-----BEGIN-----\nSENTINEL_old==\n-----END-----"\n')
    right = env_file(".env.local", 'CERT="-----BEGIN-----\nSENTINEL_new==\n-----END-----"\n')
    result = run(left, right)
    assert result.returncode == 1
    assert "  ~ CERT  値が違う" in result.stdout.splitlines()
    assert result.stderr == ""


def test_warnings_never_contain_line_content(env_file):
    left = env_file(
        ".env",
        dedent("""\
            SENTINEL_line_without_equals
            BROKEN="SENTINEL_unclosed
            TRAILING='SENTINEL_x' SENTINEL_trailing
            DUP=SENTINEL_first
            DUP=SENTINEL_second
            """),
    )
    right = env_file(".env.local", "DUP=SENTINEL_second\n")
    result = run(left, right)
    assert result.returncode == 0
    assert result.stderr.splitlines() == [
        f"envdiff: 警告: {left}:1: KEY=VALUE の形になっていない行を飛ばした",
        f"envdiff: 警告: {left}:2: BROKEN の値を読めないので飛ばした (閉じ引用符が無い)",
        f"envdiff: 警告: {left}:3: TRAILING の値を読めないので飛ばした (閉じ引用符の後ろに余分な文字がある)",
        f"envdiff: 警告: {left}:5: DUP が 4 行目にもあるので、後ろの定義を使う",
    ]


def test_bom_is_ignored(env_file):
    left = env_file(".env", "﻿A=SENTINEL_a\n")
    right = env_file(".env.local", "A=SENTINEL_a\n")
    assert run(left, right).returncode == 0


@pytest.mark.parametrize("count", [0, 1, 3])
def test_requires_exactly_two_files(env_file, count):
    files = [env_file(f"{i}.env", "A=SENTINEL_a\n") for i in range(count)]
    result = run(*files)
    assert result.returncode == 2
    assert result.stdout == ""
    assert "usage: envdiff" in result.stderr


def test_missing_file(env_file, tmp_path):
    left = env_file(".env", "A=SENTINEL_a\n")
    missing = tmp_path / "missing.env"
    result = run(left, missing)
    assert result.returncode == 2
    assert result.stdout == ""
    assert result.stderr.startswith(f"envdiff: {missing}: 読めない (")


def test_directory(env_file, tmp_path):
    left = env_file(".env", "A=SENTINEL_a\n")
    result = run(left, tmp_path)
    assert result.returncode == 2
    assert result.stderr.startswith(f"envdiff: {tmp_path}: 読めない (")


def test_not_utf8(env_file):
    left = env_file(".env", "A=SENTINEL_a\n")
    right = env_file(".env.local", b"A=\xff\xfeSENTINEL_b\n")
    result = run(left, right)
    assert result.returncode == 2
    assert result.stderr == f"envdiff: {right}: UTF-8 として読めない\n"


def test_unexpected_error_shows_only_type_name(env_file, monkeypatch, capsys):
    left = env_file(".env", "A=SENTINEL_a\n")
    right = env_file(".env.local", "A=SENTINEL_b\n")

    def broken(*args, **kwargs):
        raise ValueError("SENTINEL_in_exception")

    monkeypatch.setattr(envdiff, "compare", broken)
    assert envdiff.main([str(left), str(right)]) == 2
    captured = capsys.readouterr()
    assert captured.out == ""
    assert captured.err == "envdiff: 内部エラー (ValueError)\n"


def test_color_only_when_requested():
    changes = [envdiff.Change("+", "A")]
    assert "\033[" in envdiff.render("a", "b", changes, show_same=False, color=True)
    assert "\033[" not in envdiff.render("a", "b", changes, show_same=False, color=False)
