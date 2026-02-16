# SwiftUI Preview パターンガイド

AI 駆動開発における Preview の活用パターン。Claude が生成した UI を即座に検証するための必須テクニック。

---

## 1. なぜ Preview が重要か

Claude は画面を直接見ることができない。Preview は以下の役割を担う:

- **即時フィードバック**: コード変更の結果をビルドなしで確認
- **状態網羅**: 正常系だけでなくエッジケースを体系的に検証
- **テーマ対応**: Light/Dark、複数テーマでの表示を一括確認
- **アクセシビリティ**: Dynamic Type、ReduceMotion への対応確認

Preview を書かない UI コードは、目を閉じて絵を描くのと同じ。

---

## 2. 必須 Preview 状態

すべてのコンポーネントで以下の状態を Preview すること:

### 最低限の必須状態

| 状態 | 目的 | 修飾子 |
|------|------|--------|
| Default (Light) | 基本表示の確認 | なし（デフォルト） |
| Dark Mode | ダークモードでの視認性 | `.preferredColorScheme(.dark)` |
| Large Text | Dynamic Type 対応 | `.environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)` |
| Compact Width | 小さいデバイスでのレイアウト | `.previewLayout(.fixed(width: 320, height: ...))` |

### コンテンツバリエーション

| 状態 | 目的 |
|------|------|
| Long Text | テキストが長い場合のレイアウト崩れ確認 |
| Empty State | データがない場合の表示 |
| Error State | エラー発生時の表示 |
| Loading State | データ読み込み中の表示 |
| Maximum Content | すべての情報が最大量の場合 |

---

## 3. Preview テンプレート

### 3.1 単一コンポーネント Preview

最も基本的なパターン。コンポーネント単体の全状態を確認する。

```swift
import SwiftUI
import DesignSystem

// MARK: - Component

struct TaskCard: View {
    @Environment(\.colorPalette) var colors
    @Environment(\.spacingScale) var spacing

    let title: String
    let subtitle: String
    let isCompleted: Bool

    var body: some View {
        Card {
            HStack(spacing: spacing.md) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? colors.success : colors.outline)
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: spacing.xs) {
                    Text(title)
                        .typography(.titleMedium)
                        .foregroundStyle(colors.onSurface)
                        .strikethrough(isCompleted)

                    Text(subtitle)
                        .typography(.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                }

                Spacer()
            }
        }
        .padding(.horizontal, spacing.lg)
    }
}

// MARK: - Previews

#Preview("Default") {
    TaskCard(
        title: "デザインレビュー",
        subtitle: "明日 14:00 まで",
        isCompleted: false
    )
    .theme(ThemeProvider())
}

#Preview("Completed") {
    TaskCard(
        title: "デザインレビュー",
        subtitle: "完了済み",
        isCompleted: true
    )
    .theme(ThemeProvider())
}

#Preview("Long Text") {
    TaskCard(
        title: "非常に長いタスク名がここに入る場合のレイアウト確認用テキスト",
        subtitle: "2024年12月31日 23:59 までに完了する必要があります。遅延すると影響が出ます。",
        isCompleted: false
    )
    .theme(ThemeProvider())
}

#Preview("Dark Mode") {
    TaskCard(
        title: "デザインレビュー",
        subtitle: "明日 14:00 まで",
        isCompleted: false
    )
    .theme(ThemeProvider(initialMode: .dark))
}

#Preview("Large Text") {
    TaskCard(
        title: "デザインレビュー",
        subtitle: "明日 14:00 まで",
        isCompleted: false
    )
    .theme(ThemeProvider())
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}

#Preview("Compact Width") {
    TaskCard(
        title: "デザインレビュー",
        subtitle: "明日 14:00 まで",
        isCompleted: false
    )
    .theme(ThemeProvider())
    .previewLayout(.fixed(width: 320, height: 120))
}
```

### 3.2 画面レベル Preview

画面全体のレイアウトを確認する。複数コンポーネントの組み合わせ、スクロール、ナビゲーションを含む。

