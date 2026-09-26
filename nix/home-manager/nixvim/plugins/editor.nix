{ ... }:
{
  programs.nixvim.plugins = {
    fzf-lua.enable = true;

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
        ensure_installed = [
          "typescript"
          "tsx"
          "javascript"
        ];
      };
    };

    # キーマップは keymaps.nix で定義する。
    # nvim-treesitter main ブランチ向けの新 API では settings が nvim-treesitter 側に
    # 渡されて無視されるため、オプションは下の extraConfigLua で直接 setup する。
    treesitter-textobjects.enable = true;

    # カーソル位置の関数・クラスのシグネチャを画面上部に固定表示する
    treesitter-context = {
      enable = true;
      settings.max_lines = 3;
    };

    # 診断・シンボル・参照などの一覧パネル (キーマップは keymaps.nix)
    trouble.enable = true;

    flash.enable = true;
    which-key.enable = true;
    # コメントのトグルは Neovim 標準の gc / gcc を使う。
    # ts-comments は treesitter のノードに応じた commentstring を与えて
    # JSX 内を {/* */} にするなど、標準の gc を言語ごとに正しくする。
    ts-comments.enable = true;
    nvim-autopairs.enable = true;
    ts-autotag.enable = true;
  };

  programs.nixvim.extraConfigLua = ''
    -- カーソルより後ろにある textobject も選択対象にする (targets.vim 風)
    require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })
  '';
}
