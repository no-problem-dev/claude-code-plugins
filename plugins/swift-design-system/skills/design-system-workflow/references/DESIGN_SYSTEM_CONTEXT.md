# swift-design-system クイックリファレンス

## Quick Reference（最頻出パターン）

```swift
import DesignSystem

// --- アプリルートで ThemeProvider を設定 ---
@main
struct MyApp: App {
    @State private var themeProvider = ThemeProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .theme(themeProvider)  // 必須: デザイントークンを有効化
        }
    }
}

// --- View でトークンを使用 ---
struct ContentView: View {
    @Environment(\.colorPalette) var colors
    @Environment(\.spacingScale) var spacing
    @Environment(\.radiusScale) var radius
    @Environment(\.motion) var motion

    var body: some View {
        VStack(spacing: spacing.lg) {
            Text("見出し")
                .typography(.headlineLarge)
                .foregroundStyle(colors.onSurface)

            Button("保存") { save() }
                .buttonStyle(.primary)
                .buttonSize(.large)
        }
        .padding(spacing.xl)
        .background(colors.background)
    }
}
```

## Environment Keys

| Key | Type | 取得方法 |
|-----|------|---------|
| `\.colorPalette` | `any ColorPalette` | `@Environment(\.colorPalette) var colors` |
| `\.spacingScale` | `any SpacingScale` | `@Environment(\.spacingScale) var spacing` |
| `\.radiusScale` | `any RadiusScale` | `@Environment(\.radiusScale) var radius` |
| `\.motion` | `any Motion` | `@Environment(\.motion) var motion` |
| `\.buttonSize` | `ButtonSize` | `@Environment(\.buttonSize) var buttonSize` |

## ColorPalette プロトコル

### Primary / Secondary / Tertiary
| プロパティ | 用途 |
|-----------|------|
| `primary` | 主要アクション、ブランド要素 |
| `onPrimary` | Primary 背景上のテキスト/アイコン（デフォルト: `.white`） |
| `primaryContainer` | Primary の薄い背景（デフォルト: `primary.opacity(0.12)`） |
| `onPrimaryContainer` | PrimaryContainer 上のテキスト（デフォルト: `primary`） |
| `secondary` | 補助的なアクセントカラー |
| `onSecondary` | Secondary 背景上のテキスト |
| `secondaryContainer` / `onSecondaryContainer` | Secondary の薄いコンテナ |
| `tertiary` / `onTertiary` | 第 3 のアクセント |

### Background / Surface
| プロパティ | 用途 |
|-----------|------|
| `background` / `onBackground` | アプリ全体の背景 |
| `surface` / `onSurface` | カード、シート、ダイアログ |
| `surfaceVariant` / `onSurfaceVariant` | Surface の代替（微妙な差分） |

### Semantic State
| プロパティ | 用途 |
|-----------|------|
| `error` / `onError` | エラー状態 |
| `errorContainer` / `onErrorContainer` | エラーコンテナ |
| `warning` / `onWarning` | 警告状態 |
| `success` / `onSuccess` | 成功状態 |
| `info` / `onInfo` | 情報表示 |

### Outline
| プロパティ | 用途 |
|-----------|------|
| `outline` | ボーダー、区切り線 |
| `outlineVariant` | Outline の薄いバリエーション |

## SpacingScale

| トークン | 値 | 用途 |
|---------|-----|------|
| `none` | 0pt | 間隔なし |
| `xxs` | 2pt | 最小の間隔 |
| `xs` | 4pt | とても小さい |
| `sm` | 8pt | 小さい |
| `md` | 12pt | 中程度 |
| `lg` | 16pt | 標準（推奨デフォルト） |
| `xl` | 24pt | 大きい |
| `xxl` | 32pt | とても大きい |
| `xxxl` | 48pt | 非常に大きい |
| `xxxxl` | 64pt | 最大 |

```swift
VStack(spacing: spacing.lg) { ... }
.padding(spacing.xl)
.padding(.horizontal, spacing.lg)
```

## RadiusScale

| トークン | 値 | 用途 |
|---------|-----|------|
| `none` | 0pt | 角丸なし |
| `xs` | 2pt | 最小 |
| `sm` | 4pt | 小さい |
| `md` | 8pt | カード推奨 |
| `lg` | 12pt | 大きい |
| `xl` | 16pt | とても大きい |
| `xxl` | 20pt | 非常に大きい |
| `full` | 9999pt | 完全な円形 |

```swift
.clipShape(RoundedRectangle(cornerRadius: radius.md))
```

## Typography

