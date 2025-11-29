# release-flow

リリースワークフロー自動化プラグイン

## インストール

```bash
/plugin install release-flow@no-problem-plugins
```

## コマンド

- `/release-prepare <version>` - リリース準備
- `/changelog-add <category> <description>` - CHANGELOG エントリ追加
- `/version-bump <type>` - バージョン計算（major/minor/patch）

## スキル

- **release-workflow** - セマンティックバージョニング、Keep a Changelog、GitHub Actions

## 参照

- [RELEASE_PROCESS.md](./references/RELEASE_PROCESS.md) - リリースプロセスガイド
- [auto-release-on-merge.yml](./references/auto-release-on-merge.yml) - GitHub Actions ワークフロー
