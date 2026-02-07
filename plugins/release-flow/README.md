# release-flow

リリースワークフロー自動化プラグイン。CHANGELOG 管理、セマンティックバージョニング、GitHub Release 連携。

## インストール

### 1. マーケットプレイスの追加（初回のみ）

```bash
/plugin marketplace add no-problem-dev/claude-code-plugins
```

### 2. プラグインのインストール

Claude Code の設定画面（`/plugins`）から **release-flow** を選択してインストール

## スキル

| スキル | 用途 |
|--------|------|
| **release-workflow** | リリースワークフロー全体のオーケストレーター |
| **release-prepare** | リリース準備（CHANGELOG 更新・コミット・プッシュ） |
| **changelog-manage** | CHANGELOG エントリ追加・バージョン計算 |

キーワードで自動トリガーされます:
- `リリース`, `release`, `バージョン`, `version`
- `CHANGELOG`, `tag`, `GitHub Release`

## プラグイン構成

```
release-flow/
├── .claude-plugin/
│   └── plugin.json
├── references/
│   ├── RELEASE_PROCESS.md
│   └── auto-release-on-merge.yml
├── skills/
│   ├── release-workflow/
│   │   └── SKILL.md
│   ├── release-prepare/
│   │   └── SKILL.md
│   └── changelog-manage/
│       └── SKILL.md
└── README.md
```

## 参照

- [RELEASE_PROCESS.md](./references/RELEASE_PROCESS.md) - リリースプロセスガイド
- [auto-release-on-merge.yml](./references/auto-release-on-merge.yml) - GitHub Actions ワークフロー

## ライセンス

MIT
