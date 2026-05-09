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

    # FYI: .gitconfig の includeIf の指定
    # github.com/⚪︎⚪︎ のフォルダでユーザーを自動的に切り替える.
    # https://www.reddit.com/r/NixOS/comments/1atp50v/generate_string_to_file_without_double_quotes_in/
    includes = [
      {
        condition = "gitdir:~/github.com/gesop0n/";
        path = "~/.gitconfig-gesop0n";
      }
      {
        condition = "gitdir:~/github.com/KotaIshikuro/";
        path = "~/.gitconfig-KotaIshikuro";
      }
    ];
  };

  # includeIf で読み込む追加 gitconfig ファイルを生成
  home.file.".gitconfig-gesop0n".text = ''
    [user]
      name = gesop0n
      email = ishikuro6.2@gmail.com
  '';

  home.file.".gitconfig-KotaIshikuro".text = ''
    [user]
      name = KotaIshikuro
      email = 173035841+KotaIshikuro@users.noreply.github.com
  '';
}