| カテゴリ | ケース | サイズ | ウェイト |
|---------|--------|--------|---------|
| Display | `displayLarge` | 57pt | Bold |
| | `displayMedium` | 45pt | Bold |
| | `displaySmall` | 36pt | Bold |
| Headline | `headlineLarge` | 32pt | Semibold |
| | `headlineMedium` | 28pt | Semibold |
| | `headlineSmall` | 24pt | Semibold |
| Title | `titleLarge` | 22pt | Semibold |
| | `titleMedium` | 16pt | Semibold |
| | `titleSmall` | 14pt | Semibold |
| Body | `bodyLarge` | 16pt | Regular |
| | `bodyMedium` | 14pt | Regular |
| | `bodySmall` | 12pt | Regular |
| Label | `labelLarge` | 14pt | Medium |
| | `labelMedium` | 12pt | Medium |
| | `labelSmall` | 11pt | Medium |

```swift
Text("見出し").typography(.headlineLarge)
Text("見出し").typography(.headlineLarge, design: .serif)
```

## Elevation

| レベル | Radius | Offset Y | Opacity | 用途 |
|--------|--------|----------|---------|------|
| `level0` | 0 | 0 | 0 | 影なし |
| `level1` | 3 | 1 | 0.12 | リスト項目、軽いカード |
| `level2` | 6 | 2 | 0.14 | カード、パネル（推奨） |
| `level3` | 8 | 4 | 0.16 | 浮き上がったカード |
| `level4` | 10 | 6 | 0.18 | モーダル、ポップアップ |
| `level5` | 12 | 8 | 0.20 | ドロワー、重要なダイアログ |

```swift
Card { Text("内容") }.elevation(.level2)
RoundedRectangle(cornerRadius: 12).elevation(.level3)
```

## Motion

| トークン | Duration | Easing | 用途 |
|---------|----------|--------|------|
| `quick` | 70ms | ease-out | ホバー、カーソルフィードバック |
| `tap` | 110ms | ease-out | ボタン押下、スイッチ |
| `toggle` | 150ms | ease-in-out | 選択状態切り替え |
| `fadeIn` | 150ms | ease-out | 要素の出現 |
| `fadeOut` | 150ms | ease-in | 要素の消失 |
| `slide` | 240ms | ease-in-out | タブ切り替え、ページネーション |
| `slow` | 300ms | ease-in-out | セクション展開 |
| `slower` | 375ms | ease-in-out | ナビゲーション遷移 |
| `spring` | response 0.3s, damping 0.6 | spring | ドラッグ＆ドロップ |
| `bounce` | response 0.5s, damping 0.5 | spring | 楽しさの演出 |

```swift
.scaleEffect(isPressed ? 0.98 : 1.0)
.animate(motion.tap, value: isPressed)  // アクセシビリティ自動対応
```

## コンポーネント一覧

### Button Styles
```swift
Button("ログイン") { }.buttonStyle(.primary)   // 最重要アクション（1画面1つ推奨）
Button("キャンセル") { }.buttonStyle(.secondary) // 補助的アクション
Button("スキップ") { }.buttonStyle(.tertiary)   // 控えめなアクション

// サイズ: .large(56pt, default), .medium(48pt), .small(40pt)
.buttonSize(.medium)
```

### Card
```swift
Card { content() }                                         // デフォルト (elevation: .level1, padding: 16)
Card(elevation: .level3, cornerRadius: 20) { content() }   // カスタム
Card(elevation: .level2, allSides: 12) { content() }       // 均一パディング
```

### Chip
```swift
Chip("Active").chipStyle(.filled)                          // 静的チップ
Chip("完了", systemImage: "checkmark.circle.fill")          // アイコン付き
    .chipStyle(.filled).chipSize(.small)                   // サイズ: .small(24pt), .medium(32pt, default)
Chip("Swift", onDelete: { removeTag() }).chipStyle(.filled) // 削除可能
Chip("フィルター", isSelected: $isFiltered).chipStyle(.outlined) // 選択可能
Chip("再生", systemImage: "play.fill", action: { play() })  // アクション

// スタイル: .filled, .outlined, .liquidGlass
```

### FloatingActionButton (FAB)
```swift
FloatingActionButton(icon: "plus") { createNew() }              // regular (56pt)
FloatingActionButton(icon: "pencil", size: .small) { edit() }   // small (40pt)
FloatingActionButton(icon: "photo", size: .large) { add() }     // large (96pt)
```

### IconButton
```swift
IconButton(icon: "heart", style: .standard) { }  // 背景なし
IconButton(icon: "star", style: .filled) { }      // Primary背景
IconButton(icon: "bell", style: .tonal) { }       // SecondaryContainer背景
IconButton(icon: "gear", style: .outlined) { }    // アウトライン

// サイズ: .small(32pt), .medium(40pt, default), .large(48pt)
IconButton(icon: "gear", style: .tonal, size: .large) { }
```