```swift
// MARK: - Screen

struct TaskListScreen: View {
    @Environment(\.colorPalette) var colors
    @Environment(\.spacingScale) var spacing

    let tasks: [TaskItem]
    let isLoading: Bool
    let error: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error {
                    VStack(spacing: spacing.lg) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(colors.error)
                        Text(error)
                            .typography(.bodyLarge)
                            .foregroundStyle(colors.onSurfaceVariant)
                        Button("リトライ") { }
                            .buttonStyle(.primary)
                            .buttonSize(.medium)
                            .frame(width: 200)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if tasks.isEmpty {
                    VStack(spacing: spacing.lg) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(colors.onSurfaceVariant)
                        Text("タスクがありません")
                            .typography(.bodyLarge)
                            .foregroundStyle(colors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: spacing.sm) {
                            ForEach(tasks) { task in
                                TaskCard(
                                    title: task.title,
                                    subtitle: task.subtitle,
                                    isCompleted: task.isCompleted
                                )
                            }
                        }
                        .padding(.vertical, spacing.lg)
                    }
                }
            }
            .background(colors.background)
            .navigationTitle("タスク")
        }
    }
}

// MARK: - Preview Data

extension TaskItem {
    static let sampleTasks: [TaskItem] = [
        TaskItem(id: "1", title: "デザインレビュー", subtitle: "明日 14:00 まで", isCompleted: false),
        TaskItem(id: "2", title: "API 設計書作成", subtitle: "今週中", isCompleted: false),
        TaskItem(id: "3", title: "ユーザーインタビュー", subtitle: "完了", isCompleted: true),
        TaskItem(id: "4", title: "プロトタイプ作成", subtitle: "来週月曜", isCompleted: false),
    ]
}

// MARK: - Screen Previews

#Preview("With Data") {
    TaskListScreen(tasks: TaskItem.sampleTasks, isLoading: false, error: nil)
        .theme(ThemeProvider())
}

#Preview("Empty State") {
    TaskListScreen(tasks: [], isLoading: false, error: nil)
        .theme(ThemeProvider())
}

#Preview("Loading") {
    TaskListScreen(tasks: [], isLoading: true, error: nil)
        .theme(ThemeProvider())
}

#Preview("Error") {
    TaskListScreen(
        tasks: [],
        isLoading: false,
        error: "ネットワークエラーが発生しました。接続を確認してください。"
    )
    .theme(ThemeProvider())
}

#Preview("Dark Mode") {
    TaskListScreen(tasks: TaskItem.sampleTasks, isLoading: false, error: nil)
        .theme(ThemeProvider(initialMode: .dark))
}

#Preview("Large Text") {
    TaskListScreen(tasks: TaskItem.sampleTasks, isLoading: false, error: nil)
        .theme(ThemeProvider())
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
```

### 3.3 テーマバリエーション Preview

すべてのテーマでの表示を一括確認する。

```swift
#Preview("All Themes - Light") {
    let themes: [(String, ThemeProvider)] = [
        ("Default", ThemeProvider(initialMode: .light)),
        ("Ocean", {
            let tp = ThemeProvider(initialMode: .light)
            tp.switchToTheme(id: "ocean")
            return tp
        }()),
        ("Forest", {
            let tp = ThemeProvider(initialMode: .light)
            tp.switchToTheme(id: "forest")
            return tp
        }()),
        ("Sunset", {
            let tp = ThemeProvider(initialMode: .light)
            tp.switchToTheme(id: "sunset")
            return tp
        }()),
        ("PurpleHaze", {
            let tp = ThemeProvider(initialMode: .light)
            tp.switchToTheme(id: "purplehaze")
            return tp
        }()),
        ("Monochrome", {
            let tp = ThemeProvider(initialMode: .light)
            tp.switchToTheme(id: "monochrome")
            return tp
        }()),
    ]

    ScrollView {
        VStack(spacing: 24) {
            ForEach(themes, id: \.0) { name, provider in
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TaskCard(
                        title: "デザインレビュー",
                        subtitle: "明日 14:00 まで",
                        isCompleted: false
                    )
                    .theme(provider)
                }
            }
        }
        .padding()
    }
}

#Preview("All Themes - Dark") {
    let themes: [(String, ThemeProvider)] = [
        ("Default", ThemeProvider(initialMode: .dark)),
        ("Ocean", {
            let tp = ThemeProvider(initialMode: .dark)
            tp.switchToTheme(id: "ocean")
            return tp
        }()),
        ("Forest", {
            let tp = ThemeProvider(initialMode: .dark)
            tp.switchToTheme(id: "forest")
            return tp
        }()),
        ("Sunset", {
            let tp = ThemeProvider(initialMode: .dark)
            tp.switchToTheme(id: "sunset")
            return tp
        }()),
        ("PurpleHaze", {
            let tp = ThemeProvider(initialMode: .dark)
            tp.switchToTheme(id: "purplehaze")
            return tp
        }()),
        ("Monochrome", {
            let tp = ThemeProvider(initialMode: .dark)
            tp.switchToTheme(id: "monochrome")
            return tp
        }()),
    ]

    ScrollView {
        VStack(spacing: 24) {
            ForEach(themes, id: \.0) { name, provider in
                VStack(alignment: .leading, spacing: 8) {
                    Text(name)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TaskCard(
                        title: "デザインレビュー",
                        subtitle: "明日 14:00 まで",
                        isCompleted: false
                    )
                    .theme(provider)
                }
            }
        }
        .padding()
    }
}
```

