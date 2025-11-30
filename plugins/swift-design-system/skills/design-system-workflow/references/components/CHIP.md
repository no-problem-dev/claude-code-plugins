# Chip コンポーネント

Material Design 3準拠のチップ。フィルター、タグ、選択肢の表示に使用。

---

## タイプ

| タイプ | 説明 | 使用シーン |
|-------|------|-----------|
| テキストのみ | シンプルなラベル | ステータス表示 |
| アイコン付き | 先頭にアイコン | カテゴリ、タグ |
| 削除可能 | 削除ボタン付き | 入力チップ、フィルター |
| 選択可能 | 選択状態を持つ | フィルター、マルチ選択 |

## スタイル

| スタイル | 視覚的特徴 |
|---------|-----------|
| `.filled` | 塗りつぶし背景 |
| `.outlined` | アウトライン |
| `.liquidGlass` | 半透明ガラス効果 |

## サイズ

| サイズ | 高さ |
|-------|-----|
| `.small` | 24pt |
| `.medium` | 32pt（デフォルト） |

---

## 基本使用法

```swift
import DesignSystem

// テキストのみ
Chip("Active")
    .chipStyle(.filled)

// アイコン付き
Chip("Swift", systemImage: "swift")
    .chipStyle(.outlined)

// カスタムサイズ
Chip("Small")
    .chipStyle(.filled)
    .chipSize(.small)
```

---

## 削除可能チップ（Input Chip）

```swift
@State private var tags = ["Swift", "iOS", "SwiftUI"]

HStack {
    ForEach(tags, id: \.self) { tag in
        Chip(tag, systemImage: "tag.fill") {
            // 削除アクション
            tags.removeAll { $0 == tag }
        }
        .chipStyle(.outlined)
    }
}
```

---

## 選択可能チップ（Filter Chip）

```swift
@State private var isSelected = false

Chip("フィルター", isSelected: $isSelected)
    .chipStyle(.outlined)
```

---

## 複数選択フィルター

```swift
struct FilterOption: Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool
}

@State private var filters = [
    FilterOption(name: "新着", isSelected: false),
    FilterOption(name: "人気", isSelected: true),
    FilterOption(name: "セール", isSelected: false)
]

@Environment(\.spacingScale) var spacing

HStack(spacing: spacing.sm) {
    ForEach($filters) { $filter in
        Chip(filter.name, isSelected: $filter.isSelected)
            .chipStyle(.outlined)
    }
}
```

---

## 横スクロールフィルター

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: spacing.sm) {
        ForEach($filters) { $filter in
            Chip(filter.name, isSelected: $filter.isSelected)
                .chipStyle(.outlined)
        }
    }
    .padding(.horizontal, spacing.lg)
}
```

---

## スタイルバリエーション

```swift
VStack(spacing: spacing.md) {
    // Filled
    HStack {
        Chip("Filled").chipStyle(.filled)
        Chip("Selected", isSelected: .constant(true)).chipStyle(.filled)
    }

    // Outlined
    HStack {
        Chip("Outlined").chipStyle(.outlined)
        Chip("Selected", isSelected: .constant(true)).chipStyle(.outlined)
    }

    // Liquid Glass
    HStack {
        Chip("Glass").chipStyle(.liquidGlass)
        Chip("Selected", isSelected: .constant(true)).chipStyle(.liquidGlass)
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: Chipコンポーネントを使用
Chip("タグ", systemImage: "tag")
    .chipStyle(.outlined)

// ❌ Bad: 独自実装
HStack {
    Image(systemName: "tag")
    Text("タグ")
}
.padding(.horizontal, 12)
.padding(.vertical, 6)
.background(Capsule().stroke())
```