### IconBadge
```swift
IconBadge(systemName: "star.fill")                               // デフォルト
IconBadge(systemName: "heart.fill", size: .large,
          foregroundColor: .red, backgroundColor: .red.opacity(0.15))
// サイズ: .small(32pt), .medium(48pt), .large(64pt), .extraLarge(80pt)
```

### ProgressBar
```swift
ProgressBar(value: 0.75)                                         // シンプル
ProgressBar(value: 0.5, gradient: .init(colors: [.blue, .purple]),
            startPoint: .leading, endPoint: .trailing)            // グラデーション
ProgressBar(value: progress, height: 12, animated: true)         // アニメーション
```

### StatDisplay
```swift
StatDisplay(value: "42.5", unit: "kg")                           // 基本
StatDisplay(value: "1,234", unit: "steps", size: .large)         // 大きいサイズ
StatDisplay(value: "98%", unit: "complete", valueColor: .green)  // カスタム色
// サイズ: .small(24pt), .medium(32pt), .large(48pt), .extraLarge(64pt)
// alignment: .leading(default), .center, .trailing
```

### Snackbar
```swift
@State private var snackbarState = SnackbarState()

ZStack {
    ContentView()
    Snackbar(state: snackbarState)
}

// 表示
snackbarState.show(message: "保存しました")
snackbarState.show(
    message: "削除しました",
    primaryAction: SnackbarAction(title: "元に戻す") { undo() },
    duration: 5.0
)
snackbarState.dismiss()  // 手動消去
```

### DSTextField
```swift
DSTextField("メール", text: $email, placeholder: "example@email.com",
            leadingIcon: "envelope")                              // Outlined（デフォルト）
DSTextField("パスワード", text: $password, placeholder: "8文字以上",
            style: .filled, error: errorMsg, leadingIcon: "lock") // Filled + エラー
DSTextField("名前", text: $name, supportingText: "英数字のみ")      // サポートテキスト
```

### VideoPlayerView
```swift
VideoPlayerView(url: videoURL)
```

## レイアウトパターン

### SectionCard
```swift
ScrollView {
    VStack(spacing: spacing.xl) {
        SectionCard(title: "基本設定") {
            VStack(spacing: spacing.md) {
                Toggle("通知", isOn: $notif)
                Toggle("ダークモード", isOn: $dark)
            }
        }
        SectionCard(title: "プロフィール", elevation: .level2) {
            Text("内容")
        }
    }
}
// 注意: .padding(.horizontal) は SectionCard が自動管理（spacing.lg）
```

### AspectGrid
```swift
AspectGrid(
    minItemWidth: 140, maxItemWidth: 180,
    itemAspectRatio: 1,   // 正方形
    spacing: .md           // GridSpacing: .xs(8), .sm(12), .md(16), .lg(20), .xl(24)
) {
    ForEach(items) { item in ItemView(item) }
}
```

## Pickers

### ColorPicker
```swift
.colorPicker(preset: .tagFriendly, selectedColor: $selectedColor, isPresented: $show)
```

### EmojiPicker
```swift
.emojiPicker(categories: emojiCategories, selectedEmoji: $emoji, isPresented: $show)
// EmojiCategory(id:, displayName:, emojis: [EmojiItem(id:, emoji:, displayName:)])
```

### IconPicker (SF Symbols)
```swift
.iconPicker(categories: iconCategories, selectedIcon: $icon, isPresented: $show)
// IconCategory(id:, displayName:, icons: [IconItem(id:, systemName:, displayName:)])
```

### ImagePicker (iOS only)
```swift
.imagePicker(isPresented: $show, selectedImageData: $imageData, maxSize: 1.mb)
// Info.plist 必須: NSCameraUsageDescription, NSPhotoLibraryUsageDescription
```

## テーマシステム

### ビルトインテーマ（7 種類）
| ID | 名前 | カテゴリ |
|----|------|---------|
| `default` | Default | standard |
| `ocean` | Ocean | brandPersonality |
| `forest` | Forest | brandPersonality |
| `sunset` | Sunset | brandPersonality |
| `purpleHaze` | PurpleHaze | brandPersonality |
| `monochrome` | Monochrome | brandPersonality |
| `highContrast` | HighContrast | accessibility (WCAG AAA) |

### ThemeProvider の操作
```swift
@State private var themeProvider = ThemeProvider(
    initialTheme: OceanTheme(),     // 初期テーマ（省略時: DefaultTheme）
    initialMode: .system            // .system / .light / .dark
)

themeProvider.switchToTheme(id: "ocean")  // テーマ切り替え
themeProvider.themeMode = .dark           // モード変更
themeProvider.toggleMode()               // system -> light -> dark -> system
themeProvider.registerTheme(MyTheme())   // カスタムテーマ登録
```