### 3.4 インタラクティブ状態 Preview

`@State` を使ったインタラクティブな Preview。

```swift
#Preview("Interactive") {
    struct InteractivePreview: View {
        @State private var text = ""
        @State private var isEnabled = true
        @State private var selectedFilter = false
        @State private var snackbarState = SnackbarState()

        var body: some View {
            VStack(spacing: 24) {
                // TextField の状態変化
                DSTextField(
                    "メールアドレス",
                    text: $text,
                    placeholder: "example@email.com",
                    error: text.isEmpty ? nil : (text.contains("@") ? nil : "有効なメールアドレスを入力してください"),
                    leadingIcon: "envelope"
                )

                // ボタンの有効/無効
                Button("送信") { snackbarState.show(message: "送信しました") }
                    .buttonStyle(.primary)
                    .buttonSize(.large)
                    .disabled(text.isEmpty || !text.contains("@"))

                // フィルターチップの選択状態
                HStack(spacing: 8) {
                    Chip("すべて", isSelected: .constant(!selectedFilter))
                        .chipStyle(.outlined)
                    Chip("未完了", systemImage: "circle", isSelected: $selectedFilter)
                        .chipStyle(.outlined)
                }

                // トグル
                Toggle("通知を有効にする", isOn: $isEnabled)
                    .padding(.horizontal)
            }
            .padding()
            .overlay {
                Snackbar(state: snackbarState)
            }
            .theme(ThemeProvider())
        }
    }

    return InteractivePreview()
}
```

---

## 4. Preview の構造化

### 命名規則

Preview の表示名は以下の規則に従う:

```swift
// コンポーネント名は #Preview の引数で指定
// 状態を明示する名前にする

#Preview("Default")          // 基本状態
#Preview("Dark Mode")        // ダークモード
#Preview("Large Text")       // アクセシビリティ
#Preview("Empty State")      // データなし
#Preview("Error State")      // エラー
#Preview("Loading")          // 読み込み中
#Preview("Long Text")        // 長いテキスト
#Preview("Compact Width")    // 小さいデバイス
#Preview("Interactive")      // インタラクティブ
#Preview("All Themes - Light")  // テーマ一覧
#Preview("All Themes - Dark")   // テーマ一覧（ダーク）
```

### グルーピング戦略

1つのファイル内に関連する Preview をまとめる:

```swift
// ファイル末尾に Preview を配置
// 基本状態 → バリエーション → エッジケース → テーマ の順

// 1. 基本状態
#Preview("Default") { ... }
#Preview("Completed") { ... }

// 2. バリエーション
#Preview("With Icon") { ... }
#Preview("With Action") { ... }

// 3. エッジケース
#Preview("Long Text") { ... }
#Preview("Empty State") { ... }
#Preview("Error") { ... }

// 4. アクセシビリティ・テーマ
#Preview("Dark Mode") { ... }
#Preview("Large Text") { ... }
#Preview("All Themes - Light") { ... }
```

### `#Preview` マクロ vs `PreviewProvider`

**`#Preview` マクロを推奨**（iOS 17+）:

```swift
// 推奨: #Preview マクロ（簡潔で読みやすい）
#Preview("Default") {
    MyComponent()
        .theme(ThemeProvider())
}

// @Previewable で State を直接使える
#Preview("With State") {
    @Previewable @State var isOn = false

    Toggle("設定", isOn: $isOn)
        .padding()
        .theme(ThemeProvider())
}
```

**`PreviewProvider` が必要な場合**（iOS 16 以下サポート時のみ）:

```swift
struct MyComponent_Previews: PreviewProvider {
    static var previews: some View {
        MyComponent()
            .theme(ThemeProvider())
            .previewDisplayName("Default")
    }
}
```

---

## 5. ThemeProvider in Previews

### 必須ルール: 全 Preview で ThemeProvider をラップする

デザイントークン（`colorPalette`, `spacingScale`, `radiusScale`, `motion`）は ThemeProvider が Environment に注入する。ラップしないと、デフォルト値が使われてテーマが反映されない。

```swift
// GOOD: ThemeProvider でラップ
#Preview {
    MyView()
        .theme(ThemeProvider())  // 必須
}

// BAD: ThemeProvider なし
#Preview {
    MyView()  // デザイントークンがデフォルト値になる
}
```

### モード指定

```swift
// Light モード（明示的）
.theme(ThemeProvider(initialMode: .light))

// Dark モード
.theme(ThemeProvider(initialMode: .dark))

// System（デフォルト - Preview ではLight になる）
.theme(ThemeProvider())
```

### テーマ切り替え

```swift
// 特定テーマで Preview
#Preview("Ocean Theme") {
    let provider = {
        let tp = ThemeProvider(initialMode: .light)
        tp.switchToTheme(id: "ocean")
        return tp
    }()

    MyView()
        .theme(provider)
}
```

