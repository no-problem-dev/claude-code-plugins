# EmojiPicker コンポーネント

絵文字を選択するピッカー。View Extension 形式で提供。

---

## 特徴

- カテゴリ分類表示
- 大きな 32pt 表示
- 検索・フィルタリング機能
- ハーフモーダルシート表示（.medium, .large detents）
- 選択クリア機能

---

## API

```swift
// View Extension
func emojiPicker(
    categories: [any EmojiCategoryProtocol],
    selectedEmoji: Binding<String?>,
    isPresented: Binding<Bool>
) -> some View
```

### モデル

```swift
struct EmojiCategory: EmojiCategoryProtocol {
    let id: String
    let displayName: String
    let emojis: [EmojiItem]
}

struct EmojiItem: Identifiable {
    let id: String
    let emoji: String        // 絵文字文字列
    let displayName: String? // 表示名（検索用）
}
```

---

## パラメータ

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| `categories` | `[any EmojiCategoryProtocol]` | 絵文字カテゴリの配列 |
| `selectedEmoji` | `Binding<String?>` | 選択中の絵文字（nil で未選択） |
| `isPresented` | `Binding<Bool>` | シート表示状態 |

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedEmoji: String? = nil
@State private var showPicker = false

let categories: [EmojiCategory] = [
    EmojiCategory(id: "smileys", displayName: "スマイリー", emojis: [
        EmojiItem(id: "smile", emoji: "😊", displayName: "にっこり"),
        EmojiItem(id: "laugh", emoji: "😂", displayName: "大笑い"),
        EmojiItem(id: "heart_eyes", emoji: "😍", displayName: "ハート目"),
    ]),
    EmojiCategory(id: "animals", displayName: "動物", emojis: [
        EmojiItem(id: "dog", emoji: "🐶", displayName: "犬"),
        EmojiItem(id: "cat", emoji: "🐱", displayName: "猫"),
    ]),
]

Button {
    showPicker = true
} label: {
    if let emoji = selectedEmoji {
        Text(emoji)
            .font(.system(size: 32))
    } else {
        Text("絵文字を選択")
    }
}
.emojiPicker(
    categories: categories,
    selectedEmoji: $selectedEmoji,
    isPresented: $showPicker
)
```

---

## 応用パターン

### タグ・カテゴリでの使用

```swift
struct CategoryItem: Identifiable {
    let id = UUID()
    var emoji: String?
    var name: String
}

@Environment(\.spacingScale) var spacing

@State private var category = CategoryItem(emoji: "📁", name: "一般")
@State private var showEmojiPicker = false

HStack(spacing: spacing.md) {
    // 絵文字表示（タップで変更）
    Button {
        showEmojiPicker = true
    } label: {
        Text(category.emoji ?? "❓")
            .font(.title)
    }
    .emojiPicker(
        categories: categories,
        selectedEmoji: $category.emoji,
        isPresented: $showEmojiPicker
    )

    // カテゴリ名入力
    TextField("カテゴリ名", text: $category.name)
}
```

### プレビュー付き選択

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing

@State private var selectedEmoji: String? = "⭐️"
@State private var showPicker = false

VStack(spacing: spacing.lg) {
    // 大きなプレビュー
    Text(selectedEmoji ?? "?")
        .font(.system(size: 80))

    // 選択ボタン
    Button("絵文字を変更") {
        showPicker = true
    }
    .buttonStyle(.secondary)
    .emojiPicker(
        categories: categories,
        selectedEmoji: $selectedEmoji,
        isPresented: $showPicker
    )
}
```

### カード作成フォーム

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing
@Environment(\.radiusScale) var radius

@State private var cardEmoji: String? = "📝"
@State private var cardTitle = ""
@State private var cardDescription = ""
@State private var showPicker = false

Card(elevation: .level2) {
    VStack(spacing: spacing.lg) {
        // 絵文字選択
        Button {
            showPicker = true
        } label: {
            Text(cardEmoji ?? "➕")
                .font(.system(size: 48))
                .frame(width: 80, height: 80)
                .background(colors.surfaceVariant)
                .clipShape(RoundedRectangle(cornerRadius: radius.lg))
        }
        .emojiPicker(
            categories: categories,
            selectedEmoji: $cardEmoji,
            isPresented: $showPicker
        )

        // タイトル
        TextField("タイトル", text: $cardTitle)
            .typography(.titleMedium)

        // 説明
        TextField("説明", text: $cardDescription)
            .typography(.bodyMedium)
    }
    .padding(spacing.lg)
}
```

### 初期値なしの場合

```swift
@State private var emoji: String? = nil
@State private var showPicker = false

Button {
    showPicker = true
} label: {
    if let emoji {
        Text(emoji)
            .font(.title)
    } else {
        Image(systemName: "face.smiling")
            .font(.title)
            .foregroundColor(colors.onSurfaceVariant)
            .frame(width: 44, height: 44)
            .background(colors.surfaceVariant)
            .clipShape(Circle())
    }
}
.emojiPicker(
    categories: categories,
    selectedEmoji: $emoji,
    isPresented: $showPicker
)
```

---

## Good / Bad パターン

```swift
// ✅ Good: emojiPicker View Extension を使用し、isPresented で制御
@State private var selectedEmoji: String? = nil
@State private var showPicker = false

Button("選択") { showPicker = true }
    .emojiPicker(
        categories: categories,
        selectedEmoji: $selectedEmoji,
        isPresented: $showPicker
    )

// ✅ Good: selectedEmoji は String?（Optional）を使用
@State private var selectedEmoji: String? = nil

// ❌ Bad: 独自のピッカー実装
.sheet(isPresented: $showPicker) {
    // 手動で絵文字リストを実装
}

// ❌ Bad: 非 Optional の String を使用
@State private var selectedEmoji: String = ""

// ❌ Bad: isPresented を省略して直接バインディングだけ渡す
.emojiPicker($selectedEmoji)
```