### カスタムテーマの作成
```swift
struct MyTheme: Theme {
    var id: String { "my-theme" }
    var name: String { "My Theme" }
    var description: String { "説明" }
    var category: ThemeCategory { .custom }
    var previewColors: [Color] { [.blue, .cyan, .teal] }

    func colorPalette(for mode: ThemeMode) -> any ColorPalette {
        switch mode {
        case .light, .system: return MyLightPalette()
        case .dark: return MyDarkPalette()
        }
    }
}

struct MyLightPalette: ColorPalette {
    var primary: Color { Color(hex: "#007AFF") }
    var secondary: Color { Color(hex: "#5856D6") }
    var tertiary: Color { Color(hex: "#FF9500") }
    var background: Color { .white }
    var onBackground: Color { Color(hex: "#1C1C1E") }
    var surface: Color { Color(hex: "#F2F2F7") }
    var onSurface: Color { Color(hex: "#1C1C1E") }
    var surfaceVariant: Color { Color(hex: "#E5E5EA") }
    var onSurfaceVariant: Color { Color(hex: "#8E8E93") }
    var error: Color { Color(hex: "#FF3B30") }
    var warning: Color { Color(hex: "#FF9500") }
    var success: Color { Color(hex: "#34C759") }
    var info: Color { Color(hex: "#007AFF") }
    var outline: Color { Color(hex: "#C7C7CC") }
}
```

## ViewModifiers まとめ

| モディファイア | 用途 | 例 |
|--------------|------|-----|
| `.theme(_:)` | ThemeProvider 適用（ルートビュー） | `.theme(themeProvider)` |
| `.typography(_:)` | タイポグラフィトークン適用 | `.typography(.headlineLarge)` |
| `.typography(_:design:)` | デザイン指定付きタイポグラフィ | `.typography(.bodyLarge, design: .serif)` |
| `.elevation(_:)` | 影レベル適用 | `.elevation(.level2)` |
| `.animate(_:value:)` | アニメーション（a11y 自動対応） | `.animate(motion.tap, value: isPressed)` |
| `.buttonSize(_:)` | ボタンサイズ設定 | `.buttonSize(.medium)` |
| `.buttonStyle(.primary)` | プライマリボタンスタイル | `.buttonStyle(.primary)` |
| `.chipStyle(_:)` | チップスタイル | `.chipStyle(.filled)` |
| `.chipSize(_:)` | チップサイズ | `.chipSize(.small)` |
| `.colorPicker(...)` | カラーピッカー表示 | `.colorPicker(preset:selectedColor:isPresented:)` |
| `.emojiPicker(...)` | 絵文字ピッカー表示 | `.emojiPicker(categories:selectedEmoji:isPresented:)` |
| `.iconPicker(...)` | アイコンピッカー表示 | `.iconPicker(categories:selectedIcon:isPresented:)` |
| `.imagePicker(...)` | 画像ピッカー表示 (iOS) | `.imagePicker(isPresented:selectedImageData:maxSize:)` |

## ユーティリティ

### Color+Hex
```swift
Color(hex: "#FF5733")       // 6桁 RGB
Color(hex: "3B82F6")        // # なし
Color(hex: "#F00")          // 3桁短縮
Color(hex: "80FF5733")      // 8桁 ARGB（50%透明）
```

### ByteSize (ImagePicker 用)
```swift
1.mb    // 1MB
500.kb  // 500KB
```

## ルール

### ALWAYS
- `.theme(themeProvider)` をルートビューに適用する
- 色は `@Environment(\.colorPalette)` からのみ取得する
- 間隔は `@Environment(\.spacingScale)` からのみ取得する
- 角丸は `@Environment(\.radiusScale)` からのみ取得する
- アニメーションは `.animate()` モディファイアを使用する（a11y 自動対応）
- テキストスタイルは `.typography()` を使用する
- ボタンには `.buttonStyle(.primary/.secondary/.tertiary)` を使用する
- Preview には `.theme(ThemeProvider())` を付ける

### NEVER
- `Color.blue`, `Color.red` 等のハードコードされた色を使用しない
- `.font(.system(size: 16))` 等の直接フォント指定をしない（`.typography()` を使う）
- `.padding(16)` 等のマジックナンバーを使用しない（`spacing.lg` を使う）
- `.cornerRadius(8)` 等の直接数値を使用しない（`radius.md` を使う）
- `.shadow()` を直接使用しない（`.elevation()` を使う）
- `.animation()` を直接使用しない（`.animate()` を使う）
- ThemeProvider なしでデザインシステムコンポーネントを使用しない
