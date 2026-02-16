# View Verification Tests（スナップショットテスト）

Swift Snapshot Testing を使用した SwiftUI ビューの視覚的検証ガイド。

## 依存関係の追加

Package.swift にスナップショットテストの依存関係を追加する:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.17.0"),
],
targets: [
    .testTarget(
        name: "MyAppTests",
        dependencies: [
            "MyApp",
            .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        ]
    ),
]
```

Xcode プロジェクトの場合は、File > Add Package Dependencies から `https://github.com/pointfreeco/swift-snapshot-testing` を追加し、テストターゲットにリンクする。

## 基本テンプレート

以下のテンプレートをテストターゲットにコピーして使用する:

```swift
import SnapshotTesting
import SwiftUI
import XCTest
@testable import MyApp
import DesignSystem

final class ViewVerificationTests: XCTestCase {

    // --- 初回実行時は record = true でスナップショットを記録 ---
    // --- 2回目以降は record = false に変更して差分検出 ---
    override func invokeTest() {
        // isRecording = true   // 初回記録時にコメント解除
        super.invokeTest()
    }

    // MARK: - 単一デバイス テスト

    func testMyView_default() {
        let view = MyView()
            .theme(ThemeProvider())

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    func testMyView_dark() {
        let view = MyView()
            .theme(ThemeProvider(initialMode: .dark))

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    func testMyView_largeText() {
        let view = MyView()
            .theme(ThemeProvider())
            .dynamicTypeSize(.xxxLarge)

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}
```

## 複数デバイスサイズ テンプレート

異なる画面サイズでの表示を一括テストする:

```swift
final class MultiDeviceVerificationTests: XCTestCase {

    // テスト対象のデバイス設定
    static let devices: [(name: String, config: ViewImageConfig)] = [
        ("iPhone_SE", .iPhoneSe),
        ("iPhone_15", .iPhone13),             // iPhone 15 と同サイズ
        ("iPhone_15_Pro_Max", .iPhone13ProMax), // iPhone 15 Pro Max と同サイズ
        ("iPad_Mini", .iPadMini),
        ("iPad_Pro_12_9", .iPadPro12_9),
    ]

    // MARK: - 全デバイスサイズでテスト

    func testMyView_allDevices() {
        for device in Self.devices {
            let view = MyView()
                .theme(ThemeProvider())

            assertSnapshot(
                of: view,
                as: .image(layout: .device(config: device.config)),
                named: device.name
            )
        }
    }

    // MARK: - ライト/ダーク両方 x 全デバイス

    func testMyView_allDevices_allModes() {
        let modes: [(name: String, mode: ThemeMode)] = [
            ("light", .light),
            ("dark", .dark),
        ]

        for device in Self.devices {
            for mode in modes {
                let view = MyView()
                    .theme(ThemeProvider(initialMode: mode.mode))

                assertSnapshot(
                    of: view,
                    as: .image(layout: .device(config: device.config)),
                    named: "\(device.name)_\(mode.name)"
                )
            }
        }
    }
}
```

## テーマバリアント テスト

複数のテーマでの表示を検証する:

```swift
func testMyView_themeVariants() {
    let themes: [(name: String, theme: any Theme)] = [
        ("default", DefaultTheme()),
        ("ocean", OceanTheme()),
        ("forest", ForestTheme()),
        ("highContrast", HighContrastTheme()),
    ]

    for themeInfo in themes {
        let view = MyView()
            .theme(ThemeProvider(initialTheme: themeInfo.theme))

        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: themeInfo.name
        )
    }
}
```

## アクセシビリティバリアント テスト

```swift
func testMyView_accessibility() {
    // Large Text
    let largeText = MyView()
        .theme(ThemeProvider())
        .dynamicTypeSize(.xxxLarge)

    assertSnapshot(
        of: largeText,
        as: .image(layout: .device(config: .iPhone13)),
        named: "largeText"
    )

    // Extra Large Text
    let extraLargeText = MyView()
        .theme(ThemeProvider())
        .dynamicTypeSize(.accessibility3)

    assertSnapshot(
        of: extraLargeText,
        as: .image(layout: .device(config: .iPhone13)),
        named: "accessibility3"
    )

    // High Contrast
    let highContrast = MyView()
        .theme(ThemeProvider(initialTheme: HighContrastTheme()))

    assertSnapshot(
        of: highContrast,
        as: .image(layout: .device(config: .iPhone13)),
        named: "highContrast"
    )

    // High Contrast + Dark
    let highContrastDark = MyView()
        .theme(ThemeProvider(initialTheme: HighContrastTheme(), initialMode: .dark))

    assertSnapshot(
        of: highContrastDark,
        as: .image(layout: .device(config: .iPhone13)),
        named: "highContrast_dark"
    )
}
```

