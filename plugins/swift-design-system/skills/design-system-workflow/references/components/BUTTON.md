# Button コンポーネント

デザインシステム統合のボタンスタイル。一貫性のあるサイズ、色、インタラクションを提供。

---

## スタイル

| スタイル | 用途 | 視覚的特徴 |
|---------|------|-----------|
| `.primary` | 主要アクション、CTA | 塗りつぶし、プライマリカラー |
| `.secondary` | 代替アクション | アウトライン、セカンダリカラー |
| `.tertiary` | 控えめなアクション | テキストのみ |

## サイズ

| サイズ | 高さ | 用途 |
|-------|-----|------|
| `.large` | 56pt | 主要アクション、フルワイド |
| `.medium` | 48pt | 標準（デフォルト） |
| `.small` | 40pt | コンパクト、インライン |

---

## 基本使用法

```swift
import DesignSystem

// プライマリボタン
Button("保存する") {
    saveData()
}
.buttonStyle(.primary)
.buttonSize(.large)

// セカンダリボタン
Button("キャンセル") {
    cancel()
}
.buttonStyle(.secondary)
.buttonSize(.medium)

// ターシャリボタン
Button("詳細を見る") {
    showDetails()
}
.buttonStyle(.tertiary)
.buttonSize(.small)
```

---

## アイコン付きボタン

```swift
// 先頭アイコン
Button {
    addItem()
} label: {
    Label("追加", systemImage: "plus")
}
.buttonStyle(.primary)

// 末尾アイコン
Button {
    nextStep()
} label: {
    HStack {
        Text("次へ")
        Image(systemName: "arrow.right")
    }
}
.buttonStyle(.primary)
```

---

## 無効状態

```swift
Button("送信") {
    submit()
}
.buttonStyle(.primary)
.disabled(!isValid)
```

---

## フルワイドボタン

```swift
Button("ログイン") {
    login()
}
.buttonStyle(.primary)
.buttonSize(.large)
.frame(maxWidth: .infinity)
```

---

## ボタングループ

```swift
@Environment(\.spacingScale) var spacing

VStack(spacing: spacing.md) {
    Button("メインアクション") { }
        .buttonStyle(.primary)
        .buttonSize(.large)
        .frame(maxWidth: .infinity)

    Button("キャンセル") { }
        .buttonStyle(.secondary)
        .buttonSize(.large)
        .frame(maxWidth: .infinity)
}

// 横並び
HStack(spacing: spacing.md) {
    Button("キャンセル") { }
        .buttonStyle(.secondary)
        .buttonSize(.medium)

    Button("保存") { }
        .buttonStyle(.primary)
        .buttonSize(.medium)
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: デザインシステムのスタイルを使用
Button("保存") { }
    .buttonStyle(.primary)
    .buttonSize(.large)

// ❌ Bad: 独自スタイル
Button("保存") { }
    .padding()
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(8)
```
