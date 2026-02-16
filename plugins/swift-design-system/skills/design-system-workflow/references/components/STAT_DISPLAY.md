# StatDisplay コンポーネント

数値データを大きく目立たせて表示。ダッシュボード、統計画面、プロフィール画面などで使用。

---

## 特徴

- `.rounded` フォントデザインで視認性の高い数値表示
- 太字の value + セミボールドの unit でベースライン揃え
- 4つのサイズバリエーション
- 配置方向（左寄せ/中央/右寄せ）のカスタマイズ

## サイズ

| サイズ | 値フォント | 単位フォント | 用途 |
|-------|-----------|-------------|------|
| `.small` | 24pt | .subheadline | インライン統計 |
| `.medium` | 32pt | .title3 | 標準（デフォルト） |
| `.large` | 48pt | .title2 | ダッシュボードメイン |
| `.extraLarge` | 64pt | .title | ヒーローセクション |

---

## 基本使用法

```swift
import DesignSystem

// 単位なし
StatDisplay(value: "1,234")

// 単位付き
StatDisplay(value: "42.5", unit: "km")

// サイズ指定
StatDisplay(value: "98", unit: "%", size: .large)
```

---

## サイズバリエーション

```swift
@Environment(\.spacingScale) var spacing

VStack(alignment: .leading, spacing: spacing.lg) {
    StatDisplay(value: "128", unit: "BPM", size: .small)
    StatDisplay(value: "128", unit: "BPM", size: .medium)
    StatDisplay(value: "128", unit: "BPM", size: .large)
    StatDisplay(value: "128", unit: "BPM", size: .extraLarge)
}
```

---

## カラーカスタマイズ

```swift
@Environment(\.colorPalette) var colors

// カスタムカラー
StatDisplay(
    value: "98.6",
    unit: "%",
    size: .large,
    valueColor: colors.primary,
    unitColor: colors.onSurfaceVariant
)

// エラー状態の強調
StatDisplay(
    value: "3",
    unit: "エラー",
    size: .medium,
    valueColor: colors.error,
    unitColor: colors.error
)
```

---

## ダッシュボードレイアウト

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

LazyVGrid(columns: [
    GridItem(.flexible()),
    GridItem(.flexible())
], spacing: spacing.lg) {
    VStack(alignment: .leading, spacing: spacing.xs) {
        Text("歩数")
            .typography(.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
        StatDisplay(value: "8,432", unit: "歩", size: .medium)
    }

    VStack(alignment: .leading, spacing: spacing.xs) {
        Text("消費カロリー")
            .typography(.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
        StatDisplay(value: "326", unit: "kcal", size: .medium)
    }

    VStack(alignment: .leading, spacing: spacing.xs) {
        Text("距離")
            .typography(.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
        StatDisplay(value: "5.2", unit: "km", size: .medium)
    }

    VStack(alignment: .leading, spacing: spacing.xs) {
        Text("アクティブ時間")
            .typography(.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
        StatDisplay(value: "47", unit: "分", size: .medium)
    }
}
.padding(spacing.lg)
```

---

## ヒーローセクション

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

VStack(spacing: spacing.sm) {
    StatDisplay(
        value: "99.9",
        unit: "%",
        size: .extraLarge,
        valueColor: colors.primary,
        alignment: .center
    )

    Text("稼働率")
        .typography(.titleMedium)
        .foregroundStyle(colors.onSurfaceVariant)
}
.frame(maxWidth: .infinity)
.padding(spacing.xl)
```

---

## Good / Bad パターン

```swift
// ✅ Good: StatDisplay コンポーネントを使用
StatDisplay(value: "1,234", unit: "件", size: .large)

// ❌ Bad: 独自実装で数値表示
HStack(alignment: .firstTextBaseline) {
    Text("1,234")
        .font(.system(size: 48, weight: .bold, design: .rounded))
    Text("件")
        .font(.title2)
        .fontWeight(.semibold)
}

// ✅ Good: デザインシステムのカラートークンを使用
StatDisplay(
    value: "42",
    unit: "pt",
    valueColor: colors.primary
)

// ❌ Bad: ハードコードされた色
StatDisplay(
    value: "42",
    unit: "pt",
    valueColor: Color(red: 0.0, green: 0.5, blue: 1.0)
)
```