## コンポーネント状態テスト

インタラクティブなコンポーネントの各状態を検証する:

```swift
func testLoginButton_states() {
    // 通常状態
    let normal = Button("ログイン") { }
        .buttonStyle(.primary)
        .buttonSize(.large)
        .theme(ThemeProvider())
        .padding()

    assertSnapshot(
        of: normal,
        as: .image(layout: .fixed(width: 320, height: 80)),
        named: "normal"
    )

    // 無効状態
    let disabled = Button("ログイン") { }
        .buttonStyle(.primary)
        .buttonSize(.large)
        .disabled(true)
        .theme(ThemeProvider())
        .padding()

    assertSnapshot(
        of: disabled,
        as: .image(layout: .fixed(width: 320, height: 80)),
        named: "disabled"
    )
}
```

## Claude Code でのワークフロー

### ビュー修正 -> テスト -> 確認 のサイクル

1. **ビューを修正する**
   - デザイントークンに従ってコードを変更

2. **スナップショットテストを実行する**
   ```bash
   xcodebuild test \
     -scheme MyApp \
     -destination 'platform=iOS Simulator,name=iPhone 15' \
     -only-testing:MyAppTests/ViewVerificationTests \
     2>&1 | tail -20
   ```

3. **結果を確認する**
   - テストが成功: スナップショットが一致、変更は視覚的に問題なし
   - テストが失敗: 差分画像が `__Snapshots__` ディレクトリに保存される

4. **スナップショットを更新する**（意図的な変更の場合）
   - テスト内で `isRecording = true` に設定して再実行
   - 新しい基準スナップショットが記録される
   - `isRecording = true` を元に戻す（コメントアウト or 削除）

### スナップショット画像の読み取り

Claude Code はスナップショット画像を直接読み取って視覚的に評価できる。
テスト失敗時に生成される画像ファイルのパスを確認し、Read ツールで画像を開く。

```
# スナップショット保存先（テストファイルと同階層）
MyAppTests/__Snapshots__/ViewVerificationTests/testMyView_default.1.png

# 差分画像（テスト失敗時に生成）
# failure ディレクトリに reference / failure / diff の 3 画像が保存される
```

### スナップショット比較

Swift Snapshot Testing はテスト失敗時に自動的に差分画像を生成する:

- **reference**: 基準となるスナップショット（前回記録したもの）
- **failure**: 今回のテスト実行結果
- **diff**: 差分のハイライト

これらの画像を Claude Code の Read ツールで読み取り、視覚的に差分を確認できる。
外部ツールのインストールは不要。

## レイアウトオプション

```swift
// デバイスサイズ（最も一般的）
.image(layout: .device(config: .iPhone13))

// 固定サイズ（コンポーネント単体テスト向け）
.image(layout: .fixed(width: 320, height: 200))

// コンテンツに合わせた自動サイズ
.image(layout: .sizeThatFits)
```

## 利用可能なデバイス設定

| 設定名 | 画面サイズ | 対応デバイス |
|--------|-----------|-------------|
| `.iPhoneSe` | 320x568 | iPhone SE (1st gen) |
| `.iPhone8` | 375x667 | iPhone 8, SE (2nd/3rd gen) |
| `.iPhone13` | 390x844 | iPhone 13/14/15 |
| `.iPhone13Pro` | 390x844 | iPhone 13/14/15 Pro |
| `.iPhone13ProMax` | 428x926 | iPhone 13/14/15 Pro Max |
| `.iPadMini` | 768x1024 | iPad mini |
| `.iPadPro11` | 834x1194 | iPad Pro 11" |
| `.iPadPro12_9` | 1024x1366 | iPad Pro 12.9" |

## design-system-workflow との統合

スナップショットテストは design-system-workflow の一部として以下のように使用する:

1. **新規 View 作成時**: テンプレートからテストファイルを作成し、`isRecording = true` で初回スナップショットを記録
2. **View 修正時**: テストを実行して意図しない視覚的変更がないことを確認
3. **テーマ変更時**: テーマバリアントテストで全テーマでの表示を検証
4. **アクセシビリティ確認時**: アクセシビリティバリアントテストで Dynamic Type と High Contrast を検証
