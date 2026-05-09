{ ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "gesop0n";
        email = "ishikuro6.2@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
