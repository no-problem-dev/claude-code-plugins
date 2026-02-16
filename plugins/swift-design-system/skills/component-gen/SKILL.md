---
name: component-gen
description: デザインシステム準拠のSwiftUIコンポーネントを生成する。新しいUIパーツの作成、コンポーネント生成時に使用。「コンポーネント作成」「新しいUI」「パーツ作成」「component generate」「UIパーツ」「新規コンポーネント」などのキーワードで自動適用。
---

# コンポーネント生成スキル

Swift Design System に準拠した新規 SwiftUI コンポーネントを生成するためのガイド。

---

## 生成前チェックリスト

コンポーネントを生成する前に、以下を確認すること:

1. **目的の明確化**: このコンポーネントは何を解決するか？
2. **既存コンポーネントの確認**: 既に同等のものがないか確認
   - Button (Primary/Secondary/Tertiary), Card, Chip, FloatingActionButton
   - IconBadge, IconButton, ProgressBar, Snackbar, StatDisplay
   - TextField (DSTextField), VideoPlayer
   - Layout: AspectGrid, SectionCard
   - Pickers: ColorPicker, EmojiPicker, IconPicker, ImagePicker
3. **必要なトークンの特定**: どのトークンを使用するか
   - ColorPalette, SpacingScale, RadiusScale, Motion, Elevation, Typography

---

## コード生成テンプレート

### 基本構造

```swift
import SwiftUI
import DesignSystem

/// コンポーネントの説明
///
/// 使用場面と目的を記述。
///
/// ## 使用例
/// ```swift
/// MyComponent(title: "タイトル") {
///     Text("コンテンツ")
/// }
/// ```
public struct MyComponent<Content: View>: View {
    // MARK: - Environment（必要なトークンのみ宣言）

    @Environment(\.colorPalette) private var colors
    @Environment(\.spacingScale) private var spacing
    @Environment(\.radiusScale) private var radius
    @Environment(\.motion) private var motion

    // MARK: - Properties

    private let title: String
    private let content: Content

    // MARK: - Init

    public init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing.md) {
            Text(title)
                .typography(.titleMedium)
                .foregroundStyle(colors.onSurface)

            content
        }
        .padding(spacing.lg)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: radius.lg))
        .elevation(.level1)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }
}
```

### 重要な実装パターン

#### Environment アクセス

```swift
// 必要なトークンのみ宣言する
@Environment(\.colorPalette) private var colors
@Environment(\.spacingScale) private var spacing
@Environment(\.radiusScale) private var radius
@Environment(\.motion) private var motion
```

#### ThemeProvider ラッピング（Preview で必須）

```swift
#Preview {
    MyComponent(title: "サンプル") {
        Text("コンテンツ")
    }
    .padding()
    .theme(ThemeProvider())
}
```

#### ViewModifier パターン

```swift
// Typography
Text("見出し").typography(.headlineLarge)

// Elevation
Card { content }.elevation(.level2)

// Animation（reduce motion を自動尊重）
.animate(motion.tap, value: isPressed)
```

#### アクセシビリティ

```swift
// ラベル
.accessibilityLabel("説明テキスト")

// 最小タップターゲット 44x44pt
.frame(minWidth: 44, minHeight: 44)

// セマンティクス
.accessibilityElement(children: .contain)
.accessibilityAddTraits(.isButton)  // インタラクティブ要素の場合
```

#### SF Symbols（アイコン）

```swift
// SF Symbols を使用
Image(systemName: "star.fill")
    .foregroundStyle(colors.primary)

// IconBadge コンポーネント
IconBadge(systemName: "bell.fill", size: .medium)
```

---

## 必須 Preview 状態

最低5つの Preview を用意すること:

```swift
// 1. デフォルト状態
#Preview("Default") {
    MyComponent(title: "デフォルト") {
        Text("通常表示")
            .typography(.bodyMedium)
    }
    .padding()
    .theme(ThemeProvider())
}

// 2. ダークモード
#Preview("Dark Mode") {
    MyComponent(title: "ダークモード") {
        Text("ダーク表示")
            .typography(.bodyMedium)
    }
    .padding()
    .theme(ThemeProvider(initialMode: .dark))
}

// 3. 大きなテキスト (Dynamic Type)
#Preview("Large Text") {
    MyComponent(title: "大きなテキスト") {
        Text("Dynamic Type 対応確認")
            .typography(.bodyMedium)
    }
    .padding()
    .theme(ThemeProvider())
    .environment(\.sizeCategory, .accessibilityExtraLarge)
}

// 4. コンパクト (最小コンテンツ)
#Preview("Compact") {
    MyComponent(title: "短") {
        Text("OK")
            .typography(.bodyMedium)
    }
    .padding()
    .theme(ThemeProvider())
}

// 5. エッジケース (長いテキスト、大量データ)
#Preview("Edge Case") {
    MyComponent(title: "非常に長いタイトルが入った場合の表示確認テスト") {
        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
            .typography(.bodyMedium)
    }
    .padding()
    .theme(ThemeProvider())
}
```

---

## Good / Bad パターン

### カラー

```swift
// ✅ Good: セマンティックカラー
.foregroundStyle(colors.onSurface)
.background(colors.surface)

// ❌ Bad: ハードコード
.foregroundColor(.black)
.background(Color.white)
```

### スペーシング

```swift
// ✅ Good: トークン使用
VStack(spacing: spacing.md) { ... }
.padding(spacing.lg)

// ❌ Bad: マジックナンバー
VStack(spacing: 12) { ... }
.padding(16)
```

### 角丸

```swift
// ✅ Good: RadiusScale 使用
.clipShape(RoundedRectangle(cornerRadius: radius.lg))

// ❌ Bad: 直値
.clipShape(RoundedRectangle(cornerRadius: 12))
```

### アニメーション

```swift
// ✅ Good: Motion トークン + animate モディファイア
.animate(motion.tap, value: isPressed)

// ❌ Bad: 直接アニメーション指定（reduce motion 無視）
.animation(.easeOut(duration: 0.1), value: isPressed)
```

### コンポーネント活用

```swift
// ✅ Good: 既存コンポーネント使用
Card(elevation: .level2) { content }
Button("保存") { save() }.buttonStyle(.primary)

// ❌ Bad: 独自実装
RoundedRectangle(cornerRadius: 8).fill(Color.white).shadow(radius: 4)
```

### Typography

```swift
// ✅ Good: typography モディファイア
Text("見出し").typography(.headlineLarge)

// ❌ Bad: 直接フォント指定
Text("見出し").font(.system(size: 32, weight: .semibold))
```

---

## 生成後チェックリスト

- [ ] すべてのカラーが `colorPalette` 経由か
- [ ] すべてのスペーシングが `spacingScale` 経由か
- [ ] すべての角丸が `radiusScale` 経由か
- [ ] アニメーションに `motion` トークン + `.animate()` を使用しているか
- [ ] Typography に `.typography()` モディファイアを使用しているか
- [ ] `accessibilityLabel` が設定されているか
- [ ] タップ可能要素は最低 44x44pt か
- [ ] Preview が最低5パターンあるか（Default, Dark, Large Text, Compact, Edge Case）
- [ ] Preview に `.theme(ThemeProvider())` が付いているか
- [ ] `import DesignSystem` があるか

---

## 関連スキル

- **design-system-workflow**: トークン・コンポーネントの詳細リファレンス
- **design-audit**: 生成後の準拠性チェック
- **design-diff**: 視覚的な確認
- **ios-clean-architecture**: アーキテクチャ上の配置
- **ios-build-workflow**: ビルド・テスト実行
