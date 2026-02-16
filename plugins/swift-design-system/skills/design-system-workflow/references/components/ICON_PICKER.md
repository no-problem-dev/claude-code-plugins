# IconPicker コンポーネント

SF Symbols からアイコンを選択するピッカー。View Extension 形式で提供。

---

## 特徴

- SF Symbols のカテゴリ分類表示
- 検索・フィルタリング機能
- ハーフモーダルシート表示（.medium, .large detents）
- 選択時の視覚的フィードバック
- 選択クリア機能

---

## API

```swift
// View Extension
func iconPicker(
    categories: [any IconCategoryProtocol],
    selectedIcon: Binding<String?>,
    isPresented: Binding<Bool>
) -> some View
```

### モデル

```swift
struct IconCategory: IconCategoryProtocol {
    let id: String
    let displayName: String
    let icons: [IconItem]
}

struct IconItem: Identifiable {
    let id: String
    let systemName: String   // SF Symbols 名
    let displayName: String? // 表示名（検索用）
}
```

---

## パラメータ

| パラメータ | 型 | 説明 |
|-----------|-----|------|
| `categories` | `[any IconCategoryProtocol]` | アイコンカテゴリの配列 |
| `selectedIcon` | `Binding<String?>` | 選択中のアイコン名（nil で未選択） |
| `isPresented` | `Binding<Bool>` | シート表示状態 |

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedIcon: String? = nil
@State private var showPicker = false

let categories: [IconCategory] = [
    IconCategory(id: "general", displayName: "一般", icons: [
        IconItem(id: "star", systemName: "star.fill", displayName: "スター"),
        IconItem(id: "heart", systemName: "heart.fill", displayName: "ハート"),
        IconItem(id: "folder", systemName: "folder.fill", displayName: "フォルダ"),
    ]),
    IconCategory(id: "media", displayName: "メディア", icons: [
        IconItem(id: "photo", systemName: "photo", displayName: "写真"),
        IconItem(id: "camera", systemName: "camera.fill", displayName: "カメラ"),
    ]),
]

Button {
    showPicker = true
} label: {
    if let icon = selectedIcon {
        Image(systemName: icon)
        Text(icon)
    } else {
        Text("アイコンを選択")
    }
}
.iconPicker(
    categories: categories,
    selectedIcon: $selectedIcon,
    isPresented: $showPicker
)
```

---

## 応用パターン

### プレビュー付き選択

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing

@State private var selectedIcon: String? = "star.fill"
@State private var showPicker = false

VStack(spacing: spacing.lg) {
    // プレビュー
    if let icon = selectedIcon {
        Image(systemName: icon)
            .font(.system(size: 60))
            .foregroundColor(colors.primary)
    } else {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 60))
            .foregroundColor(colors.onSurfaceVariant)
    }

    // 選択ボタン
    Button("アイコンを変更") {
        showPicker = true
    }
    .buttonStyle(.secondary)
    .iconPicker(
        categories: categories,
        selectedIcon: $selectedIcon,
        isPresented: $showPicker
    )
}
```

### カテゴリ編集での使用

```swift
struct CategoryItem: Identifiable {
    let id = UUID()
    var icon: String?
    var name: String
}

@State private var category = CategoryItem(icon: "folder.fill", name: "一般")
@State private var showIconPicker = false

HStack(spacing: spacing.md) {
    // アイコン表示（タップで変更）
    Button {
        showIconPicker = true
    } label: {
        Image(systemName: category.icon ?? "questionmark")
            .font(.title)
            .foregroundColor(colors.primary)
            .frame(width: 44, height: 44)
            .background(colors.primaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
    }
    .iconPicker(
        categories: categories,
        selectedIcon: $category.icon,
        isPresented: $showIconPicker
    )

    // カテゴリ名
    TextField("カテゴリ名", text: $category.name)
}
```

### 選択クリア対応

```swift
@State private var selectedIcon: String? = "star.fill"
@State private var showPicker = false

VStack {
    Button {
        showPicker = true
    } label: {
        if let icon = selectedIcon {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(colors.primary)
        } else {
            Circle()
                .fill(colors.surfaceVariant)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "plus")
                        .foregroundColor(colors.onSurfaceVariant)
                )
        }
    }
    .iconPicker(
        categories: categories,
        selectedIcon: $selectedIcon,
        isPresented: $showPicker
    )

    // 選択をクリアするボタン
    if selectedIcon != nil {
        Button("クリア") {
            selectedIcon = nil
        }
        .typography(.labelSmall)
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: iconPicker View Extension を使用し、isPresented で制御
@State private var selectedIcon: String? = nil
@State private var showPicker = false

Button("選択") { showPicker = true }
    .iconPicker(
        categories: categories,
        selectedIcon: $selectedIcon,
        isPresented: $showPicker
    )

// ✅ Good: selectedIcon は String?（Optional）を使用
@State private var selectedIcon: String? = nil

// ❌ Bad: 独自のピッカー実装
.sheet(isPresented: $showPicker) {
    // 手動で SF Symbols リストを実装
}

// ❌ Bad: 非 Optional の String を使用
@State private var selectedIcon: String = ""

// ❌ Bad: isPresented を省略して直接バインディングだけ渡す
.iconPicker($selectedIcon)
```
