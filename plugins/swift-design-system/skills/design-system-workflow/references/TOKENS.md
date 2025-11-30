# デザイントークン リファレンス

Swift Design Systemの全デザイントークン詳細仕様。すべてのUI実装で必須の知識。

---

## 1. カラーパレット (ColorPalette)

### アクセス方法

```swift
@Environment(\.colorPalette) var colors

Text("Hello").foregroundColor(colors.primary)
view.background(colors.surface)
```

### Primary カラー

ブランドを表現する主要カラー。CTAボタン、重要なアクション、アクティブ状態に使用。

| トークン | 用途 |
|---------|------|
| `primary` | 主要アクション、ブランドカラー |
| `onPrimary` | primary上のテキスト/アイコン |
| `primaryContainer` | 控えめなprimary背景 |
| `onPrimaryContainer` | primaryContainer上のテキスト |

```swift
Button("保存") { ... }
    .background(colors.primary)
    .foregroundColor(colors.onPrimary)
```

### Secondary カラー

補助的な要素、代替アクション、補足情報に使用。

| トークン | 用途 |
|---------|------|
| `secondary` | 補助的アクション |
| `onSecondary` | secondary上のテキスト |
| `secondaryContainer` | 控えめなsecondary背景 |
| `onSecondaryContainer` | secondaryContainer上のテキスト |

### Tertiary カラー

| トークン | 用途 |
|---------|------|
| `tertiary` | アクセント要素 |
| `onTertiary` | tertiary上のテキスト |

### Background / Surface カラー

| トークン | 用途 | 使用例 |
|---------|------|--------|
| `background` | 画面全体の背景 | ScrollViewの背景 |
| `onBackground` | background上のテキスト | 一般的なテキスト |
| `surface` | カード、パネルの背景 | Card背景 |
| `onSurface` | surface上のテキスト | カード内テキスト |
| `surfaceVariant` | 控えめなsurface | TextField背景 |
| `onSurfaceVariant` | surfaceVariant上のテキスト | プレースホルダー |

### セマンティックステートカラー

| トークン | 用途 |
|---------|------|
| `error` / `onError` | エラー状態 |
| `errorContainer` / `onErrorContainer` | エラーメッセージ背景 |
| `warning` / `onWarning` | 警告状態 |
| `success` / `onSuccess` | 成功状態 |
| `info` / `onInfo` | 情報状態 |

```swift
// エラー表示
HStack {
    Image(systemName: "exclamationmark.circle")
    Text("入力エラー")
}
.foregroundColor(colors.error)

// 成功バナー
Text("保存しました")
    .padding()
    .background(colors.success)
    .foregroundColor(colors.onSuccess)
```

### Outline カラー

| トークン | 用途 |
|---------|------|
| `outline` | 明確なボーダー（アウトラインボタン等） |
| `outlineVariant` | 控えめなボーダー（Divider等） |

---

## 2. タイポグラフィ (Typography)

### アクセス方法

```swift
Text("見出し").typography(.headlineLarge)
```

### Display（ヒーロー用）

| スタイル | サイズ | Weight | 用途 |
|---------|-------|--------|------|
| `displayLarge` | 57pt | Bold | ヒーローセクション |
| `displayMedium` | 45pt | Bold | 大見出し |
| `displaySmall` | 36pt | Bold | セクション見出し |

### Headline（ページ/セクション見出し）

| スタイル | サイズ | Weight | 用途 |
|---------|-------|--------|------|
| `headlineLarge` | 32pt | Semibold | ページタイトル |
| `headlineMedium` | 28pt | Semibold | セクションタイトル |
| `headlineSmall` | 24pt | Semibold | カードタイトル |

### Title（小見出し）

| スタイル | サイズ | Weight | 用途 |
|---------|-------|--------|------|
| `titleLarge` | 22pt | Semibold | リストヘッダー |
| `titleMedium` | 16pt | Semibold | サブヘッダー |
| `titleSmall` | 14pt | Semibold | キャプション見出し |

### Body（本文）

| スタイル | サイズ | Weight | 用途 |
|---------|-------|--------|------|
| `bodyLarge` | 16pt | Regular | 本文（強調） |
| `bodyMedium` | 14pt | Regular | 本文（標準） |
| `bodySmall` | 12pt | Regular | 補足テキスト |

### Label（ラベル）

| スタイル | サイズ | Weight | 用途 |
|---------|-------|--------|------|
| `labelLarge` | 14pt | Medium | ボタンラベル |
| `labelMedium` | 12pt | Medium | タブラベル |
| `labelSmall` | 11pt | Medium | バッジテキスト |

### カスタムフォント対応

```swift
Text("優雅な見出し")
    .typography(.headlineLarge)
    .fontDesign(.serif)      // serif / rounded / monospaced
```

---

## 3. スペーシング (SpacingScale)

### アクセス方法

```swift
@Environment(\.spacingScale) var spacing

VStack(spacing: spacing.lg) { ... }
.padding(spacing.xl)
```

### スケール定義