---

## 6. デバイスバリエーション

### 主要デバイスサイズ

| デバイス | 幅 | 高さ | 特徴 |
|---------|---:|-----:|------|
| iPhone SE (3rd) | 375 | 667 | 最小サイズ、ノッチなし |
| iPhone 15 | 393 | 852 | 標準サイズ |
| iPhone 15 Pro Max | 430 | 932 | 最大サイズ |
| iPad (10th) | 820 | 1180 | タブレット |

### デバイス固定 Preview

```swift
#Preview("iPhone SE") {
    MyScreen()
        .theme(ThemeProvider())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
}

#Preview("iPhone 15 Pro Max") {
    MyScreen()
        .theme(ThemeProvider())
        .previewDevice(PreviewDevice(rawValue: "iPhone 15 Pro Max"))
}
```

### 固定サイズ Preview（コンポーネント向け）

```swift
#Preview("Compact") {
    MyComponent()
        .theme(ThemeProvider())
        .previewLayout(.fixed(width: 320, height: 200))
}

#Preview("Wide") {
    MyComponent()
        .theme(ThemeProvider())
        .previewLayout(.fixed(width: 430, height: 200))
}
```

---

## 7. アンチパターン

### ThemeProvider の欠如

```swift
// BAD: カラーがデフォルトになる
#Preview {
    Card {
        Text("テスト")
    }
}

// GOOD
#Preview {
    Card {
        Text("テスト")
    }
    .theme(ThemeProvider())
}
```

### 単一状態のみの Preview

```swift
// BAD: 正常系だけ
#Preview {
    UserProfile(user: .sample)
        .theme(ThemeProvider())
}

// GOOD: 複数状態をカバー
#Preview("With Data") {
    UserProfile(user: .sample)
        .theme(ThemeProvider())
}
#Preview("Empty Avatar") {
    UserProfile(user: .sampleWithoutAvatar)
        .theme(ThemeProvider())
}
#Preview("Long Name") {
    UserProfile(user: .sampleWithLongName)
        .theme(ThemeProvider())
}
#Preview("Dark Mode") {
    UserProfile(user: .sample)
        .theme(ThemeProvider(initialMode: .dark))
}
```

### ハードコードされた Preview データ

```swift
// BAD: Preview 内でデータを直書き
#Preview {
    TaskCard(
        title: "テスト",
        subtitle: "テスト",
        isCompleted: false
    )
    .theme(ThemeProvider())
}

// GOOD: 再利用可能なサンプルデータを定義
extension TaskItem {
    static let sample = TaskItem(
        id: "preview-1",
        title: "デザインレビュー",
        subtitle: "明日 14:00 まで",
        isCompleted: false
    )

    static let sampleCompleted = TaskItem(
        id: "preview-2",
        title: "コードレビュー",
        subtitle: "完了",
        isCompleted: true
    )

    static let sampleLongText = TaskItem(
        id: "preview-3",
        title: "非常に長いタスク名がここに入る場合のレイアウト確認用テキスト",
        subtitle: "2024年12月31日 23:59 までに完了する必要があります",
        isCompleted: false
    )
}
```

### サイズカテゴリの確認漏れ

```swift
// BAD: 固定幅が Dynamic Type で溢れる
HStack {
    Text(title)
    Spacer()
    Text(value)
        .frame(width: 80)  // Large Text で溢れる
}

// GOOD: 柔軟なレイアウト
HStack {
    Text(title)
    Spacer()
    Text(value)
        .layoutPriority(1)
}
```

### @Previewable の不使用

```swift
// BAD: State のために struct を作成（冗長）
#Preview("Interactive") {
    struct Wrapper: View {
        @State private var text = ""
        var body: some View {
            DSTextField("名前", text: $text)
                .theme(ThemeProvider())
        }
    }
    return Wrapper()
}

// GOOD: @Previewable を使う（iOS 17+）
#Preview("Interactive") {
    @Previewable @State var text = ""

    DSTextField("名前", text: $text)
        .padding()
        .theme(ThemeProvider())
}
```

---

## Preview 作成チェックリスト

新しいコンポーネントを作成したら:

- [ ] Default (Light) Preview を追加
- [ ] Dark Mode Preview を追加
- [ ] Long Text / Maximum Content Preview を追加
- [ ] Large Text (Accessibility) Preview を追加
- [ ] Empty State Preview を追加（該当する場合）
- [ ] Error State Preview を追加（該当する場合）
- [ ] Loading State Preview を追加（該当する場合）
- [ ] すべての Preview で `.theme(ThemeProvider())` を使用
- [ ] サンプルデータを extension で定義
- [ ] `#Preview` マクロを使用（iOS 17+）
