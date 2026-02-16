---
name: design-diff
description: UIの視覚的差分を検出・比較する。デザイン変更前後の比較、リファレンスとの差分確認時に使用。「デザイン比較」「UI差分」「design diff」「design compare」「ビフォーアフター」「見た目の違い」などのキーワードで自動適用。
---

# デザイン差分スキル

UI の変更前後を比較し、視覚的な差分を検出・分析する。

---

## 比較手法

3つの手法を組み合わせて使用する。

### 1. Swift Snapshot Testing による差分検出（主要手法）

[swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) を使用してスナップショットの差分を検出する。

**仕組み**:
- `record: true` でリファレンス画像を保存
- `record: false`（デフォルト）で現在の状態をリファレンスと比較
- 差異がある場合、テストが失敗し差分画像が自動生成される

**差分画像の出力先**:
```
Tests/
  __Snapshots__/           # リファレンス画像
    TestClassName/
      testMethodName.1.png
  Failures/                # 差分画像（テスト失敗時に生成）
    testMethodName.1.png
```

### 2. Claude Vision による画像比較

2つの PNG 画像を Read ツールで読み込み、視覚的に比較する。

**使用場面**:
- スナップショットテストの差分画像を詳しく分析する場合
- リファレンスと現在のスナップショットを並べて確認する場合
- デザインモックアップとの比較

### 3. コードレベル差分

View のソースコードを比較し、トークンの変更を特定する。

**使用場面**:
- どのトークンが変わったか正確に把握したい場合
- 視覚的変化の原因を特定する場合

---

## ワークフロー

### Step 1: リファレンス状態の記録

```swift
import XCTest
import SnapshotTesting
@testable import YourApp

final class MyViewSnapshotTests: XCTestCase {
    func testMyView() {
        let view = MyView()
            .frame(width: 375)
            .theme(ThemeProvider())

        // リファレンス記録（初回のみ record: true）
        isRecording = true
        assertSnapshot(of: view, as: .image)
    }
}
```

テスト実行:
```bash
xcodebuild test \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:YourTests/MyViewSnapshotTests/testMyView
```

### Step 2: コードを変更

View のソースコードを修正する。

### Step 3: スナップショットテスト実行（差分検出）

```swift
// record を false に戻す（またはデフォルト）
func testMyView() {
    let view = MyView()
        .frame(width: 375)
        .theme(ThemeProvider())

    // リファレンスと比較（差異があればテスト失敗）
    assertSnapshot(of: view, as: .image)
}
```

テスト実行:
```bash
xcodebuild test \
  -scheme YourScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:YourTests/MyViewSnapshotTests/testMyView
```

**テストが失敗した場合**: 差分画像が `Failures/` ディレクトリに生成される。

### Step 4: 差分画像の確認

Read ツールで以下の画像を読み込んで分析する:

1. **リファレンス画像**: `__Snapshots__/TestClassName/testMethodName.1.png`
2. **失敗画像**: `Failures/testMethodName.1.png`（差分を含む）

### Step 5: 分析と判断

差分の内容に基づいて:
- **意図した変更**: Step 6 でスナップショットを更新
- **意図しない変更**: コードを修正して Step 3 に戻る

### Step 6: スナップショット更新（変更を受け入れる場合）

```swift
// 一時的に record: true に戻してリファレンスを更新
isRecording = true
assertSnapshot(of: view, as: .image)
```

テスト実行後、`isRecording = true` を削除してコミット。

---

## 差分レポートフォーマット

```markdown
# Design Diff レポート

**対象**: `MyView.swift`
**比較**: リファレンス vs 現在

## 変更サマリー

| 項目 | Before | After | 影響 |
|------|--------|-------|------|
| 背景色 | surface | primaryContainer | 視覚的に大きい変化 |
| パディング | spacing.md (12pt) | spacing.lg (16pt) | レイアウトに影響 |
| 角丸 | radius.md | radius.lg | 軽微な変化 |

## 視覚的差分

- **変化あり**: 背景色がより強調された色に変更
- **変化あり**: 内部余白が広がりコンテンツが収縮
- **変化なし**: テキスト、アイコン、アニメーション

## Design System 準拠性

変更後の状態が Design System に準拠しているか:
- ✅ すべてのカラーが ColorPalette 経由
- ✅ すべてのスペーシングが SpacingScale 経由
- ⚠️ ダークモードでの確認が必要
```

---

## design-audit との連携

差分検出後、変更が Design System 準拠性を改善したか悪化させたかを確認する:

1. 変更前のコードで `design-audit` を実行（結果を記録）
2. コードを変更
3. `design-diff` で視覚的差分を確認
4. 変更後のコードで `design-audit` を再実行
5. 監査スコアの変化を比較

---

## 推奨テスト構成

```swift
final class MyViewSnapshotTests: XCTestCase {
    // デフォルトテーマ・ライトモード
    func testDefault() {
        let view = MyView()
            .frame(width: 375)
            .theme(ThemeProvider())
        assertSnapshot(of: view, as: .image)
    }

    // ダークモード
    func testDarkMode() {
        let view = MyView()
            .frame(width: 375)
            .theme(ThemeProvider(initialMode: .dark))
        assertSnapshot(of: view, as: .image)
    }

    // Large Text
    func testLargeText() {
        let view = MyView()
            .frame(width: 375)
            .theme(ThemeProvider())
            .environment(\.sizeCategory, .accessibilityExtraLarge)
        assertSnapshot(of: view, as: .image)
    }

    // 別テーマ
    func testOceanTheme() {
        let view = MyView()
            .frame(width: 375)
            .theme(ThemeProvider(initialTheme: OceanTheme()))
        assertSnapshot(of: view, as: .image)
    }
}
```

---

## 関連スキル

- **design-system-workflow**: トークン・コンポーネントの詳細リファレンス
- **design-audit**: Design System 準拠性監査
- **component-gen**: 新規コンポーネント生成
- **ios-build-workflow**: テスト実行