| トークン | サイズ | 用途 |
|---------|-------|------|
| `none` | 0pt | 間隔なし |
| `xxs` | 2pt | 最小間隔 |
| `xs` | 4pt | 非常にコンパクト |
| `sm` | 8pt | コンパクトレイアウト |
| `md` | 12pt | 中間スペーシング |
| `lg` | 16pt | **標準（デフォルト）** |
| `xl` | 24pt | 大きめの間隔 |
| `xxl` | 32pt | セクション間 |
| `xxxl` | 48pt | 大セクション間 |
| `xxxxl` | 64pt | 最大間隔 |

### 推奨パターン

| シーン | 推奨 |
|-------|-----|
| インラインアイコンとテキスト | `xs` |
| リストアイテム内 | `sm` |
| カード内コンテンツ | `md` |
| 標準パディング | `lg` |
| フォームフィールド間 | `lg` |
| セクション間 | `xxl` |

---

## 4. 角丸 (RadiusScale)

### アクセス方法

```swift
@Environment(\.radiusScale) var radius

.clipShape(RoundedRectangle(cornerRadius: radius.md))
```

### スケール定義

| トークン | 値 | 用途 |
|---------|---|------|
| `none` | 0pt | シャープな角 |
| `xs` | 2pt | 最小の丸み |
| `sm` | 4pt | 控えめな丸み（入力フィールド） |
| `md` | 8pt | **カード（推奨）** |
| `lg` | 12pt | 大きめの要素（モーダル） |
| `xl` | 16pt | 非常に丸い |
| `xxl` | 20pt | 高い丸み |
| `full` | 9999pt | 完全な円形（FAB、アバター） |

---

## 5. モーション (Motion)

### アクセス方法

```swift
@Environment(\.motion) var motion

.animation(motion.toggle, value: isSelected)
withAnimation(motion.slide) { ... }
```

### マイクロインタラクション（70-110ms）

| トークン | 時間 | 用途 |
|---------|-----|------|
| `quick` | 70ms | ホバー効果 |
| `tap` | 110ms | ボタンプレス |

### 状態変化（150ms）

| トークン | 用途 |
|---------|------|
| `toggle` | 状態切り替え |
| `fadeIn` | 要素の出現 |
| `fadeOut` | 要素の消失 |

### トランジション（240-375ms）

| トークン | 時間 | 用途 |
|---------|-----|------|
| `slide` | 240ms | ページ遷移 |
| `slow` | 300ms | 複雑なレイアウト変更 |
| `slower` | 375ms | ナビゲーション遷移 |

### スプリング

| トークン | Response | Damping | 用途 |
|---------|----------|---------|------|
| `spring` | 0.3s | 0.6 | 自然なバウンス |
| `bounce` | 0.5s | 0.5 | 遊び心のあるバウンス |

### アクセシビリティ

`motion`は自動的に「視差効果を減らす」設定を尊重。

---

## 6. エレベーション (Elevation)

### アクセス方法

```swift
Card(elevation: .level2) { content }
// または
view.elevation(.level2)
```

### レベル定義

| レベル | Blur | Y Offset | 用途 |
|-------|------|----------|------|
| `level0` | 0pt | 0pt | 埋め込み要素 |
| `level1` | 3pt | 1pt | リストアイテム |
| `level2` | 6pt | 2pt | **カード、パネル（標準）** |
| `level3` | 8pt | 4pt | ホバー状態 |
| `level4` | 10pt | 6pt | モーダル、ポップアップ |
| `level5` | 12pt | 8pt | ドロワー、ダイアログ |

---

## 7. グリッドスペーシング (GridSpacing)

### アクセス方法

```swift
AspectGrid(spacing: .md) { ... }
```

### スケール定義

| ケース | 値 | 用途 |
|-------|---|------|
| `xs` | 8pt | アイコングリッド |
| `sm` | 12pt | コンパクトカード |
| `md` | 16pt | **標準グリッド** |
| `lg` | 20pt | ゆったりレイアウト |
| `xl` | 24pt | プレミアムコンテンツ |

---

## トークン組み合わせ例

### 一貫性のあるカード

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing
@Environment(\.radiusScale) var radius

Card(elevation: .level2) {
    VStack(alignment: .leading, spacing: spacing.md) {
        Text("タイトル")
            .typography(.titleMedium)
            .foregroundColor(colors.onSurface)

        Text("説明文")
            .typography(.bodyMedium)
            .foregroundColor(colors.onSurfaceVariant)

        Button("アクション") { }
            .buttonStyle(.primary)
            .buttonSize(.small)
    }
    .padding(spacing.lg)
}
.clipShape(RoundedRectangle(cornerRadius: radius.md))
```

### 状態を持つコンポーネント

```swift
@State private var isSelected = false

Button {
    isSelected.toggle()
} label: {
    Text("選択")
        .typography(.labelLarge)
        .foregroundColor(isSelected ? colors.onPrimary : colors.primary)
        .padding(.horizontal, spacing.lg)
        .padding(.vertical, spacing.md)
        .background(isSelected ? colors.primary : colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: radius.md)
                .stroke(colors.primary, lineWidth: 1)
        )
}
.animation(motion.toggle, value: isSelected)
```
