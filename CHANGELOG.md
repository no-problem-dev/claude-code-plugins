# Changelog

このプロジェクトのすべての注目すべき変更はこのファイルに記載されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

なし

## [1.0.4] - 2025-11-30

### 修正

- **ios-dev, go-backend, firebase-emulator**: plugin.json の `commands`/`skills` パスを正しいフォーマットに修正
  - `"./"` プレフィックスを追加（`"commands"` → `"./commands/"`）
- **notify-on-stop**: `hooks` フィールドを削除（`hooks/hooks.json` は自動読み込みされるため重複エラーになっていた）

### 変更

- **README**: プラグイン一覧をカテゴリ別に整理
  - 開発ワークフロー: ios-dev, go-backend, firebase-emulator
  - アーキテクチャ・設計: ios-architecture
  - ユーティリティ: release-flow, notify-on-stop

## [1.0.3] - 2025-11-30

### 追加

- **ios-dev**: iOS/Swift/Xcode ビルド・テスト・実行コマンド群
  - `/ios-check`, `/ios-build`, `/ios-run`, `/ios-test`, `/ios-clean` コマンド
  - 動的シミュレーターID検出（起動中シミュレーターを自動検出）
  - SPM パッケージ構成のiOSアプリ開発をサポート
  - 環境変数によるプロジェクト固有設定の注入に対応
- **go-backend**: Go バックエンド ビルド・テスト・Lint コマンド群
  - `/go-build`, `/go-test`, `/go-lint`, `/go-run`, `/go-tidy`, `/go-swagger` コマンド
  - golangci-lint による静的解析
  - swag による Swagger ドキュメント自動生成
  - 環境変数によるプロジェクト固有設定の注入に対応
- **firebase-emulator**: Firebase Emulator Suite 起動・停止・管理コマンド群
  - `/emulator-start`, `/emulator-stop`, `/emulator-status` コマンド
  - バックグラウンドプロセス管理
  - ポート設定のカスタマイズに対応

## [1.0.2] - 2025-11-30

### 修正

- **notify-on-stop**: hooks.json フォーマットを公式プラグイン構造に準拠するよう修正
  - plugin.json の hooks フィールドをディレクトリからファイルパスに変更
  - hooks.json に description フィールドを追加
  - 不要な matcher フィールドを削除
  - プラグインインストール時にフックが自動的に統合されるよう修正

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

[1.0.4]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.4
[1.0.3]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.3
[1.0.2]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.2
[1.0.1]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.1
[1.0.0]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.0

<!-- Auto-generated on 2025-11-29T23:49:25Z by release workflow -->

<!-- Auto-generated on 2025-11-30T00:23:25Z by release workflow -->

<!-- Auto-generated on 2025-11-30T00:45:09Z by release workflow -->

<!-- Auto-generated on 2025-11-30T02:43:29Z by release workflow -->

<!-- Auto-generated on 2025-11-30T03:05:12Z by release workflow -->
