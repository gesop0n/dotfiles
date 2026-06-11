{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
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
  };
}
