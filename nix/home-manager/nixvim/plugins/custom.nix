{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [
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
