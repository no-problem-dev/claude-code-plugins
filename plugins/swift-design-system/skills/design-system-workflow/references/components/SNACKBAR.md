# Snackbar コンポーネント

一時的な通知メッセージを表示。Material Design 3準拠。

---

## 特徴

- `SnackbarState`による状態管理
- 自動非表示（デフォルト5秒）
- 最大2つのアクションボタン
- スプリングアニメーション

---

## 基本使用法

```swift
import DesignSystem

struct ContentView: View {
    @State private var snackbarState = SnackbarState()

    var body: some View {
        ZStack {
            // メインコンテンツ
            VStack {
                Button("通知を表示") {
                    snackbarState.show("操作が完了しました")
                }
            }

            // Snackbar（最前面に配置）
            Snackbar(state: snackbarState)
        }
    }
}
```

---

## アクション付きSnackbar

```swift
snackbarState.show(
    "ファイルを削除しました",
    action: SnackbarAction(title: "元に戻す") {
        undoDelete()
    }
)
```

---

## 複数アクション

```swift
snackbarState.show(
    "変更を保存しますか？",
    action: SnackbarAction(title: "保存") {
        save()
    },
    secondaryAction: SnackbarAction(title: "破棄") {
        discard()
    }
)
```

---

## 表示時間のカスタマイズ

```swift
// 長めの表示（8秒）
snackbarState.show(
    "重要なメッセージ",
    duration: 8.0
)

// 短い表示（3秒）
snackbarState.show(
    "保存しました",
    duration: 3.0
)
```

---

## 手動で閉じる

```swift
snackbarState.dismiss()
```

---

## 状態の確認

```swift
if snackbarState.isVisible {
    // Snackbarが表示中
}
```

---

## 使用パターン：操作完了通知

```swift
func saveData() async {
    do {
        try await repository.save(data)
        snackbarState.show("保存しました")
    } catch {
        snackbarState.show(
            "保存に失敗しました",
            action: SnackbarAction(title: "再試行") {
                Task { await saveData() }
            }
        )
    }
}
```

---

## 使用パターン：削除の取り消し

```swift
func deleteItem(_ item: Item) {
    let deletedItem = item
    items.removeAll { $0.id == item.id }

    snackbarState.show(
        "\(item.name)を削除しました",
        action: SnackbarAction(title: "元に戻す") {
            items.append(deletedItem)
        }
    )
}
```

---

## 配置のベストプラクティス

```swift
struct RootView: View {
    @State private var snackbarState = SnackbarState()

    var body: some View {
        ZStack {
            NavigationStack {
                ContentView()
            }
            .environment(\.snackbarState, snackbarState)

            // 常に最前面に
            Snackbar(state: snackbarState)
        }
    }
}

// 子Viewからの使用
struct ChildView: View {
    @Environment(\.snackbarState) var snackbar

    var body: some View {
        Button("通知") {
            snackbar.show("メッセージ")
        }
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: Snackbarコンポーネントを使用
@State private var snackbarState = SnackbarState()

snackbarState.show("保存しました")
Snackbar(state: snackbarState)

// ❌ Bad: アラートで代用
.alert("保存しました", isPresented: $showAlert) {
    Button("OK") { }
}
```
