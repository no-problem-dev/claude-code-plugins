# FloatingActionButton (FAB) コンポーネント

画面上の主要アクションを表す浮遊ボタン。通常は画面右下に配置。

---

## サイズ

| サイズ | 直径 | 用途 |
|-------|-----|------|
| `.small` | 40pt | コンパクトUI |
| `.regular` | 56pt | 標準（デフォルト） |
| `.large` | 96pt | 強調されたアクション |

---

## 基本使用法

```swift
import DesignSystem

FloatingActionButton(icon: "plus") {
    createNewItem()
}

// サイズ指定
FloatingActionButton(icon: "plus", size: .large) {
    createNewItem()
}
```

---

## 画面レイアウトでの配置

```swift
@Environment(\.spacingScale) var spacing

ZStack {
    // メインコンテンツ
    ScrollView {
        LazyVStack {
            ForEach(items) { item in
                ItemRow(item)
            }
        }
    }

    // FAB（右下固定）
    VStack {
        Spacer()
        HStack {
            Spacer()
            FloatingActionButton(icon: "plus") {
                createNewItem()
            }
            .padding(spacing.lg)
        }
    }
}
```

---

## SafeAreaを考慮した配置

```swift
ZStack(alignment: .bottomTrailing) {
    // メインコンテンツ
    ContentView()

    // FAB
    FloatingActionButton(icon: "plus") {
        createNewItem()
    }
    .padding(spacing.lg)
    .padding(.bottom, spacing.lg) // SafeArea追加
}
```

---

## Extended FAB（ラベル付き）

標準のFABはアイコンのみですが、ラベル付きが必要な場合：

```swift
Button {
    createNewItem()
} label: {
    HStack(spacing: spacing.sm) {
        Image(systemName: "plus")
        Text("新規作成")
            .typography(.labelLarge)
    }
    .padding(.horizontal, spacing.lg)
    .padding(.vertical, spacing.md)
}
.buttonStyle(.primary)
.clipShape(Capsule())
.elevation(.level3)
```

---

## スクロールで隠す

```swift
@State private var showFAB = true
@State private var lastScrollOffset: CGFloat = 0

ZStack {
    ScrollView {
        LazyVStack {
            // コンテンツ
        }
        .background(GeometryReader { geo in
            Color.clear.preference(
                key: ScrollOffsetKey.self,
                value: geo.frame(in: .named("scroll")).minY
            )
        })
    }
    .coordinateSpace(name: "scroll")
    .onPreferenceChange(ScrollOffsetKey.self) { offset in
        let scrollingDown = offset < lastScrollOffset
        withAnimation(motion.toggle) {
            showFAB = !scrollingDown
        }
        lastScrollOffset = offset
    }

    if showFAB {
        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton(icon: "plus") {
                    createNewItem()
                }
                .padding(spacing.lg)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: FABコンポーネントを使用
FloatingActionButton(icon: "plus", size: .regular) {
    action()
}

// ❌ Bad: 独自実装
Button { } label: {
    Image(systemName: "plus")
        .font(.title2)
        .foregroundColor(.white)
        .frame(width: 56, height: 56)
        .background(Circle().fill(Color.blue))
        .shadow(radius: 4)
}
```
