# IconBadge コンポーネント

アイコンを円形の背景で囲んだバッジ。ステータスインジケーター、カテゴリアイコン、リストアイテムの装飾に使用。

---

## 特徴

- SF Symbols を円形背景で強調表示
- デフォルトで `primary` 色のアイコン + `primary.opacity(0.15)` の背景
- 3つのサイズバリエーション
- 色のカスタマイズ可能

## サイズ

| サイズ | 用途 |
|-------|------|
| `.small` | インライン、リスト項目 |
| `.medium` | 標準（デフォルト） |
| `.large` | 強調表示、ヘッダー |

---

## 基本使用法

```swift
import DesignSystem

// デフォルトスタイル
IconBadge(systemName: "star.fill")

// サイズ指定
IconBadge(systemName: "bell.fill", size: .large)

// 小サイズ
IconBadge(systemName: "checkmark", size: .small)
```

---

## カラーカスタマイズ

```swift
@Environment(\.colorPalette) var colors

// カスタムカラー
IconBadge(
    systemName: "heart.fill",
    foregroundColor: colors.error,
    backgroundColor: colors.errorContainer
)

// 成功状態
IconBadge(
    systemName: "checkmark.circle.fill",
    foregroundColor: colors.tertiary,
    backgroundColor: colors.tertiaryContainer
)

// 警告状態
IconBadge(
    systemName: "exclamationmark.triangle.fill",
    foregroundColor: .orange,
    backgroundColor: .orange.opacity(0.15)
)
```

---

## リストアイテムの装飾

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let iconBackground: Color

    var body: some View {
        HStack(spacing: spacing.md) {
            IconBadge(
                systemName: icon,
                size: .medium,
                foregroundColor: iconColor,
                backgroundColor: iconBackground
            )

            Text(title)
                .typography(.bodyLarge)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(colors.onSurfaceVariant)
        }
        .padding(.vertical, spacing.sm)
    }
}

// 使用例
List {
    SettingsRow(
        icon: "person.fill",
        title: "アカウント",
        iconColor: colors.primary,
        iconBackground: colors.primaryContainer
    )
    SettingsRow(
        icon: "bell.fill",
        title: "通知",
        iconColor: colors.error,
        iconBackground: colors.errorContainer
    )
    SettingsRow(
        icon: "lock.fill",
        title: "プライバシー",
        iconColor: colors.tertiary,
        iconBackground: colors.tertiaryContainer
    )
}
```

---

## カテゴリ表示

```swift
@Environment(\.spacingScale) var spacing

struct CategoryItem: View {
    let icon: String
    let name: String

    var body: some View {
        VStack(spacing: spacing.sm) {
            IconBadge(systemName: icon, size: .large)

            Text(name)
                .typography(.labelMedium)
        }
    }
}

// グリッド配置
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: spacing.lg) {
    CategoryItem(icon: "fork.knife", name: "食事")
    CategoryItem(icon: "figure.run", name: "運動")
    CategoryItem(icon: "bed.double.fill", name: "睡眠")
    CategoryItem(icon: "heart.fill", name: "健康")
}
```

---

## ステータスインジケーター

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

HStack(spacing: spacing.md) {
    IconBadge(
        systemName: "checkmark",
        size: .small,
        foregroundColor: colors.tertiary,
        backgroundColor: colors.tertiaryContainer
    )

    VStack(alignment: .leading, spacing: spacing.xxs) {
        Text("バックアップ完了")
            .typography(.bodyMedium)
        Text("最終更新: 5分前")
            .typography(.bodySmall)
            .foregroundStyle(colors.onSurfaceVariant)
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: IconBadge コンポーネントを使用
IconBadge(
    systemName: "star.fill",
    size: .medium,
    foregroundColor: colors.primary,
    backgroundColor: colors.primaryContainer
)

// ❌ Bad: 独自実装
Image(systemName: "star.fill")
    .font(.system(size: 20))
    .foregroundColor(.blue)
    .frame(width: 40, height: 40)
    .background(Circle().fill(Color.blue.opacity(0.15)))

// ✅ Good: セマンティックカラーを使用
IconBadge(
    systemName: "xmark",
    foregroundColor: colors.error,
    backgroundColor: colors.errorContainer
)

// ❌ Bad: ハードコードされた色
IconBadge(
    systemName: "xmark",
    foregroundColor: .red,
    backgroundColor: Color(red: 1, green: 0, blue: 0, opacity: 0.15)
)
```
