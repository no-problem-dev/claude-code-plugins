---
name: ios-build-workflow
description: iOS/Swift/Xcodeのビルド・テスト・実行ワークフロー。「iOSビルド」「Xcodeエラー」「コンパイル」「シミュレーター」「swift build」「xcodebuild」などのキーワードで自動適用。
---

# iOS Build Workflow

iOS/Swift/Xcode プロジェクトのビルド・テスト・実行ワークフロー。

## ビルド実行（推奨）

ビルドやテストは **サブエージェント** を使って実行することを推奨。
サブエージェントは独立したコンテキストで動作し、ビルドログでメインコンテキストを消費しない。

| エージェント | 用途 |
|-------------|------|
| **ios-build-runner** | iOS アプリのビルド |
| **ios-test-runner** | ユニットテスト実行 |
| **swift-build-runner** | Server-side Swift (SPM) ビルド |

## プロジェクト検出順序

以下の優先順位でプロジェクトを検出:

1. **xcworkspace（最優先）**: ユーザーが Xcode で開いているのはワークスペース
2. **xcodeproj**: ワークスペースがない場合
3. **Package.swift**: 純粋な SPM プロジェクト

**重要**: `.xcodeproj/project.xcworkspace` は除外（内部ファイル）

## 軽量コマンド

クイック操作用のコマンド（コンテキスト消費が少ない）:

| コマンド | 用途 |
|---------|------|
| `/ios-dev:ios-clean` | ビルドキャッシュクリア |
| `/ios-dev:ios-check` | コンパイルエラー高速チェック |

## 推奨ワークフロー

```
コード変更
    ↓
ios-build-runner（ビルド）
    ↓ 成功
ios-test-runner（テスト）
    ↓ 全テストパス
コミット・PR
```

## よくあるエラーと対処

### シミュレーターが見つからない

```
❌ No booted iPhone simulator found
```

**対処**: シミュレーターを起動
```bash
open -a Simulator
# または
xcrun simctl boot "iPhone 16 Pro"
```

### スキームが見つからない

```
xcodebuild: error: The project/workspace does not contain a scheme named '...'
```

**対処**: 利用可能なスキームを確認
```bash
# ワークスペースの場合
xcodebuild -list -workspace <name>.xcworkspace

# プロジェクトの場合
xcodebuild -list -project <name>.xcodeproj
```

### SPM依存関係エラー

```
error: Dependencies could not be resolved
```

**対処**: パッケージキャッシュをクリア
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
swift package resolve
```

## Server-side Swift

Server/ や Backend/ ディレクトリに Package.swift がある場合は `swift-build-runner` を使用。

```bash
# 手動実行の場合
cd Server && swift build
cd Server && swift test
```

## ios-architecture との連携

このプラグインは `ios-architecture` プラグインと補完関係:

- **ios-architecture**: 設計原則・レイヤー構成の知識
- **ios-dev**: ビルド・テスト・実行

両方をインストールすることで、設計に沿った開発とビルドワークフローの両方をサポート。
