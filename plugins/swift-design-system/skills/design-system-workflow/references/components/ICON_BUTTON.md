# IconButton コンポーネント

アイコンのみのボタン。ツールバー、ナビゲーション、トグル操作など、テキスト不要のアクションに使用。

---

## スタイル

| スタイル | 視覚的特徴 | 用途 |
|---------|-----------|------|
| `.standard` | 背景なし、アイコンのみ | ツールバー、ナビゲーション |
| `.filled` | Primary 色の背景 | 主要アクション、強調 |
| `.tonal` | SecondaryContainer 色の背景 | 中程度の強調 |
| `.outlined` | アウトラインのみ | フォーム内、設定 |

## サイズ

| サイズ | コンテナ | アイコン | 用途 |
|-------|---------|---------|------|
| `.small` | 32pt | 16pt | コンパクト UI、インライン |
| `.medium` | 40pt | 20pt | 標準（デフォルト） |
| `.large` | 48pt | 24pt | ナビゲーション、強調 |

---

## 基本使用法

```swift
import DesignSystem

// 標準スタイル（デフォルト）
IconButton(icon: "heart", style: .standard, size: .medium) {
    toggleFavorite()
}

// 塗りつぶしスタイル
IconButton(icon: "plus", style: .filled) {
    addItem()
}

// トーナルスタイル
IconButton(icon: "square.and.arrow.up", style: .tonal) {
    shareContent()
}

// アウトラインスタイル
IconButton(icon: "gear", style: .outlined, size: .large) {
    openSettings()
}
```

---

## ツールバーでの使用

```swift
@Environment(\.spacingScale) var spacing

HStack(spacing: spacing.sm) {
    IconButton(icon: "arrow.left", style: .standard) {
        navigateBack()
    }

    Spacer()

    IconButton(icon: "magnifyingglass", style: .standard) {
        openSearch()
    }

    IconButton(icon: "ellipsis", style: .standard) {
        showMenu()
    }
}
.padding(.horizontal, spacing.md)
```

---

## トグルボタン

```swift
@State private var isFavorite = false

IconButton(
    icon: isFavorite ? "heart.fill" : "heart",
    style: isFavorite ? .filled : .standard
) {
    withAnimation {
        isFavorite.toggle()
    }
}
```

---

## カード内アクション

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

HStack(spacing: spacing.sm) {
    IconButton(icon: "hand.thumbsup", style: .tonal, size: .small) {
        likePost()
    }

    IconButton(icon: "bubble.right", style: .standard, size: .small) {
        openComments()
    }

    IconButton(icon: "square.and.arrow.up", style: .standard, size: .small) {
        sharePost()
    }

    Spacer()

    IconButton(icon: "bookmark", style: .standard, size: .small) {
        bookmarkPost()
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: IconButton コンポーネントを使用
IconButton(icon: "trash", style: .standard, size: .medium) {
    deleteItem()
}

// ❌ Bad: 独自実装
Button {
    deleteItem()
} label: {
    Image(systemName: "trash")
        .font(.system(size: 20))
        .frame(width: 40, height: 40)
        .foregroundColor(.primary)
}

// ✅ Good: スタイルで意味を区別
IconButton(icon: "plus", style: .filled) { addItem() }    // 主要アクション
IconButton(icon: "gear", style: .standard) { settings() }  // 補助アクション

// ❌ Bad: ハードコードされた色で区別
Button { } label: {
    Image(systemName: "plus")
        .foregroundColor(.white)
        .background(Color.blue)
}
```
