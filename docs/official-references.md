# Claude Code 公式リファレンス集

Claude Code プラグイン開発に必要な公式ドキュメントへのリンク集です。

## 目次

- [プラグインシステム](#プラグインシステム)
- [コンポーネント別リファレンス](#コンポーネント別リファレンス)
- [MCP (Model Context Protocol)](#mcp-model-context-protocol)
- [設定・カスタマイズ](#設定カスタマイズ)
- [ベストプラクティス・ガイド](#ベストプラクティスガイド)
- [コミュニティリソース](#コミュニティリソース)

---

## プラグインシステム

### 概要・入門

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Plugins Overview | プラグインの概要と基本構造 | [英語](https://code.claude.com/docs/en/plugins) |
| Plugins Reference | plugin.json スキーマ詳細 | [英語](https://code.claude.com/docs/en/plugins-reference) |
| Plugin Marketplaces | マーケットプレイスの作成・管理 | [英語](https://code.claude.com/docs/en/plugin-marketplaces) |

### アナウンス・ブログ

| 記事 | 説明 | リンク |
|-----|------|--------|
| Claude Code Plugins 発表 | プラグイン機能の公式アナウンス | [Anthropic News](https://www.anthropic.com/news/claude-code-plugins) |
| Claude Code Best Practices | 公式ベストプラクティス | [Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices) |

---

## コンポーネント別リファレンス

### スラッシュコマンド (Slash Commands)

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Slash Commands | コマンド作成・YAML フロントマター | [日本語](https://code.claude.com/docs/ja/slash-commands) / [英語](https://code.claude.com/docs/en/slash-commands) |

**主要トピック:**
- コマンドファイルの配置場所 (`.claude/commands/`, `~/.claude/commands/`)
- YAML フロントマター (`description`, `allowed-tools`, `model`)
- パラメータ (`$ARGUMENTS`, `$1`, `$2`...)
- Bash 実行 (`!` プレフィックス)
- ファイル参照 (`@` プレフィックス)

### サブエージェント (Subagents)

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Subagents | エージェント定義・ツール制限 | [日本語](https://code.claude.com/docs/ja/sub-agents) / [英語](https://code.claude.com/docs/en/sub-agents) |

**主要トピック:**
- エージェント定義ファイル (`.claude/agents/*.md`)
- YAML フロントマター (`name`, `description`, `tools`, `model`, `skills`)
- モデル選択 (`sonnet`, `opus`, `haiku`, `inherit`)
- ツール制限とスコープ
- ビルトインエージェント

### エージェントスキル (Agent Skills)

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Agent Skills | SKILL.md 構造・段階的読み込み | [日本語](https://code.claude.com/docs/ja/skills) / [英語](https://code.claude.com/docs/en/skills) |

**主要トピック:**
- SKILL.md 必須フィールド (`name`, `description`)
- ディレクトリ構造 (`scripts/`, `references/`)
- 段階的読み込み (Progressive Disclosure)
- スキル検出メカニズム
- `allowed-tools` によるツール制限

### フック (Hooks)

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Hooks Guide | フック設定・イベント種類 | [日本語](https://code.claude.com/docs/ja/hooks-guide) / [英語](https://code.claude.com/docs/en/hooks-guide) |
| Hooks Reference | フック詳細仕様 | [英語](https://code.claude.com/docs/en/hooks) |

**フックイベント一覧:**
| イベント | タイミング | ブロック可能 |
|---------|-----------|-------------|
| `PreToolUse` | ツール実行前 | ✅ |
| `PostToolUse` | ツール実行後 | - |
| `UserPromptSubmit` | ユーザー入力時 | ✅ |
| `Notification` | 通知送信時 | - |
| `Stop` | 応答終了時 | - |
| `SubagentStop` | サブエージェント終了時 | - |
| `PreCompact` | コンパクト操作前 | - |
| `SessionStart` | セッション開始時 | - |
| `SessionEnd` | セッション終了時 | - |

**Exit Code:**
- `0`: 成功（実行許可）
- `2`: ブロック（stderr をフィードバック）

---

## MCP (Model Context Protocol)

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| MCP Overview | MCP サーバー設定・統合 | [日本語](https://code.claude.com/docs/ja/mcp) / [英語](https://code.claude.com/docs/en/mcp) |
| MCP 公式サイト | Model Context Protocol 仕様 | [modelcontextprotocol.io](https://modelcontextprotocol.io/) |
| MCP Servers リスト | 公開 MCP サーバー一覧 | [GitHub](https://github.com/modelcontextprotocol/servers) |

**トランスポートオプション:**
| タイプ | 用途 | コマンド例 |
|--------|------|----------|
| HTTP | リモートサービス（推奨） | `claude mcp add --transport http name url` |
| SSE | リモート代替 | `claude mcp add --transport sse name url` |
| Stdio | ローカルプロセス | `claude mcp add --transport stdio name -- command` |

**スコープ:**
- `local`: 現在のプロジェクトのみ
- `project`: `.mcp.json` でチーム共有
- `user`: 全プロジェクト共通

---

## 設定・カスタマイズ

### 設定ファイル

| ファイル | スコープ | 用途 |
|---------|---------|------|
| `.claude/settings.json` | プロジェクト | チーム共有設定 |
| `~/.claude/settings.json` | ユーザー | 個人設定 |
| `.mcp.json` | プロジェクト | MCP サーバー設定 |
| `~/.claude.json` | ユーザー | グローバル設定 |

### 関連ドキュメント

| ドキュメント | 説明 | リンク |
|-------------|------|--------|
| Settings | 設定ファイル詳細 | [英語](https://code.claude.com/docs/en/settings) |
| Memory | メモリ・コンテキスト管理 | [英語](https://code.claude.com/docs/en/memory) |
| Permissions | 権限・セキュリティ | [英語](https://code.claude.com/docs/en/permissions) |

---

## ベストプラクティス・ガイド

### 公式ガイド

| ガイド | 説明 | リンク |
|-------|------|--------|
| Claude Code Best Practices | 公式推奨パターン | [Anthropic Engineering](https://www.anthropic.com/engineering/claude-code-best-practices) |
| Agentic Coding | エージェント型コーディング | [英語](https://code.claude.com/docs/en/agentic-coding) |
| Tutorials | チュートリアル集 | [英語](https://code.claude.com/docs/en/tutorials) |

### セキュリティ

| トピック | 説明 | リンク |
|---------|------|--------|
| Security | セキュリティガイドライン | [英語](https://code.claude.com/docs/en/security) |
| Permissions | 権限管理 | [英語](https://code.claude.com/docs/en/permissions) |

---

## コミュニティリソース

### プラグインコレクション

| リポジトリ | 説明 | リンク |
|-----------|------|--------|
| anthropics/claude-code | 公式プラグイン例 | [GitHub](https://github.com/anthropics/claude-code/tree/main/plugins) |
| claude-code-plugins-plus | 243+ プラグイン集 | [GitHub](https://github.com/jeremylongshore/claude-code-plugins-plus) |
| awesome-claude-plugins | キュレーションリスト | [GitHub](https://github.com/GiladShoham/awesome-claude-plugins) |
| cc-plugins | 開発者向けプラグイン | [GitHub](https://github.com/yanmxa/cc-plugins) |
| awesome-claude-code-subagents | 100+ サブエージェント | [GitHub](https://github.com/VoltAgent/awesome-claude-code-subagents) |

### 日本語リソース

| 記事 | 説明 | リンク |
|-----|------|--------|
| Claude Code Skills/Subagent/Plugin ガイド | 包括的な日本語解説 | [Classmethod](https://dev.classmethod.jp/articles/claude-code-skills-subagent-plugin-guide/) |

---

## クイックリファレンス

### plugin.json 必須フィールド

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "プラグインの説明"
}
```

### marketplace.json 必須フィールド

```json
{
  "name": "marketplace-name",
  "owner": { "name": "...", "email": "..." },
  "plugins": [
    { "name": "...", "source": "./plugins/..." }
  ]
}
```

### SKILL.md 必須フィールド

```yaml
---
name: skill-name
description: スキルの説明
---
```

### コマンド/エージェント YAML フロントマター

```yaml
---
name: agent-name           # エージェントのみ必須
description: 説明
allowed-tools: Read, Write # オプション
model: sonnet              # オプション
---
```

---

## 更新履歴

| 日付 | 内容 |
|------|------|
| 2025-11-30 | 初版作成 |
