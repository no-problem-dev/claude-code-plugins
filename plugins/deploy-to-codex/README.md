# deploy-to-codex

Claude Code のスキル・エージェントを Codex CLI 互換形式に変換し、`.agents/` を自動生成するプラグイン。

2つのスキルを提供:

| スキル | 入力 | 用途 |
|--------|------|------|
| `/deploy-to-codex` | `marketplace.json` → `plugins/*/` | プラグインマーケットプレイスの変換 |
| `/codex-export` | `.claude/` ディレクトリ | 通常プロジェクトの変換 |

## 概要

Claude Code を SSOT（Single Source of Truth）として維持しつつ、Codex CLI ユーザーにもスキルを提供できる。

## deploy-to-codex

プラグインマーケットプレイスのリポジトリルートで実行:

```
/deploy-to-codex
```

marketplace.json を起点に、全プラグインのスキル・エージェントをスキャンして変換する。

## codex-export

`.claude/` ディレクトリを持つ任意のプロジェクトで実行:

```
/codex-export
```

`.claude/skills/`, `.claude/agents/`, `.claude/contexts/` をスキャンし、Codex CLI 互換の `.agents/` を生成する。コンテキストファイルは AGENTS.md に要約として統合される。

## 生成物

| 出力先 | 内容 |
|--------|------|
| `.agents/skills/{name}/SKILL.md` | 変換済みスキル |
| `.agents/AGENTS.md` | Codex 向けプロジェクトガイド（コンテキスト要約含む） |
| `.agents/.codex-export-metadata.json` | べき等性検証用メタデータ |

## 変換分類

| 分類 | 説明 | 扱い |
|------|------|------|
| PORTABLE | MCP/Task 参照なし | そのまま変換 |
| PARTIAL | MCP 参照あり + CLI フォールバック | 注記付きで変換 |
| MCP_ONLY | MCP 専用 | 警告バナー付きで生成 |
| DELEGATION_ONLY | サブエージェント委譲が主体 | スキップ（AGENTS.md に記載） |

## 非ポータブルコンポーネント

hooks, commands, rules, contexts, settings は Codex CLI 非対応のためスキップされ、AGENTS.md に記載される（codex-export ではコンテキストの要約は AGENTS.md に統合される）。
