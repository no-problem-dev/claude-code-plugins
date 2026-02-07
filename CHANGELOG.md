# Changelog

このプロジェクトのすべての注目すべき変更はこのファイルに記載されます。

フォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

## [1.0.7] - 2026-02-07

### 変更

- **ios-dev**: MCP ビルド/テスト実行をスキル層に移動（v2.1）
  - サブエージェントは Claude Code の制限により MCP ツールにアクセスできないため、MCP 実行をワークフロースキル（`ios-dev-workflow`）に引き上げ
  - `ios-build-runner` / `ios-test-runner` を CLI 専用に簡素化
  - MCP 利用可能時はスキルで直接 `BuildProject` / `RunAllTests` を実行、不可時はサブエージェントにフォールバック
  - `VERIFICATION.md` のサブエージェント MCP アクセス項目を N/A に更新

## [1.0.6] - 2026-02-07

### 追加

- **ios-dev**: v2.0 — commands → skills/agents アーキテクチャに全面移行
  - ビルド・テストをサブエージェント化（`ios-build-runner`, `ios-test-runner`）で隔離実行
  - 診断・プレビュー・情報・メンテナンスを機能別スキルに分割
  - Xcode MCP ハイブリッド対応（MCP 優先、CLI フォールバック）
  - 全スキル・エージェントの日本語化
- **go-backend**: v2.0 — commands → skills/agents アーキテクチャに移行
  - ビルド・テストをサブエージェント化（`go-build-runner`, `go-test-runner`）
  - 品質チェック（`go-quality`）、開発サーバー（`go-dev-server`）、メンテナンス（`go-maintenance`）スキルを追加
- **firebase-emulator**: v2.0 — commands → skills アーキテクチャに移行
  - エミュレーター操作を `emulator-control` スキルに統合
  - スクリプトはポート管理ロジックのため維持
- **release-flow**: v2.0 — commands → skills アーキテクチャに移行
  - リリース準備（`release-prepare`）、CHANGELOG・バージョン管理（`changelog-manage`）スキルを追加

### 変更

- **全プラグイン**: スキル description を `日本語説明。「keyword」...` パターンに統一
- **release-flow**: plugin.json description・workflow スキルを日本語化

### 削除

- **go-backend, firebase-emulator, release-flow**: 旧 commands/ ディレクトリを廃止（skills/agents に移行済み）
- **go-backend**: scripts/ ディレクトリを廃止（ロジックをスキル/エージェントにインライン化）

## [1.0.5] - 2025-11-30

### 追加

- **swift-design-system**: no problem製 swift-design-system パッケージを使用した iOS UI 実装スキル
  - 3層トークンシステム（Primitive → Semantic → Component）のリファレンス
  - デザイントークン: カラー、タイポグラフィ、スペーシング、角丸、モーション、エレベーション
  - UIコンポーネント: Button, Card, Chip, FAB, Snackbar
  - Picker コンポーネント: ColorPicker, EmojiPicker, IconPicker, ImagePicker
  - レイアウトパターン: AspectGrid, SectionCard, Theme

### 変更

- **ios-architecture, release-flow**: plugin.json の description を日本語化
  - 全プラグインの説明文を統一して日本語に

### 修正

- **ios-dev**: シミュレーターログ表示を改善
  - 起動中のシミュレーター名を正しく表示するよう修正
  - `get_booted_simulator_name()` 関数を追加
  - ios-check, ios-build, ios-test スクリプトで実際のシミュレーター名を表示

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

[1.0.7]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.7
[1.0.6]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.6
[1.0.5]: https://github.com/no-problem-dev/claude-code-plugins/releases/tag/v1.0.5
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

<!-- Auto-generated on 2025-11-30T04:03:48Z by release workflow -->

<!-- Auto-generated on 2026-02-07T05:39:39Z by release workflow -->
