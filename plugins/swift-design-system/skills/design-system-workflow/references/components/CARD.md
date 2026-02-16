# Card コンポーネント

コンテンツを囲む汎用コンテナ。サーフェスカラー、角丸、エレベーションを自動適用。

---

## パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|---|----------|------|
| `elevation` | `Elevation` | `.level1` | シャドウレベル |
| `content` | `@ViewBuilder` | - | カード内コンテンツ |

---

## エレベーションレベル

| レベル | 用途 |
|-------|------|
| `.level0` | 埋め込み要素、フラット |
| `.level1` | リストアイテム、**標準カード（デフォルト）** |
| `.level2` | 強調されたカード |
| `.level3` | ホバー状態、強調 |
| `.level4` | モーダル、ポップアップ |
| `.level5` | ドロワー、ダイアログ |

---

## 基本使用法

```swift
import DesignSystem

@Environment(\.spacingScale) var spacing

Card {
    VStack(alignment: .leading, spacing: spacing.md) {
        Text("カードタイトル")
            .typography(.titleMedium)

        Text("カードの説明文がここに入ります。")
            .typography(.bodyMedium)
    }
    .padding(spacing.lg)
}
```

---

## エレベーションの指定

```swift
// フラットなカード（埋め込み）
Card(elevation: .level0) {
    content
}

// 標準カード
Card(elevation: .level2) {
    content
}

// 強調されたカード
Card(elevation: .level3) {
    content
}
```

---

## インタラクティブカード

```swift
@Environment(\.motion) var motion
@State private var isHovered = false

Card(elevation: isHovered ? .level3 : .level2) {
    VStack {
        Image("product")
            .resizable()
            .aspectRatio(contentMode: .fill)

        Text("商品名")
            .typography(.titleMedium)
            .padding(spacing.md)
    }
}
.onHover { hovering in
    withAnimation(motion.tap) {
        isHovered = hovering
    }
}
.onTapGesture {
    selectProduct()
}
```

---

## 構造化カード

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing

Card(elevation: .level2) {
    VStack(alignment: .leading, spacing: spacing.md) {
        // ヘッダー
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(colors.primary)

            VStack(alignment: .leading, spacing: spacing.xxs) {
                Text("ユーザー名")
                    .typography(.titleSmall)
                Text("@username")
                    .typography(.bodySmall)
                    .foregroundColor(colors.onSurfaceVariant)
            }

            Spacer()

            Button { } label: {
                Image(systemName: "ellipsis")
            }
        }

        Divider()

        // 本文
        Text("投稿内容がここに表示されます。")
            .typography(.bodyMedium)

        // フッター
        HStack(spacing: spacing.lg) {
            Label("12", systemImage: "heart")
            Label("3", systemImage: "bubble.right")
            Spacer()
            Text("2時間前")
                .typography(.bodySmall)
                .foregroundColor(colors.onSurfaceVariant)
        }
        .typography(.labelMedium)
    }
    .padding(spacing.lg)
}
```

---

## メディア付きカード

```swift
Card(elevation: .level2) {
    VStack(alignment: .leading, spacing: 0) {
        // 画像（パディングなし）
        Image("cover")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
            .clipped()

        // コンテンツ
        VStack(alignment: .leading, spacing: spacing.sm) {
            Text("タイトル")
                .typography(.titleMedium)

            Text("説明文")
                .typography(.bodyMedium)
                .foregroundColor(colors.onSurfaceVariant)
        }
        .padding(spacing.lg)
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: Cardコンポーネントを使用
Card(elevation: .level2) {
    content
        .padding(spacing.lg)
}

// ❌ Bad: 独自実装
RoundedRectangle(cornerRadius: 8)
    .fill(Color.white)
    .shadow(radius: 4)
    .overlay(content)
```
