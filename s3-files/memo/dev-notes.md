# 業務で使うノウハウなど共有用

## alias
```
alias glog='git log --date=iso --pretty="format:%C(yellow)%h %C(green)%cd %C(blue)%an%C(red)%d %C(reset)%s" -200 --graph'
alias gst='git status -s'
alias gb='git branch'
alias gc='git checkout'
alias gr="git checkout master && git pull && git branch --merged | grep -v '\*' | grep -v 'master' | xargs git branch -d; git fetch -p"
alias gacp='git add -A && git commit --amend --no-edit && git push origin -f'

# claude code
ccds() {
  if ! docker image inspect claude-code &>/dev/null; then
    docker build -t claude-code "$HOME/.claude/docker/claude-code"
  fi

  touch "$HOME/.claude.json" "$HOME/.claude/.credentials.json"

  local timestamp
  timestamp=$(date +%Y-%m-%d_%H-%M)
  sed -i -E "s|plans/[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}/|plans/$timestamp/|" \
    "$HOME/.claude/settings.json"

  docker run --rm -it \
    -v "$(pwd)":/workspace \
    -v "$HOME/.claude.json":/home/claude/.claude.json \
    -v "$HOME/.claude/.credentials.json":/home/claude/.claude/.credentials.json \
    -v "$HOME/.claude/commands":/home/claude/.claude/commands:ro \
    -v "$HOME/.claude/bin":/home/claude/bin:ro \
    -v "$HOME/.claude/CLAUDE.md":/home/claude/.claude/CLAUDE.md:ro \
    -v "$HOME/.claude/settings.json":/home/claude/.claude/settings.json:ro \
    -v "$HOME/.config/gh":/home/claude/.config/gh:ro \
    -v "$HOME/.gitconfig":/home/claude/.gitconfig:ro \
    -v "$HOME/.aws/config":/home/claude/.aws/config:ro \
    -v "$HOME/.ssh":/home/claude/.ssh:ro \
    -w /workspace \
    claude-code "$@"
}
```

## cloude code実行用Dockerfile
~/.claude/docker/claude-code/Dockerfile 
```
# ~/.bash_aliases の ccds コマンドで使用するDockerイメージ
#
# イメージの確認:
#   docker image inspect claude-code
#
# イメージのビルド:
#   docker build -t claude-code ~/.claude/docker/claude-code
#   ※ ccds コマンド実行時にイメージが存在しない場合は自動でビルドされる
#
# イメージの削除:
#   docker rmi claude-code

FROM ubuntu:22.04

ENV TZ=JST-9

RUN apt-get update && apt-get install -y \
    curl ca-certificates sudo git jq python3 unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg \
        | gpg --dearmor | dd of=/usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" \
        | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null \
    && apt-get update && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

RUN useradd -m -s /bin/bash claude

USER claude
ENV HOME=/home/claude

RUN curl -fsSL https://claude.ai/install.sh | bash

# ホストから .claude 配下のファイルを個別マウントするため、親ディレクトリを claude ユーザー所有で事前作成
# （未作成だと Docker が root 所有で自動生成し、claude ユーザーが書き込めなくなる）
RUN mkdir -p /home/claude/.claude

# install.sh は claude バイナリを ~/.local/bin に配置するが、デフォルト PATH に含まれないため追加
ENV PATH="/home/claude/.local/bin:${PATH}"

# ccds 実行時にホストの ~/.claude/bin を /home/claude/bin にマウントしており、
# そこに置かれたスクリプト（ask_slack.sh 等）をコマンド名で呼び出せるよう PATH に追加
ENV PATH="/home/claude/bin:${PATH}"

WORKDIR /workspace
ENTRYPOINT ["claude"]
```

## CLAUDE.md(ホームディレクトリ直下)
~/.claude/CLAUDE.md
```
# CLAUDE.md

## コミュニケーション

- **チャットは日本語**でやり取りする
- **技術用語は英語**のまま使って構わない（例: `commit`, `branch`, `refactor`, `dependency` など）

## 実装ワークフロー

### 1. GitHub Issue作成（Planモード完了後、実装前に必須）
- `gh issue create` でIssueを立てる

### 2. 作業ブランチ作成
- developブランチがあれば最新のdevelopから、無ければmaster/mainから切る
- 命名規則: `[prefix]/issue-[Issue番号]-[簡潔な説明]`（英数字・ハイフンのみ、kebab-case）
  - prefix: `feature`（新機能）、`fix`（バグ修正）、`docs`（ドキュメント）、`chore`（雑務）
  - 例: `feature/issue-5-add-login`, `fix/issue-12-null-pointer-on-startup`

### 3. コミット（Conventional Commits規約）
- 形式: `<type>: <日本語の変更概要>`
- 主なtype（英語のまま使う）:
  - `feat:` 新機能追加
  - `fix:` バグ修正
  - `docs:` ドキュメント変更
  - `refactor:` リファクタリング
  - `test:` テスト追加・修正
  - `chore:` 設定・ビルド・雑務
  - `style:` フォーマット修正（動作変更なし）
  - `perf:` パフォーマンス改善
  - `ci:` CI設定変更
- 例: `feat: ログイン画面のバリデーション処理を追加`
- 1コミット＝1つの論理的な変更にまとめる
- plansディレクトリにファイルが配置されていればコミット対象に加える

### 4. Pull Request作成
- PRのタイトルおよび本文は**日本語**で記述する
- 本文に必ず含めるもの：
  - 変更内容の概要
  - `Close #[Issue番号]`（Issueと紐づけるため必須）
