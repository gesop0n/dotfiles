{
  lib,
  stdenvNoCC,
  python3,
}:
# envdiff: 2 つの dotenv ファイルをキー単位で比べる自作コマンド (値は表示しない)。
# 本体は標準ライブラリだけの Python 1 ファイル。テストはインストール後の
# $out/bin/envdiff を実際に実行するので、手元で試した物とインストールされる物がずれない。
stdenvNoCC.mkDerivation {
  pname = "envdiff";
  version = "0.1.0";

  # nix のファイルを触っただけで作り直さないよう、ビルドに要る物だけを渡す。
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./envdiff.py
      ./pytest.ini
      ./tests
    ];
  };

  # 実行時に要る。fixupPhase の patchShebangs が `#!/usr/bin/env python3` を
  # この python3 の絶対パスへ書き換える。
  buildInputs = [ python3 ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 envdiff.py $out/bin/envdiff
    runHook postInstall
  '';

  # テストが落ちたら rebuild ごと失敗させ、壊れた物をインストールしない。
  doInstallCheck = true;
  nativeInstallCheckInputs = [ (python3.withPackages (ps: [ ps.pytest ])) ];
  installCheckPhase = ''
    runHook preInstallCheck
    ENVDIFF_BIN=$out/bin/envdiff pytest
    runHook postInstallCheck
  '';

  meta = {
    description = "2 つの dotenv ファイルをキー単位で比べる (値は表示しない)";
    mainProgram = "envdiff";
  };
}
