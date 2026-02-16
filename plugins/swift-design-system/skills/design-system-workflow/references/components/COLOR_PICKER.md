# ColorPicker コンポーネント

プリセットカラーから色を選択するピッカー。View Extension 形式で提供。

---

## 特徴

- プリセットカラーシステム（ColorPreset）
- 選択値は Hex 文字列（`String?`）で返却
- ハーフモーダルシート表示
- 選択クリア機能

---

## API

```swift
// View Extension
func colorPicker(
    preset: ColorPreset = .tagFriendly,
    selectedColor: Binding<String?>,   // Hex 文字列（例: "#FF0000"）
    isPresented: Binding<Bool>
) -> some View
```

### プリセット

```swift
enum ColorPreset {
    case tagFriendly    // タグ用に最適化された10色
    case allPrimitives  // 全プリミティブカラー
}
```

---

## パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|-----------|------|
| `preset` | `ColorPreset` | `.tagFriendly` | カラープリセット |
| `selectedColor` | `Binding<String?>` | - | 選択中の Hex 文字列（nil で未選択） |
| `isPresented` | `Binding<Bool>` | - | シート表示状態 |

### 重要

- **選択値は `String?`（Hex 文字列）であって `Color` ではない**
- 表示に使う場合は `Color(hex:)` で変換する
- 例: `"#FF0000"` → `Color(hex: "#FF0000")`

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedColor: String? = nil
@State private var showPicker = false

Button {
    showPicker = true
} label: {
    Circle()
        .fill(selectedColor.map { Color(hex: $0) } ?? Color.gray)
        .frame(width: 32, height: 32)
}
.colorPicker(
    selectedColor: $selectedColor,
    isPresented: $showPicker
)
```

---

## 応用パターン

### タグカラー選択

```swift
@Environment(\.spacingScale) var spacing

@State private var tagColor: String? = nil
@State private var tagName = ""
@State private var showColorPicker = false

HStack(spacing: spacing.md) {
    // カラーインジケーター
    Button {
        showColorPicker = true
    } label: {
        Circle()
            .fill(tagColor.map { Color(hex: $0) } ?? Color.gray)
            .frame(width: 24, height: 24)
    }
    .colorPicker(
        preset: .tagFriendly,
        selectedColor: $tagColor,
        isPresented: $showColorPicker
    )

    // タグ名入力
    TextField("タグ名", text: $tagName)
}
```

### カテゴリ編集での使用

```swift
struct CategoryItem: Identifiable {
    let id = UUID()
    var colorHex: String?
    var icon: String
    var name: String
}

@State private var category = CategoryItem(
    colorHex: "#4285F4",
    icon: "folder.fill",
    name: "一般"
)
@State private var showColorPicker = false

HStack(spacing: spacing.md) {
    // カラー付きアイコン
    Button {
        showColorPicker = true
    } label: {
        Image(systemName: category.icon)
            .font(.title2)
            .foregroundColor(.white)
            .frame(width: 44, height: 44)
            .background(category.colorHex.map { Color(hex: $0) } ?? colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
    }
    .colorPicker(
        preset: .tagFriendly,
        selectedColor: $category.colorHex,
        isPresented: $showColorPicker
    )

    TextField("カテゴリ名", text: $category.name)
}
```

### 全プリミティブカラーの使用

```swift
@State private var themeColor: String? = nil
@State private var showPicker = false

VStack(spacing: spacing.lg) {
    // プレビューカード
    Card(elevation: .level2) {
        VStack(spacing: spacing.md) {
            Circle()
                .fill(themeColor.map { Color(hex: $0) } ?? colors.primary)
                .frame(width: 60, height: 60)

            Text("テーマカラー")
                .typography(.titleMedium)
        }
        .padding(spacing.lg)
    }

    // 選択ボタン（全カラー表示）
    Button("カラーを変更") {
        showPicker = true
    }
    .buttonStyle(.secondary)
    .colorPicker(
        preset: .allPrimitives,
        selectedColor: $themeColor,
        isPresented: $showPicker
    )
}
```

### リスト項目での使用

```swift
struct Tag: Identifiable {
    let id = UUID()
    var colorHex: String?
    var name: String
}

@State private var tags: [Tag] = [
    Tag(colorHex: "#F44336", name: "重要"),
    Tag(colorHex: "#4285F4", name: "仕事"),
    Tag(colorHex: "#4CAF50", name: "プライベート"),
]
@State private var editingTagId: UUID? = nil

List {
    ForEach($tags) { $tag in
        HStack {
            Button {
                editingTagId = tag.id
            } label: {
                Circle()
                    .fill(tag.colorHex.map { Color(hex: $0) } ?? Color.gray)
                    .frame(width: 20, height: 20)
            }
            .colorPicker(
                preset: .tagFriendly,
                selectedColor: $tag.colorHex,
                isPresented: Binding(
                    get: { editingTagId == tag.id },
                    set: { if !$0 { editingTagId = nil } }
                )
            )

            TextField("タグ名", text: $tag.name)
        }
    }
}
```

---

## tagFriendly プリセットのカラー

`.tagFriendly` プリセットには以下の 10 色が含まれます:
- 赤系、オレンジ系、黄色系、緑系、青緑系
- 青系、紫系、ピンク系、グレー系、ブラウン系

視認性とアクセシビリティを考慮して選定されています。

---

## Good / Bad パターン

```swift
// ✅ Good: colorPicker View Extension を使用し、isPresented で制御
@State private var selectedColor: String? = nil
@State private var showPicker = false

Button("選択") { showPicker = true }
    .colorPicker(
        preset: .tagFriendly,
        selectedColor: $selectedColor,
        isPresented: $showPicker
    )

// ✅ Good: selectedColor は String?（Hex 文字列）を使用
@State private var selectedColor: String? = nil

// ✅ Good: Color(hex:) で表示用に変換
Circle().fill(selectedColor.map { Color(hex: $0) } ?? Color.gray)

// ❌ Bad: selectedColor に Color 型を使用
@State private var selectedColor: Color = .blue

// ❌ Bad: システムの ColorPicker を使用（デザイン不統一）
ColorPicker("色", selection: $selectedColor)

// ❌ Bad: isPresented を省略して直接バインディングだけ渡す
.colorPicker($selectedColor)
```
