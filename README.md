# dotfiles

macOS (Apple Silicon) 向けの個人環境設定。
[nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager) で管理している.

## 構成

```
dotfiles/
├── flake.nix              # Nix flake エントリポイント
├── nix/
│   ├── darwin/            # macOS システム設定
│   │   ├── default.nix    # モジュール結合
│   │   ├── homebrew.nix   # Homebrew (cask) 管理
│   │   ├── packages.nix   # システムレベルのパッケージ
│   │   └── ...
│   └── home-manager/      # ユーザー環境設定
│       ├── packages.nix   # ユーザーパッケージ
│       ├── git.nix        # Git 設定
│       ├── zsh.nix        # zsh 設定
│       └── ...
├── nvim/                  # Neovim 設定 (AstroNvim)
├── wezterm/               # WezTerm 設定
└── hammerspoon/           # Hammerspoon 設定
```

## Getting Started

### 前提条件

- macOS (Apple Silicon)
- Xcode Command Line Tools: `xcode-select --install`

### 1. Nix のインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

インストール後、ターミナルを再起動してください。

### 2. このリポジトリをクローン

```bash
git clone https://github.com/gesop0n/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. nix-darwin を適用

```bash
darwin-rebuild switch --flake .
```

初回は nix-darwin 自体のインストールが必要な場合があります：

```bash
nix run nix-darwin -- switch --flake .
```

---

## Nix 基本コマンド

### 設定の変更を反映する

`nix/` 以下のファイルを編集したあと、以下で適用します：

```bash
darwin-rebuild switch --flake ~/dotfiles
```

### パッケージを検索する

```bash
# nixpkgs でパッケージを検索
nix search nixpkgs <パッケージ名>

# 例
nix search nixpkgs ripgrep
```

### flake の入力 (依存) を更新する

```bash
# すべての入力を最新に更新
nix flake update

# 特定の入力だけ更新 (例: Claude Code)
nix flake update claude-code-nix
```

更新後は `darwin-rebuild switch --flake .` で適用します。

### flake の情報を確認する

```bash
# 入力のバージョン・コミットハッシュを確認
nix flake metadata ~/dotfiles

# flake が提供するパッケージ・設定を一覧表示
nix flake show ~/dotfiles
```

### パッケージのバージョンを確認する

```bash
# 例: Claude Code の最新バージョンを upstream で確認
nix eval github:sadjow/claude-code-nix#packages.aarch64-darwin.claude-code.version
```

### 一時的にパッケージを試す (インストールせず)

```bash
nix shell nixpkgs#<パッケージ名>

# 例
nix shell nixpkgs#jq
```

### Nix ストアのクリーンアップ

```bash
# 古い世代を削除してストアを最適化
nix-collect-garbage -d
```

---

## ツール一覧

| ツール | 概要 |
|---|---|
| [nix-darwin](https://github.com/nix-darwin/nix-darwin) | macOS のシステム設定を Nix で宣言的に管理 |
| [home-manager](https://github.com/nix-community/home-manager) | ユーザー環境・dotfiles を Nix で管理 |
| [WezTerm](https://wezfurlong.org/wezterm/) | GPU アクセラレート対応ターミナル |
| [Neovim](https://neovim.io/) + [AstroNvim](https://astronvim.com/) | テキストエディタ |
| [Hammerspoon](https://www.hammerspoon.org/) | macOS 自動化 |
| [Claude Code](https://claude.ai/code) | AI コーディングアシスタント CLI |
