# ColorPicker コンポーネント

プリセットカラーから選択するピッカー。ViewModifier形式で提供。

---

## 特徴

- プリセットカラーシステム（ColorPreset）
- カテゴリ分類
- 検索機能
- ハーフモーダルシート表示

---

## プリセット

| プリセット | 説明 |
|-----------|------|
| `.tagFriendly` | タグ用に最適化された10色 |
| `.allPrimitives` | 全プリミティブカラー |

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedColor: Color = .blue

Button {
    // ピッカーが表示される
} label: {
    Circle()
        .fill(selectedColor)
        .frame(width: 32, height: 32)
}
.colorPicker($selectedColor)
```

---

## タグカラー選択

```swift
@Environment(\.spacingScale) var spacing

@State private var tagColor: Color = .blue
@State private var tagName = ""

HStack(spacing: spacing.md) {
    // カラーインジケーター
    Circle()
        .fill(tagColor)
        .frame(width: 24, height: 24)
        .colorPicker($tagColor, preset: .tagFriendly)

    // タグ名入力
    TextField("タグ名", text: $tagName)
}
```

---

## カテゴリ編集での使用

```swift
struct Category: Identifiable {
    let id = UUID()
    var color: Color
    var icon: String
    var name: String
}

@State private var category = Category(
    color: .blue,
    icon: "folder.fill",
    name: "一般"
)

HStack(spacing: spacing.md) {
    // カラー付きアイコン
    Button {
        // カラーピッカー表示
    } label: {
        Image(systemName: category.icon)
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(category.color)
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
    }
    .colorPicker($category.color, preset: .tagFriendly)

    TextField("カテゴリ名", text: $category.name)
}
```

---

## リスト項目での使用

```swift
struct Tag: Identifiable {
    let id = UUID()
    var color: Color
    var name: String
}

@State private var tags: [Tag] = [
    Tag(color: .red, name: "重要"),
    Tag(color: .blue, name: "仕事"),
    Tag(color: .green, name: "プライベート")
]

List {
    ForEach($tags) { $tag in
        HStack {
            Circle()
                .fill(tag.color)
                .frame(width: 20, height: 20)
                .colorPicker($tag.color, preset: .tagFriendly)

            TextField("タグ名", text: $tag.name)
        }
    }
}
```

---

## プレビュー付き選択

```swift
@State private var themeColor: Color = .blue

VStack(spacing: spacing.lg) {
    // プレビューカード
    Card(elevation: .level2) {
        VStack(spacing: spacing.md) {
            Circle()
                .fill(themeColor)
                .frame(width: 60, height: 60)

            Text("テーマカラー")
                .typography(.titleMedium)
        }
        .padding(spacing.lg)
    }

    // 選択ボタン
    Button("カラーを変更") { }
        .buttonStyle(.secondary)
        .colorPicker($themeColor)
}
```

---

## タグフリープリセットのカラー

`.tagFriendly`プリセットには以下の10色が含まれます：
- 赤系
- オレンジ系
- 黄色系
- 緑系
- 青緑系
- 青系
- 紫系
- ピンク系
- グレー系
- ブラウン系

視認性とアクセシビリティを考慮して選定されています。

---

## Good / Bad パターン

```swift
// ✅ Good: colorPickerモディファイアを使用
Circle()
    .fill(selectedColor)
    .colorPicker($selectedColor, preset: .tagFriendly)

// ❌ Bad: システムのColorPickerを使用（デザイン不統一）
ColorPicker("色", selection: $selectedColor)
```
