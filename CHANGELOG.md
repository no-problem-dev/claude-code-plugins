# Changelog

このプロジェクトのすべての注目すべき変更はこのファイルに記載されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

なし

## [1.0.1] - 2025-11-30

### 追加

- **notify-on-stop**: Claude Code の停止・権限要求時に通知を送信するプラグイン
  - Slack 通知（Bot Token / Incoming Webhook 対応）
  - macOS ローカル通知（作業完了、入力待ち、権限要求、サブエージェント完了）
  - `/notify-setup`, `/notify-test` コマンド
  - Hooks による自動通知連携

## [1.0.0] - 2025-11-30

### 追加

- **release-flow**: リリースワークフロー自動化プラグイン
  - `/release-prepare`, `/changelog-add`, `/version-bump` コマンド
  - release-workflow スキル
  - GitHub Actions 自動リリースワークフロー
- **ios-architecture**: iOS Clean Architecture スキル（Stockle より）
  - SPM マルチモジュール構成
  - レイヤー依存関係ガイド
- マーケットプレイス設定（plugin-dev@anthropic-official 参照）

[1.0.1]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.1
[1.0.0]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.0

<!-- Auto-generated on 2025-11-29T23:49:25Z by release workflow -->

<!-- Auto-generated on 2025-11-30T00:23:25Z by release workflow -->
