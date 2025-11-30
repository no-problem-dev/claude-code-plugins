# release-flow

リリースワークフロー自動化プラグイン

## インストール

### 1. マーケットプレイスの追加（初回のみ）

```bash
/plugin marketplace add no-problem-dev/claude-code-plugins
```

### 2. プラグインのインストール

Claude Code の設定画面（`/plugins`）から **release-flow** を選択してインストール

## コマンド

- `/release-prepare <version>` - リリース準備
- `/changelog-add <category> <description>` - CHANGELOG エントリ追加
- `/version-bump <type>` - バージョン計算（major/minor/patch）

## スキル

- **release-workflow** - セマンティックバージョニング、Keep a Changelog、GitHub Actions

## 参照

- [RELEASE_PROCESS.md](./references/RELEASE_PROCESS.md) - リリースプロセスガイド
- [auto-release-on-merge.yml](./references/auto-release-on-merge.yml) - GitHub Actions ワークフロー
