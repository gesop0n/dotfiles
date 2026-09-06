{ pkgs, ... }:
{
  home.packages = with pkgs; [
    delta
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
      };
      git = {
        diffRenderers = [
          {
            command = "delta --dark --paging=never --line-numbers --syntax-theme='Visual Studio Dark+'";
          }
        ];
      };
    };
  };
}
