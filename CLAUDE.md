# Claude Code プラグインマーケットプレイス

このリポジトリは Claude Code のプラグインマーケットプレイスです。

## リポジトリ構造

```
claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json    # マーケットプレイスカタログ定義
├── plugins/                # プラグイン格納ディレクトリ
│   └── <plugin-name>/      # 各プラグイン
└── README.md
```

## マーケットプレイスの仕組み

### marketplace.json
- プラグインカタログを定義
- 各プラグインの `name`, `description`, `source`, `version` を管理
- `source` は相対パス `./plugins/<name>` で指定

### プラグイン構造
各プラグインは以下の構造を持つ:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json         # 必須: プラグインマニフェスト
├── commands/               # スラッシュコマンド (.md)
├── agents/                 # サブエージェント (.md)
├── skills/                 # エージェントスキル (SKILL.md)
│   └── skill-name/
│       └── SKILL.md
└── hooks/                  # フック設定 (hooks.json)
```

## コンポーネント仕様

### plugin.json (必須)
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "プラグインの説明",
  "commands": "./commands/",
  "agents": "./agents/",
  "skills": "./skills/"
}
```

### スラッシュコマンド (commands/*.md)
```yaml
---
description: コマンドの説明
allowed-tools: Read, Write, Bash
---

コマンドの指示内容...
$ARGUMENTS で引数を受け取る
```

### サブエージェント (agents/*.md)
```yaml
---
name: agent-name
description: エージェントの説明と呼び出し条件
tools: Read, Grep, Glob
model: sonnet
---

エージェントのシステムプロンプト...
```

### スキル (skills/*/SKILL.md)
```yaml
---
name: skill-name
description: スキルの説明（いつ使うか、キーワード含む）
---

スキルの詳細な指示...
```

## 開発ガイドライン

### プラグイン追加時
1. `plugins/<name>/` ディレクトリ作成
2. `.claude-plugin/plugin.json` 作成
3. 必要なコンポーネント追加
4. `marketplace.json` の `plugins` 配列に追加

### 命名規則
- プラグイン名: kebab-case (例: `release-flow`)
- スキル名: 小文字、ハイフン、数字のみ (最大64文字)
- コマンドファイル: ファイル名がコマンド名になる

### ベストプラクティス
- 1プラグイン = 1つの明確な目的
- スキルの description は具体的に（トリガー用語を含める）
- コマンドは頻繁に使う操作をショートカット化
- エージェントは独立したコンテキストで実行される専門タスク向け

## 予定プラグイン

### release-flow
Stockle プロジェクトのリリースフローを参考にした自動化:
- `/release prepare` - リリース準備
- `/release changelog` - CHANGELOG 更新
- セマンティックバージョニングガイダンス

### ios-architecture
iOS 開発のアーキテクチャスキル:
- Clean Architecture パターン
- SwiftUI + Combine ベストプラクティス
- マルチモジュール Swift Package 構成
