# ios-dev

iOS/Swift/Xcode のビルド・テスト・実行コマンド群。SPMパッケージ構成のiOSアプリ開発をサポート。

## インストール

Claude Code の `/plugins` UI からインストール、または:

```bash
claude plugins:install ios-dev
```

## コマンド一覧

| コマンド | 説明 |
|---------|------|
| `/ios-dev:ios-check` | コンパイルエラーを高速チェック |
| `/ios-dev:ios-build` | フルビルド実行 |
| `/ios-dev:ios-run` | シミュレーターで実行 |
| `/ios-dev:ios-test` | ユニットテスト実行 |
| `/ios-dev:ios-clean` | ビルドキャッシュクリア |

## スキル

**ios-build-workflow**: iOS開発ワークフローの知識が自動適用されます。

以下のキーワードで自動トリガー:
- `iOSビルド`, `Xcodeエラー`, `コンパイル`
- `シミュレーター`, `swift build`, `xcodebuild`

## 環境変数

プロジェクト固有の設定は環境変数で上書き可能:

| 変数 | 説明 | デフォルト |
|------|------|-----------|
| `IOS_PROJECT` | .xcodeproj パス | 自動検出 |
| `IOS_SCHEME` | ビルドスキーム | プロジェクト名 |
| `IOS_SIMULATOR` | シミュレーター名 | `iPhone 16 Pro` |

## プロジェクト構成

このプラグインは以下の構成を自動検出:

### 1. Makefile ベース（推奨）

```
project/
├── Makefile          # ios-check, ios-build 等のターゲット
└── ios-app/
    ├── Makefile      # check, build 等のターゲット
    └── App.xcodeproj
```

Makefileターゲットがあれば優先的に使用します。

### 2. Xcode プロジェクト直接

```
project/
└── App.xcodeproj
```

### 3. Swift Package Manager

```
project/
└── Package.swift
```

## プラグイン構成

```
ios-dev/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── ios-build.md
│   ├── ios-check.md
│   ├── ios-clean.md
│   ├── ios-run.md
│   └── ios-test.md
├── scripts/
│   ├── common.sh       # 共通関数
│   ├── ios-build.sh
│   ├── ios-check.sh
│   ├── ios-clean.sh
│   ├── ios-run.sh
│   └── ios-test.sh
├── skills/
│   └── ios-build-workflow/
│       └── SKILL.md
└── README.md
```

## 推奨ワークフロー

```
1. コード変更
2. /ios-dev:ios-check  → 高速エラーチェック
3. /ios-dev:ios-build  → フルビルド
4. /ios-dev:ios-run    → 動作確認
5. /ios-dev:ios-test   → テスト実行
6. コミット・PR
```

## 関連プラグイン

- **ios-architecture**: iOS クリーンアーキテクチャの設計原則（補完関係）

## ライセンス

MIT
