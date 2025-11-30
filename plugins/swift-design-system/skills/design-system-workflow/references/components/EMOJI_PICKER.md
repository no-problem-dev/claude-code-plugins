# EmojiPicker コンポーネント

絵文字を選択するピッカー。ViewModifier形式で提供。

---

## 特徴

- カテゴリ分類（Smileys, Animals, Food, Activities等）
- 大きな32pt表示
- 検索・フィルタリング機能
- ハーフモーダルシート表示

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedEmoji = ""

Button {
    // ピッカーが表示される
} label: {
    if selectedEmoji.isEmpty {
        Text("絵文字を選択")
    } else {
        Text(selectedEmoji)
            .font(.system(size: 32))
    }
}
.emojiPicker($selectedEmoji)
```

---

## タグ・カテゴリでの使用

```swift
struct Category: Identifiable {
    let id = UUID()
    var emoji: String
    var name: String
}

@State private var category = Category(emoji: "📁", name: "一般")

@Environment(\.spacingScale) var spacing

HStack(spacing: spacing.md) {
    // 絵文字表示（タップで変更）
    Button {
        // ピッカー表示
    } label: {
        Text(category.emoji)
            .font(.title)
    }
    .emojiPicker($category.emoji)

    // カテゴリ名入力
    TextField("カテゴリ名", text: $category.name)
}
```

---

## リスト項目での使用

```swift
struct Folder: Identifiable {
    let id = UUID()
    var emoji: String
    var name: String
}

@State private var folders: [Folder] = [
    Folder(emoji: "📁", name: "ドキュメント"),
    Folder(emoji: "📷", name: "写真"),
    Folder(emoji: "🎵", name: "音楽")
]

List {
    ForEach($folders) { $folder in
        HStack {
            Text(folder.emoji)
                .font(.title2)
                .emojiPicker($folder.emoji)

            TextField("フォルダ名", text: $folder.name)
        }
    }
}
```

---

## プレビュー付き選択

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing

@State private var emoji = "⭐️"

VStack(spacing: spacing.lg) {
    // 大きなプレビュー
    Text(emoji)
        .font(.system(size: 80))

    // 選択ボタン
    Button("絵文字を変更") { }
        .buttonStyle(.secondary)
        .emojiPicker($emoji)
}
```

---

## カード作成フォーム

```swift
@State private var cardEmoji = "📝"
@State private var cardTitle = ""
@State private var cardDescription = ""

Card(elevation: .level2) {
    VStack(spacing: spacing.lg) {
        // 絵文字選択
        Button {
            // ピッカー表示
        } label: {
            Text(cardEmoji)
                .font(.system(size: 48))
                .frame(width: 80, height: 80)
                .background(colors.surfaceVariant)
                .clipShape(RoundedRectangle(cornerRadius: radius.lg))
        }
        .emojiPicker($cardEmoji)

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

---

## 初期値なしの場合

```swift
@State private var emoji: String = ""

Button {
    // ピッカー表示
} label: {
    if emoji.isEmpty {
        Image(systemName: "face.smiling")
            .font(.title)
            .foregroundColor(colors.onSurfaceVariant)
            .frame(width: 44, height: 44)
            .background(colors.surfaceVariant)
            .clipShape(Circle())
    } else {
        Text(emoji)
            .font(.title)
    }
}
.emojiPicker($emoji)
```

---

## Good / Bad パターン

```swift
// ✅ Good: emojiPickerモディファイアを使用
Text(selectedEmoji)
    .emojiPicker($selectedEmoji)

// ❌ Bad: 独自のピッカー実装
.sheet(isPresented: $showPicker) {
    // 手動で絵文字リストを実装
}
```
