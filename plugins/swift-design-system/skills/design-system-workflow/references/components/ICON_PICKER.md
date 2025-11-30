# IconPicker コンポーネント

SF Symbolsからアイコンを選択するピッカー。ViewModifier形式で提供。

---

## 特徴

- SF Symbolsのカテゴリ分類
- 検索・フィルタリング機能
- ハーフモーダルシート表示（.medium, .large detents）
- 選択時の視覚的フィードバック

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedIcon = ""

Button {
    // ピッカーが表示される
} label: {
    HStack {
        if selectedIcon.isEmpty {
            Text("アイコンを選択")
        } else {
            Image(systemName: selectedIcon)
            Text(selectedIcon)
        }
    }
}
.iconPicker($selectedIcon)
```

---

## プレビュー付き選択

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing

@State private var icon = "star.fill"

VStack(spacing: spacing.lg) {
    // プレビュー
    Image(systemName: icon)
        .font(.system(size: 60))
        .foregroundColor(colors.primary)

    // 選択ボタン
    Button("アイコンを変更") { }
        .buttonStyle(.secondary)
        .iconPicker($icon)
}
```

---

## カテゴリ編集での使用

```swift
struct Category: Identifiable {
    let id = UUID()
    var icon: String
    var name: String
}

@State private var category = Category(icon: "folder.fill", name: "一般")

HStack(spacing: spacing.md) {
    // アイコン表示（タップで変更）
    Button {
        // ピッカー表示
    } label: {
        Image(systemName: category.icon)
            .font(.title)
            .foregroundColor(colors.primary)
            .frame(width: 44, height: 44)
            .background(colors.primaryContainer)
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
    }
    .iconPicker($category.icon)

    // カテゴリ名
    TextField("カテゴリ名", text: $category.name)
}
```

---

## リスト項目での使用

```swift
struct ListItem: Identifiable {
    let id = UUID()
    var icon: String
    var title: String
}

@State private var items: [ListItem] = [
    ListItem(icon: "house", title: "ホーム"),
    ListItem(icon: "gear", title: "設定")
]

List {
    ForEach($items) { $item in
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(colors.primary)
                .iconPicker($item.icon)

            TextField("タイトル", text: $item.title)
        }
    }
}
```

---

## 初期値なしの場合

```swift
@State private var icon: String = ""

VStack {
    if icon.isEmpty {
        // プレースホルダー
        Circle()
            .fill(colors.surfaceVariant)
            .frame(width: 60, height: 60)
            .overlay(
                Image(systemName: "plus")
                    .foregroundColor(colors.onSurfaceVariant)
            )
            .iconPicker($icon)
    } else {
        // 選択済み
        Image(systemName: icon)
            .font(.system(size: 40))
            .foregroundColor(colors.primary)
            .iconPicker($icon)
    }

    Text(icon.isEmpty ? "アイコンを選択" : icon)
        .typography(.bodySmall)
        .foregroundColor(colors.onSurfaceVariant)
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: iconPickerモディファイアを使用
Button("選択") { }
    .iconPicker($selectedIcon)

// ❌ Bad: 独自のピッカー実装
.sheet(isPresented: $showPicker) {
    // 手動でSF Symbolsリストを実装
}
```
