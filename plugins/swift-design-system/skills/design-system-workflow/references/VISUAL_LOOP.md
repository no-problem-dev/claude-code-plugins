# Visual Feedback Loop ガイド

Claude が SwiftUI コードを生成し、視覚的に検証し、改善するためのイテレーションワークフロー。

---

## 1. Visual Feedback Loop とは

UI コードを書いた後、実際の描画結果を確認せずに次に進むのは危険。Visual Feedback Loop は以下のサイクルを回す:

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌──────────┐     ┌─────────┐
│ Generate │ ──→ │  Build  │ ──→ │   See   │ ──→ │ Evaluate │ ──→ │ Modify  │
│ コード生成 │     │ ビルド   │     │ 確認    │     │  評価     │     │  修正    │
└─────────┘     └─────────┘     └─────────┘     └──────────┘     └─────────┘
      ↑                                                                │
      └────────────────────────────────────────────────────────────────┘
```

**3-5 ラウンド以内に収束させる**ことを目標にする。各ラウンドでは1つの品質軸に集中する。

---

## 2. 方法 1: Swift Snapshot Testing（推奨）

最も信頼性が高く、自動化可能な方法。スナップショット画像を生成し、Claude が Read ツールで画像を確認できる。

### セットアップ

#### SPM 依存関係の追加

`Package.swift` に swift-snapshot-testing を追加:

```swift
// Package.swift
let package = Package(
    name: "MyApp",
    // ...
    dependencies: [
        .package(url: "https://github.com/no-problem-dev/swift-design-system.git", from: "X.X.X"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0"),
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                .product(name: "DesignSystem", package: "swift-design-system"),
            ]
        ),
        .testTarget(
            name: "ViewVerificationTests",
            dependencies: [
                "MyApp",
                .product(name: "DesignSystem", package: "swift-design-system"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
```

Xcode プロジェクトの場合は、テストターゲットに SPM 依存を追加する。

#### テストファイルの基本構造

```swift
// Tests/ViewVerificationTests/ViewVerificationTests.swift

import XCTest
import SnapshotTesting
import SwiftUI
import DesignSystem
@testable import MyApp

final class ViewVerificationTests: XCTestCase {

    // テスト実行前にリセット（差分を正確に取るため）
    override func setUp() {
        super.setUp()
        // isRecording = true  // 初回のみ true にしてリファレンス画像を生成
    }

    // MARK: - Component Tests

    func testTaskCard_default() {
        let view = TaskCard(
            title: "デザインレビュー",
            subtitle: "明日 14:00 まで",
            isCompleted: false
        )
        .theme(ThemeProvider(initialMode: .light))
        .frame(width: 393)  // iPhone 15 幅

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func testTaskCard_darkMode() {
        let view = TaskCard(
            title: "デザインレビュー",
            subtitle: "明日 14:00 まで",
            isCompleted: false
        )
        .theme(ThemeProvider(initialMode: .dark))
        .frame(width: 393)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func testTaskCard_completed() {
        let view = TaskCard(
            title: "デザインレビュー",
            subtitle: "完了",
            isCompleted: true
        )
        .theme(ThemeProvider(initialMode: .light))
        .frame(width: 393)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    func testTaskCard_longText() {
        let view = TaskCard(
            title: "非常に長いタスク名がここに入る場合のレイアウト確認用テキスト",
            subtitle: "2024年12月31日 23:59 までに完了する必要があります。遅延すると影響が出ます。",
            isCompleted: false
        )
        .theme(ThemeProvider(initialMode: .light))
        .frame(width: 393)

        assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
    }

    // MARK: - Screen Tests

    func testTaskListScreen_withData() {
        let view = TaskListScreen(
            tasks: TaskItem.sampleTasks,
            isLoading: false,
            error: nil
        )
        .theme(ThemeProvider(initialMode: .light))

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    func testTaskListScreen_emptyState() {
        let view = TaskListScreen(
            tasks: [],
            isLoading: false,
            error: nil
        )
        .theme(ThemeProvider(initialMode: .light))

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    func testTaskListScreen_errorState() {
        let view = TaskListScreen(
            tasks: [],
            isLoading: false,
            error: "ネットワークエラーが発生しました"
        )
        .theme(ThemeProvider(initialMode: .light))

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
```

### イテレーションループ

#### Step 1: コード生成

Claude が SwiftUI View コードを生成する。

#### Step 2: リファレンス画像の記録

初回は `isRecording = true` でスナップショットを記録:

```bash
xcodebuild test \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    -only-testing:ViewVerificationTests/ViewVerificationTests/testTaskCard_default \
    2>&1 | tail -20
```

#### Step 3: スナップショット画像を確認

生成された画像を Read ツールで確認:

```
Tests/ViewVerificationTests/__Snapshots__/ViewVerificationTests/testTaskCard_default.1.png
```

Claude は Read ツールで PNG ファイルを直接読み取って視覚的に評価できる。

#### Step 4: 評価と修正

画像を見て問題を特定し、コードを修正する。修正後は `isRecording = false` にしてテストを再実行。差分がある場合はテストが失敗し、差分画像が生成される。

#### Step 5: 差分画像の確認

テスト失敗時は以下のファイルが生成される:

```
Tests/ViewVerificationTests/__Snapshots__/ViewVerificationTests/
├── testTaskCard_default.1.png          # リファレンス画像
└── testTaskCard_default.1.png           # 差分がある場合のみ失敗
```

失敗メッセージにリファレンス画像と実際の画像のパスが含まれる。

### テーマバリエーションのスナップショット

```swift
func testTaskCard_allThemes() {
    let themeIds = ["default", "ocean", "forest", "sunset", "purplehaze", "monochrome"]

    for themeId in themeIds {
        let provider = ThemeProvider(initialMode: .light)
        provider.switchToTheme(id: themeId)

        let view = TaskCard(
            title: "デザインレビュー",
            subtitle: "明日 14:00 まで",
            isCompleted: false
        )
        .theme(provider)
        .frame(width: 393)

        assertSnapshot(
            of: view,
            as: .image(layout: .sizeThatFits),
            named: themeId
        )
    }
}
```

---

## 3. 方法 2: Xcode Preview MCP（利用可能な場合）

`ios-dev` プラグインの `ios-preview-repl` スキルが利用可能な場合、RenderPreview ツールで Preview を直接レンダリングできる。

### 使い方

```
/ios-preview-repl
```

スキルが有効になると、以下のようにプレビューをレンダリングできる:

1. SwiftUI View コードを書く
2. `#Preview` マクロを追加
3. RenderPreview ツールでプレビュー画像を取得
4. 画像を評価して修正

### 利点

- ビルド不要で高速にフィードバックを得られる
- スナップショットテストの準備が不要
- インタラクティブな確認が可能

### 制限

- MCP サーバーのセットアップが必要
- Xcode が起動している必要がある
- 複雑なプロジェクト依存がある場合はビルドエラーの可能性

**フォールバック**: Preview MCP が利用できない場合は方法 1（Snapshot Testing）または方法 3（手動ビルド）を使用する。

---

## 4. 方法 3: 手動ビルド + スクリーンショット

Snapshot Testing のセットアップが難しい場合や、実機に近い確認が必要な場合に使用する。

### Step 1: シミュレータの準備

```bash
# 利用可能なシミュレータを一覧
xcrun simctl list devices available | grep iPhone

# シミュレータを起動（未起動の場合）
xcrun simctl boot "iPhone 15"

# 起動確認
xcrun simctl list devices booted
```

### Step 2: ビルドとインストール

```bash
# ビルド
xcodebuild build \
    -scheme MyApp \
    -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
    -derivedDataPath ./build \
    2>&1 | tail -5

# アプリをインストール
xcrun simctl install booted ./build/Build/Products/Debug-iphonesimulator/MyApp.app

# アプリを起動
xcrun simctl launch booted com.example.MyApp
```

### Step 3: スクリーンショット撮影

```bash
# スクリーンショットを撮影
xcrun simctl io booted screenshot /tmp/screenshot.png

# Claude が Read ツールで画像を確認
```

### Step 4: 評価と修正

スクリーンショットを Read ツールで確認し、問題を特定してコードを修正。修正後は再ビルド → 再起動 → 再スクリーンショットのサイクルを回す。

### Dark Mode の切り替え

```bash
# ダークモードに切り替え
xcrun simctl ui booted appearance dark

# スクリーンショット
xcrun simctl io booted screenshot /tmp/screenshot_dark.png

# ライトモードに戻す
xcrun simctl ui booted appearance light
```

### テキストサイズの変更

```bash
# アクセシビリティ設定でテキストサイズを変更
# (simctl では直接変更できないため、アプリ内で環境値をオーバーライドするか
#  Settings.app から手動で変更する)
```

---

## 5. ベストプラクティス

### 1ラウンド1品質軸の原則

一度にすべてを直そうとしない。各イテレーションで1つの品質軸に集中する:

```
Round 1: レイアウト（配置、サイズ、余白）
Round 2: カラー（テーマ対応、コントラスト、階層）
Round 3: タイポグラフィ（サイズ、ウェイト、行間）
Round 4: モーション（アニメーション、トランジション）
Round 5: エッジケース（Long Text、Empty State、Dark Mode）
```

### 具体的なフィードバック

```
// BAD: 曖昧なフィードバック
「もう少しスペースを空けて」
「色をもう少し薄く」

// GOOD: 具体的なフィードバック
「タイトルとサブタイトルの間を spacing.md (12pt) に変更」
「背景色を colors.surface から colors.surfaceVariant に変更」
「ボタンの角丸を radius.full に変更」
「カードのエレベーションを .level1 から .level2 に変更」
```

### Light/Dark 同時テスト

常に両方のモードで確認する:

```swift
// スナップショットテストでは両方を必ず含める
func testComponent_light() {
    let view = MyComponent()
        .theme(ThemeProvider(initialMode: .light))
    assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
}

func testComponent_dark() {
    let view = MyComponent()
        .theme(ThemeProvider(initialMode: .dark))
    assertSnapshot(of: view, as: .image(layout: .sizeThatFits))
}
```

### イテレーション回数の制限

- **3ラウンド**: コンポーネント（Button、Card、Chip など）
- **5ラウンド**: 画面（リスト画面、詳細画面など）
- **超過する場合**: 設計を見直す。根本的な構造の問題がある可能性

### 品質チェックポイント

各ラウンドの終了時に確認:

- [ ] デザイントークンがハードコードされていない
- [ ] ThemeProvider でラップされている
- [ ] Light/Dark 両方で確認した
- [ ] 長いテキストでレイアウトが崩れない
- [ ] アクセシビリティ（Dynamic Type）に対応している

---

## 6. デザインシステムとの連携

### Visual Loop でトークンを検証する

```
問題: 「カードの影が強すぎる」
 → elevation を .level2 → .level1 に変更

問題: 「テキストの間隔が詰まりすぎている」
 → spacing を .sm → .md に変更

問題: 「ボタンの色がアクション感がない」
 → colors.secondary → colors.primary に変更

問題: 「角丸がシャープすぎる」
 → radius.sm → radius.md に変更
```

### テーマ切り替えテスト

Visual Loop ではデフォルトテーマだけでなく、複数テーマで確認する:

```swift
// 主要テーマでのスナップショット
let testThemes = ["default", "ocean", "forest", "monochrome", "highcontrast"]

for themeId in testThemes {
    let provider = ThemeProvider(initialMode: .light)
    provider.switchToTheme(id: themeId)

    let view = MyScreen().theme(provider)

    assertSnapshot(
        of: view,
        as: .image(layout: .device(config: .iPhone13)),
        named: "\(themeId)-light"
    )

    provider.themeMode = .dark
    assertSnapshot(
        of: view,
        as: .image(layout: .device(config: .iPhone13)),
        named: "\(themeId)-dark"
    )
}
```

### デザイントークンの問題を発見するパターン

| 視覚的な問題 | 原因 | 修正 |
|------------|------|------|
| 背景とテキストの区別がつかない | `on~` カラーの不使用 | `colors.onSurface` を使う |
| すべてが同じ高さに見える | Elevation 未設定 | カードに `.level1-2` を適用 |
| テキストサイズの差がわからない | Typography の階層不足 | `headlineSmall` + `bodyMedium` + `labelSmall` |
| 余白が不規則 | ハードコードされた数値 | `spacing.sm/md/lg` に統一 |
| ダークモードで色が見えない | Light 専用の色を使用 | `colorPalette` 経由に変更 |

---

## 方法選択ガイド

| 状況 | 推奨方法 |
|------|---------|
| 新規コンポーネント開発 | 方法 1 (Snapshot Testing) |
| 既存コンポーネントの改修 | 方法 1 (Snapshot Testing) - 差分検出 |
| 素早いプロトタイピング | 方法 2 (Preview MCP) > 方法 1 |
| 実機に近い確認が必要 | 方法 3 (手動ビルド) |
| CI/CD への組み込み | 方法 1 (Snapshot Testing) 一択 |
| テーマ一括確認 | 方法 1 (Snapshot Testing) |