- PRの粒度は小さく保ち、1PRで1つの目的を達成する
- developブランチがあればdevelopへ、無ければmaster/mainへのPRとして作成する
```

## claude用settings.json
~/.claude/settings.json 
```
{
  "env": {
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1"
  },
  "plansDirectory": "plans/2026-04-26_13-56/",
  "sandbox": {
    "enabled": true,
    "network": {
      "allowedDomains": [
        "api.anthropic.com",

        "github.com",
        "api.github.com",
        "raw.githubusercontent.com",
        "objects.githubusercontent.com",
        "codeload.github.com",
        "uploads.github.com",
        "cli.github.com",
        "pipelines.actions.githubusercontent.com",

        "registry.npmjs.org",
        "npmjs.org",

        "pypi.org",
        "files.pythonhosted.org",

        "proxy.golang.org",
        "sum.golang.org",
        "pkg.go.dev",

        "crates.io",
        "static.crates.io",

        "repo1.maven.org",
        "search.maven.org",

        "rubygems.org",
        "api.rubygems.org",

        "packagist.org",
        "repo.packagist.org",

        "s3.amazonaws.com",
        "ec2.amazonaws.com",
        "sts.amazonaws.com",
        "iam.amazonaws.com",
        "lambda.amazonaws.com",
        "rds.amazonaws.com",

        "googleapis.com",
        "storage.googleapis.com",
        "container.googleapis.com",
        "accounts.google.com",
        "gcr.io",

        "registry.terraform.io",
        "releases.hashicorp.com",
        "checkpoint-api.hashicorp.com",

        "registry-1.docker.io",
        "hub.docker.com",
        "auth.docker.io",
        "mcr.microsoft.com",

        "archive.ubuntu.com",
        "security.ubuntu.com",
        "packages.ubuntu.com",

        "slack.com",
        "api.slack.com",
        "hooks.slack.com",

        "cdn.jsdelivr.net",
        "unpkg.com",
        "cdnjs.cloudflare.com"
      ]
    }
  },
  "permissions": {
    "allow": [
      "Read(**)"
    ],
    "deny": [
      "Bash(sudo*)",
      "Read(.env)",
      "Read(id_rsa)",
      "Read(id_ed25519)",
      "Write(.env)"
    ]
  }
}
```

## .vimrc
~/.vimrc 
```
" ===========================
"  基本設定
" ===========================
set encoding=utf-8          " 文字コード
set fileencoding=utf-8      " ファイル保存時の文字コード
set nobackup                " バックアップファイルを作らない
set noswapfile              " スワップファイルを作らない
set autoread                " 外部でファイルが変更されたら自動読み込み
set hidden                  " バッファを保存せず切り替え可能に
set showcmd                 " 入力中のコマンドを表示

" ===========================
"  表示設定
" ===========================
set number                  " 行番号表示
"set relativenumber          " 相対行番号（移動しやすくなる）
"set cursorline              " カーソル行をハイライト
set showmatch               " 対応する括弧をハイライト
"set wrap                    " 長い行を折り返す
"set colorcolumn=80          " 80文字目にガイドラインを表示
set laststatus=2            " ステータスラインを常に表示
set wildmenu                " コマンドライン補完を強化
syntax on                   " シンタックスハイライト有効化
set background=dark         " ダークテーマ用設定

" ===========================
"  インデント設定
" ===========================
set expandtab               " タブをスペースに変換
set tabstop=4               " タブ幅 = 4スペース
set shiftwidth=4            " インデント幅
set softtabstop=4           " 編集時のタブ幅
set autoindent              " 自動インデント
set smartindent             " スマートインデント

" ===========================
"  検索設定
" ===========================
set incsearch               " インクリメンタルサーチ（入力しながら検索）
set hlsearch                " 検索結果をハイライト
set ignorecase              " 検索時に大文字小文字を無視
set smartcase               " 大文字が含まれている場合は区別する
" Escで検索ハイライトを消す
nnoremap <Esc><Esc> :nohlsearch<CR><Esc>

" ===========================
"  キーマッピング
" ===========================
" leaderキーをスペースに設定
let mapleader = "\<Space>"

" jjでノーマルモードに戻る
"inoremap jj <Esc>

" Ctrl+s で保存
"nnoremap <C-s> :w<CR>
"inoremap <C-s> <Esc>:w<CR>

" バッファ切り替え
nnoremap <Leader>n :bnext<CR>
nnoremap <Leader>p :bprev<CR>

" 行頭・行末移動を直感的に
noremap H ^
noremap L $

" ===========================
"  クリップボード
" ===========================
set clipboard=unnamed       " OSのクリップボードと共有 (macOS/Windows)
" Linux の場合は以下を使用
" set clipboard=unnamedplus

" ===========================
"  その他の便利設定
" ===========================
set backspace=indent,eol,start  " バックスペースで何でも削除
set scrolloff=8                 " スクロール時に8行余白を保つ
set sidescrolloff=8             " 横スクロール時の余白
set splitbelow                  " 水平分割は下に開く
set splitright                  " 垂直分割は右に開く
set updatetime=300              " 更新間隔を短く（gitgutterなどに効果的）
```