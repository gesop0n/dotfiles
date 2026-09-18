{
  description = "My nix-darwin system flake";

  # NOTE: inputs は Nix がロック解決のために「評価せずに静的な attrset として」
  # 読むため、import や関数適用で別ファイルへ切り出すことはできない
  # (`expected a set but got a thunk` になる)。URL の列挙はここに集約する。
  #
  # 一方で input を各モジュールへ渡す配線は outputs 以下で inputs を丸ごと
  # 引き回しており、input 追加時に触るのはこの inputs ブロックと
  # 実際に使うモジュールの2箇所だけで済む。
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
    };

    grok-build-nix = {
      url = "github:gesop0n/grok-build-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # UI/UX 設計用の Claude Code / Codex skill。
    # flake ではないリポジトリなので flake = false で生ソースとして取得し、
    # skills.nix が各 skill dir へ配布する。
    ui-ux-pro-max-skill = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };

    # 検証済み JSON IR から自己完結 HTML の構成図を生成する skill。
    # skill 本体はリポジトリ直下ではなく archify/ サブディレクトリ。
    # main は development channel (2.17.0-dev.1) なので stable のリリース
    # タグを pin する。更新はこのタグを書き換える (nix flake update では動かない)。
    archify-skill = {
      url = "github:tt-a1i/archify/v2.16.0";
      flake = false;
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      system = "aarch64-darwin";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;

      darwinConfigurations = {
        "Kotas-MacBook-Pro" = import ./nix/darwin/default.nix {
          inherit inputs system;
        };
      };
    };
}
