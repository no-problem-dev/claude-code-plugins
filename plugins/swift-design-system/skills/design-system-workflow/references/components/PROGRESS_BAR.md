# ProgressBar コンポーネント

進捗状況を水平バーで視覚的に表示。ソリッドカラーとグラデーションの2つのバリエーションを提供。

---

## 特徴

- 0.0〜1.0 の値で進捗を表現
- ソリッドカラー版とグラデーション版
- カスタマイズ可能な高さ・角丸・色
- アニメーション対応（値の変化をスムーズに表現）

## パラメータ

| パラメータ | デフォルト | 説明 |
|-----------|-----------|------|
| `value` | - | 進捗値（0.0〜1.0） |
| `height` | 8pt | バーの高さ |
| `cornerRadius` | height / 2 | 角丸 |
| `foregroundColor` | primary | バーの色 |
| `backgroundColor` | surfaceVariant | 背景色 |
| `animated` | false | アニメーション有効化 |
| `animation` | .easeInOut(0.3) | アニメーション種類 |

---

## 基本使用法

```swift
import DesignSystem

// シンプルなプログレスバー
ProgressBar(value: 0.6)

// 高さをカスタマイズ
ProgressBar(value: 0.4, height: 12)

// アニメーション付き
ProgressBar(value: progress, animated: true)
```

---

## 色のカスタマイズ

```swift
@Environment(\.colorPalette) var colors

// カスタムカラー
ProgressBar(
    value: 0.75,
    foregroundColor: colors.tertiary,
    backgroundColor: colors.tertiaryContainer
)

// グラデーション版
ProgressBar(
    value: 0.8,
    gradient: LinearGradient(
        colors: [colors.primary, colors.tertiary],
        startPoint: .leading,
        endPoint: .trailing
    )
)
```

---

## アニメーション付き進捗

```swift
@State private var progress: Double = 0.0

VStack(spacing: spacing.md) {
    ProgressBar(
        value: progress,
        animated: true,
        animation: .easeInOut(duration: 0.5)
    )

    Button("進捗を更新") {
        progress = min(progress + 0.2, 1.0)
    }
    .buttonStyle(.primary)
}
```

---

## ダウンロード進捗 UI

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

@State private var downloadProgress: Double = 0.0

VStack(alignment: .leading, spacing: spacing.sm) {
    HStack {
        Text("ダウンロード中...")
            .typography(.bodyMedium)

        Spacer()

        Text("\(Int(downloadProgress * 100))%")
            .typography(.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
    }

    ProgressBar(
        value: downloadProgress,
        height: 6,
        animated: true
    )
}
.padding(spacing.lg)
```

---

## ステップ進捗

```swift
@Environment(\.spacingScale) var spacing

let totalSteps = 5
let currentStep = 3

VStack(alignment: .leading, spacing: spacing.sm) {
    Text("ステップ \(currentStep) / \(totalSteps)")
        .typography(.labelMedium)

    ProgressBar(
        value: Double(currentStep) / Double(totalSteps),
        height: 8,
        animated: true
    )
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: ProgressBar コンポーネントを使用
ProgressBar(value: 0.6, animated: true)

// ❌ Bad: 独自実装
GeometryReader { geo in
    ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 8)
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.blue)
            .frame(width: geo.size.width * 0.6, height: 8)
    }
}

// ✅ Good: グラデーション版を使用
ProgressBar(
    value: progress,
    gradient: LinearGradient(
        colors: [colors.primary, colors.tertiary],
        startPoint: .leading,
        endPoint: .trailing
    )
)

// ❌ Bad: ハードコードされた色
ProgressBar(
    value: progress,
    foregroundColor: Color(red: 0.2, green: 0.5, blue: 1.0)
)
```
