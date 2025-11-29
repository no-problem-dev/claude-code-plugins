# Claude Code プラグインマーケットプレイス

個人用の Claude Code 拡張機能マーケットプレイスです。

## インストール

Claude Code にこのマーケットプレイスを追加:

```bash
# GitHub から（公開後）
/plugin marketplace add kyoichi/claude-code-plugins

# ローカルパスから（開発用）
/plugin marketplace add /Users/kyoichi/NOPROBLEM/claude-code-plugins
```

## 利用可能なプラグイン

| プラグイン | 説明 | コンポーネント |
|-----------|------|--------------|
| [release-flow](#release-flow) | リリースワークフロー自動化 | コマンド×3, スキル×1 |
| [ios-architecture](#ios-architecture) | iOS開発ベストプラクティス | スキル×3 |

---

## release-flow

リリースワークフロー自動化プラグイン。

### コマンド

| コマンド | 説明 |
|---------|------|
| `/release-prepare <version>` | リリース準備（CHANGELOGのバージョン変換、ブランチ作成） |
| `/changelog-add <category> <description>` | CHANGELOGにエントリ追加 |
| `/version-bump <type>` | 次バージョンを計算（major/minor/patch） |

### スキル

- **release-workflow**: セマンティックバージョニング、Keep a Changelog形式、GitHub Actions自動化のガイダンス

### インストール

```bash
/plugin install release-flow@no-problem-plugins
```

---

## ios-architecture

iOS開発のアーキテクチャとベストプラクティスプラグイン。

### スキル

| スキル | 説明 |
|-------|------|
| **ios-clean-architecture** | Clean Architecture パターン、レイヤー分離、依存性注入 |
| **swiftui-best-practices** | iOS 17+ SwiftUI、@Observable、Navigation、パフォーマンス |
| **swift-package-structure** | SPM マルチモジュール構成、Package.swift テンプレート |

### インストール

```bash
/plugin install ios-architecture@no-problem-plugins
```

## プラグイン構造

各プラグインは標準的な Claude Code プラグイン構造に従います:

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json      # プラグインマニフェスト
    ├── commands/            # スラッシュコマンド
    ├── agents/              # サブエージェント
    ├── skills/              # エージェントスキル
    └── hooks/               # イベントフック
```

## 公式プラグインの利用

このリポジトリでは、Anthropic公式マーケットプレースのプラグインも利用可能です。

### 設定済みプラグイン

`.claude/settings.json`で以下が設定されています:

- **plugin-dev@anthropic-official**: プラグイン・スキル作成用の公式ツールキット

### 利用方法

このリポジトリのフォルダを信頼すると、設定済みプラグインが自動的にインストールされます。

```bash
# リポジトリをClaudeで開くと自動インストール
cd /path/to/claude-code-plugins
claude

# または手動でインストール
/plugin install plugin-dev@anthropic-official
```

### plugin-devの主要機能

| コマンド/スキル | 説明 |
|---------------|------|
| `/plugin-dev:create-plugin` | 8フェーズのプラグイン作成ワークフロー |
| skill-development | スキル作成のベストプラクティス |
| command-development | スラッシュコマンド作成ガイド |
| hook-development | イベントフック開発 |
| agent-development | サブエージェント作成 |
| plugin-structure | ディレクトリ構成・マニフェスト |
| mcp-integration | MCPサーバー連携 |

## 開発

### 新しいプラグインの作成

1. `plugins/` 配下にプラグインディレクトリを作成
2. `.claude-plugin/plugin.json` マニフェストを追加
3. コンポーネント（commands, agents, skills, hooks）を追加
4. marketplace.json に登録
5. `/plugin marketplace add ./` でローカルテスト

**推奨**: `/plugin-dev:create-plugin`コマンドを使うと、ガイド付きでプラグインを作成できます。

### ローカルテスト

```bash
# ローカルマーケットプレイスを追加
/plugin marketplace add /Users/kyoichi/NOPROBLEM/claude-code-plugins

# プラグインをインストール
/plugin install plugin-name@no-problem-plugins

# インストール確認
/help
```

## ライセンス

MIT
