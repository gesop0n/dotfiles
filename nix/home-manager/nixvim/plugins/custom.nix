{ pkgs, ... }:
let
  # peek.nvim は deno でビルドが必要なため fixed-output derivation で対応
  peekBuilt = pkgs.stdenvNoCC.mkDerivation {
    name = "peek-nvim-built";
    src = pkgs.fetchFromGitHub {
      owner = "toppair";
      repo = "peek.nvim";
      rev = "5820d937d5414baea5f586dc2a3d912a74636e5b";
      hash = "sha256-hGIPxHwTSXTHFJ3JiVATMjEmoFhZ87fWElj1AMPMbQU=";
    };
    nativeBuildInputs = [ pkgs.deno ];
    buildPhase = ''
      export HOME=$TMPDIR
      export DENO_DIR=$TMPDIR/deno-cache
      FAST=true deno run --allow-run --allow-net --allow-read --allow-write --allow-env --no-check scripts/build.js
    '';
    installPhase = "cp -r . $out";
    outputHash = "sha256-N2KB9BKbVbq31iRbc56xutdUIeZOk+ufdmj7b8WrSLs=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "peek-nvim";
        src = peekBuilt;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "dataform-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "magal1337";
          repo = "dataform.nvim";
          rev = "43a5f9e17275325ae32e5248c6f21636418e2018";
          hash = "sha256-HA6E9L6U37Btb/dDgtm7du97/fae5IawCSg/nmB/tqg=";
        };
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "wmnusmv-vim";
        src = pkgs.fetchFromGitHub {
          owner = "wannesm";
          repo = "wmnusmv.vim";
          rev = "a9fa46eea8e667aa6413267a27209be18cae6622";
          hash = "sha256-otXUPzzabsjXiOvhCieO1d9TYpIrxyNwjxydx7dU+MQ=";
        };
      })
    ];

    extraConfigLua = ''
      require("peek").setup({ app = "browser" })
    '';
  };
}
