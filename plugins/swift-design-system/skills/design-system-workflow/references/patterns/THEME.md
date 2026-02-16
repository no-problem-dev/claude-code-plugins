# Theme パターン

テーマ設定・切り替え・カスタムテーマ作成のパターン。

---

## アプリ起動時の設定（必須）

```swift
import DesignSystem

@main
struct MyApp: App {
    @State private var themeProvider = ThemeProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .theme(themeProvider)  // 必須
        }
    }
}
```

---

## 組み込みテーマ（7種類）

| テーマ | ID | 特徴 | 用途 |
|-------|-----|------|------|
| DefaultTheme | `default` | 青ベースのニュートラル | 汎用 |
| OceanTheme | `ocean` | 落ち着いた青 | ビジネス、プロフェッショナル |
| ForestTheme | `forest` | 安定感のある緑 | 自然、環境、健康 |
| SunsetTheme | `sunset` | エネルギッシュなオレンジ | クリエイティブ、活力 |
| PurpleHazeTheme | `purpleHaze` | 革新的な紫 | テクノロジー、革新 |
| MonochromeTheme | `monochrome` | エレガントなグレー | ミニマル、高級感 |
| HighContrastTheme | `highContrast` | 最大コントラスト | アクセシビリティ重視 |

---

## テーマ切り替え

```swift
// IDで切り替え
themeProvider.switchToTheme(id: "ocean")

// Light/Dark モード切り替え
themeProvider.toggleMode()

// モード直接指定
themeProvider.themeMode = .light   // .light / .dark / .system
```

---

## 設定画面でのテーマ選択

```swift
struct ThemeSettingsView: View {
    @Environment(\.themeProvider) var themeProvider

    let themes: [(id: String, name: String)] = [
        ("default", "デフォルト"),
        ("ocean", "オーシャン"),
        ("forest", "フォレスト"),
        ("sunset", "サンセット"),
        ("purpleHaze", "パープルヘイズ"),
        ("monochrome", "モノクローム"),
        ("highContrast", "ハイコントラスト")
    ]

    var body: some View {
        List {
            Section("テーマ") {
                ForEach(themes, id: \.id) { theme in
                    Button {
                        themeProvider.switchToTheme(id: theme.id)
                    } label: {
                        HStack {
                            Text(theme.name)
                            Spacer()
                            if themeProvider.currentTheme.id == theme.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(colors.primary)
                            }
                        }
                    }
                }
            }

            Section("外観モード") {
                Picker("モード", selection: $themeProvider.themeMode) {
                    Text("システム").tag(ThemeMode.system)
                    Text("ライト").tag(ThemeMode.light)
                    Text("ダーク").tag(ThemeMode.dark)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
```

---

## 追加テーマの登録

```swift
// 初期テーマとして
@State private var themeProvider = ThemeProvider(
    initialTheme: MyBrandTheme()
)

// 追加テーマとして
@State private var themeProvider = ThemeProvider(
    additionalThemes: [MyBrandTheme(), AnotherTheme()]
)
```

---

## カスタムテーマの作成

### Step 1: ColorPalette実装

```swift
struct MyBrandLightPalette: ColorPalette {
    // Primary
    let primary = Color(hex: "#1A73E8")
    let onPrimary = Color.white
    let primaryContainer = Color(hex: "#D2E3FC")
    let onPrimaryContainer = Color(hex: "#0D47A1")

    // Secondary
    let secondary = Color(hex: "#5F6368")
    let onSecondary = Color.white
    let secondaryContainer = Color(hex: "#E8EAED")
    let onSecondaryContainer = Color(hex: "#3C4043")

    // Tertiary
    let tertiary = Color(hex: "#1E8E3E")
    let onTertiary = Color.white

    // Background / Surface
    let background = Color(hex: "#FFFFFF")
    let onBackground = Color(hex: "#202124")
    let surface = Color(hex: "#FFFFFF")
    let onSurface = Color(hex: "#202124")
    let surfaceVariant = Color(hex: "#F1F3F4")
    let onSurfaceVariant = Color(hex: "#5F6368")

    // States
    let error = Color(hex: "#D93025")
    let onError = Color.white
    let errorContainer = Color(hex: "#FCE8E6")
    let onErrorContainer = Color(hex: "#B31412")
    let warning = Color(hex: "#F9AB00")
    let onWarning = Color.black
    let success = Color(hex: "#1E8E3E")
    let onSuccess = Color.white
    let info = Color(hex: "#1A73E8")
    let onInfo = Color.white

    // Outline
    let outline = Color(hex: "#DADCE0")
    let outlineVariant = Color(hex: "#E8EAED")
}

struct MyBrandDarkPalette: ColorPalette {
    // Dark mode用のカラー定義
    // ...
}
```

### Step 2: Theme実装

```swift
struct MyBrandTheme: Theme {
    var id: String { "myBrand" }
    var name: String { "マイブランド" }
    var category: ThemeCategory { .brandPersonality }

    func colorPalette(for mode: ThemeMode) -> any ColorPalette {
        switch mode {
        case .light:
            return MyBrandLightPalette()
        case .dark:
            return MyBrandDarkPalette()
        case .system:
            // システム設定に従う場合の処理
            return MyBrandLightPalette()
        }
    }
}
```

### Step 3: 登録

```swift
@State private var themeProvider = ThemeProvider(
    initialTheme: MyBrandTheme()
)
```

---

## テーマプレビューコンポーネント

```swift
struct ThemePreviewCard: View {
    let themeId: String
    let themeName: String
    @Environment(\.colorPalette) var colors

    var body: some View {
        VStack(spacing: spacing.sm) {
            // カラーサンプル
            HStack(spacing: spacing.xs) {
                Circle().fill(colors.primary)
                Circle().fill(colors.secondary)
                Circle().fill(colors.tertiary)
            }
            .frame(height: 24)

            Text(themeName)
                .typography(.labelMedium)
        }
        .padding(spacing.md)
        .background(colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: radius.md))
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: ThemeProviderで一元管理
@State private var themeProvider = ThemeProvider()
ContentView().theme(themeProvider)

// ❌ Bad: 個別にカラーを管理
@AppStorage("primaryColor") var primaryColor = "blue"
// カラーの一貫性が失われる
```
