# ios-dev

iOS/Swift/Xcode のビルド・テスト・実行。xcworkspace 対応、Server-side Swift 対応。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install ios-dev
```

## サブエージェント（推奨）

ビルドやテストは **サブエージェント** で実行することを推奨。独立したコンテキストで動作し、メインの会話コンテキストを消費しません。

| エージェント | 用途 | モデル |
|-------------|------|--------|
| **ios-build-runner** | iOS アプリのビルド | Sonnet |
| **ios-test-runner** | ユニットテスト実行 | Sonnet |
| **swift-build-runner** | Server-side Swift (SPM) ビルド | Sonnet |

### 使用例

```
「Reading Memory をビルドして」
→ ios-build-runner が xcworkspace を検出してビルド実行
→ サマリーのみ返却（フルログは返さない）

「サーバーをビルドして」
→ swift-build-runner が Server/Package.swift をビルド
```

## コマンド（軽量操作向け）

短い出力のクイック操作用:

| コマンド | 説明 |
|---------|------|
| `/ios-dev:ios-clean` | ビルドキャッシュクリア |
| `/ios-dev:ios-check` | コンパイルエラー高速チェック |

## プロジェクト検出順序

以下の優先順位で自動検出:

1. **xcworkspace（最優先）** - ユーザーが Xcode で開いているのはワークスペース
2. **xcodeproj** - ワークスペースがない場合
3. **Package.swift** - 純粋な SPM プロジェクト

※ `.xcodeproj/project.xcworkspace` は除外（内部ファイル）

## 対応プロジェクト構成

### 1. iOS + Server-side Swift（推奨構成）

```
project/
├── Project.xcworkspace    ← iOS ビルドはこれを使用
├── iOS/
│   ├── App.xcodeproj
│   └── Packages/
├── Server/
│   └── Package.swift      ← swift-build-runner で対応
└── Shared/
    └── Package.swift
```

### 2. iOS のみ（xcworkspace）

```
project/
├── Project.xcworkspace
└── iOS/
    ├── App.xcodeproj
    └── Packages/
```

### 3. iOS のみ（xcodeproj）

```
project/
└── App.xcodeproj
```

### 4. Swift Package のみ

```
project/
├── Package.swift
├── Sources/
└── Tests/
```

## プラグイン構成

```
ios-dev/
├── .claude-plugin/
│   └── plugin.json
├── agents/                   # サブエージェント（推奨）
│   ├── ios-build-runner.md
│   ├── ios-test-runner.md
│   └── swift-build-runner.md
├── commands/                 # 軽量コマンド
│   ├── ios-check.md
│   └── ios-clean.md
├── skills/
│   └── ios-build-workflow/
│       └── SKILL.md
└── README.md
```

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

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則
- **swift-design-system**: Swift Design System を使った UI 実装

## ライセンス

MIT
