# SwiftUI 美的方向性ガイド

AI によるUI生成で「それっぽいけど何か違う」を防ぎ、意図のあるデザインを実現するための指針。

---

## 1. 目的

AI が SwiftUI コードを生成する際、技術的に正しいコードでも「美的判断」が欠落すると、どのアプリでも同じような没個性な UI になる。このガイドは、デザイントークンの「何を使うか」ではなく「なぜそう使うか」を定義し、一貫性のある美的方向を持った UI を生成するための判断基準を提供する。

---

## 2. 「AI スロップ」回避ガイド

### AI スロップとは

AI が生成しがちな、技術的には動くが美的判断が欠落した UI パターン。以下の特徴を持つ:

### アンチパターン一覧

| アンチパターン | 症状 | 対策 |
|-------------|------|------|
| **均等配置症候群** | すべての要素が同じ間隔・同じサイズで並ぶ | 視覚的階層を作る。重要な要素を大きく、補助情報を小さく |
| **システムデフォルト依存** | `.font(.title)`, `.foregroundColor(.blue)` などシステム標準のみ | デザイントークンを使う: `.typography(.headlineLarge)`, `colors.primary` |
| **パディング均一病** | すべてに `.padding()` を同じ値で適用 | `spacing.sm`/`md`/`lg`/`xl` を意図的に使い分ける |
| **角丸統一病** | すべての要素に同じ `cornerRadius` | ボタンは `radius.full`、カードは `radius.md`、入力は `radius.sm` |
| **色の単調さ** | primary 色を全箇所に適用 | surface/surfaceVariant で層を作り、primary はアクションのみ |
| **影の過剰使用** | すべての要素に影をつける | 階層が必要な要素だけ。カードは `.level1-2`、モーダルは `.level4` |
| **空白恐怖症** | 余白を埋めようとして情報を詰め込む | 呼吸する余白を確保。`spacing.xxl` 以上のセクション間隔 |
| **アニメーション過多** | あらゆる状態変化にアニメーション追加 | ユーザーアクションへの直接応答のみ。motion トークンで制御 |

### 具体例: Bad vs Good

**Bad - AI スロップの典型例:**

```swift
// 全要素が同じ扱い、階層なし、システムデフォルト
VStack(spacing: 16) {
    Text("タスク一覧")
        .font(.title)
        .bold()
    ForEach(tasks) { task in
        HStack {
            Text(task.title)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
.padding()
```

**Good - 意図のあるデザイン:**

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing
@Environment(\.radiusScale) var radius

VStack(alignment: .leading, spacing: spacing.xxl) {
    // 見出し: 明確な階層のトップ
    Text("タスク一覧")
        .typography(.headlineLarge)
        .foregroundStyle(colors.onBackground)

    // リスト: カードで囲んでグループ感を表現
    Card(elevation: .level1) {
        VStack(spacing: spacing.none) {
            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                HStack(spacing: spacing.md) {
                    // 状態を色で表現
                    Circle()
                        .fill(task.isCompleted ? colors.success : colors.outline)
                        .frame(width: 8, height: 8)

                    Text(task.title)
                        .typography(.bodyLarge)
                        .foregroundStyle(colors.onSurface)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(colors.onSurfaceVariant)
                }
                .padding(.horizontal, spacing.lg)
                .padding(.vertical, spacing.md)

                if index < tasks.count - 1 {
                    Divider()
                        .foregroundStyle(colors.outlineVariant)
                        .padding(.leading, spacing.xl)
                }
            }
        }
    }
}
.padding(.horizontal, spacing.lg)
```

---

## 3. 美的方向性の確立

### デザインパーソナリティ

アプリの性格に応じて6つの方向性から選択する。各方向性はデザイントークンの使い方の傾向を定義する。

### 1. Precision（精密・プロフェッショナル）

金融、ビジネス、生産性ツール向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | `bodyMedium` 中心。Display は控えめに |
| スペーシング | `lg`-`xl` の均一な間隔。密度を保つ |
| 角丸 | `sm`-`md`。シャープさを残す |
| カラー | Monochrome テーマ。primary は1色のみ強調 |
| モーション | `quick`/`tap` のみ。最小限のアニメーション |
| エレベーション | `level1` 中心。フラットに近い |

```swift
// Precision の例: ダッシュボード統計
HStack(spacing: spacing.lg) {
    StatDisplay(value: "¥1,234,567", label: "今月の売上")
    Divider().frame(height: 40)
    StatDisplay(value: "89.2%", label: "達成率")
    Divider().frame(height: 40)
    StatDisplay(value: "156", label: "取引件数")
}
```

### 2. Warmth（温かみ・親しみ）

ヘルスケア、教育、コミュニティ向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | `headlineMedium`-`bodyLarge`。大きめのテキスト |
| スペーシング | `xl`-`xxl` のゆったりした間隔 |
| 角丸 | `lg`-`xl`。柔らかい印象 |
| カラー | Forest/Sunset テーマ。暖色系を活用 |
| モーション | `spring`/`bounce` を積極的に使用 |
| エレベーション | `level1-2`。軽い浮遊感 |

### 3. Sophistication（洗練・高級感）

ファッション、アート、プレミアムサービス向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | Display を大胆に使用。`.fontDesign(.serif)` |
| スペーシング | `xxl`-`xxxl` の贅沢な余白 |
| 角丸 | `none`-`xs`。シャープなエッジ |
| カラー | PurpleHaze/Ocean テーマ。低彩度 |
| モーション | `slow`/`slower` のゆったりした動き |
| エレベーション | `level0`。影なしでフラットに |

### 4. Boldness（大胆・インパクト）

エンタメ、ゲーム、SNS 向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | `displayLarge` を積極的に。コントラスト重視 |
| スペーシング | 極端な差をつける（`xs` と `xxxl` の対比） |
| 角丸 | `full`（完全な円形）を多用 |
| カラー | Sunset テーマ。高彩度、complementary 配色 |
| モーション | `bounce` を特徴的に使用 |
| エレベーション | `level3-4`。立体感を強調 |

### 5. Utility（実用・効率）

開発者ツール、設定画面、管理画面向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | `bodySmall`-`bodyMedium`。情報密度重視 |
| スペーシング | `sm`-`md`。コンパクト |
| 角丸 | `sm`。機能的な最小限 |
| カラー | Default テーマ。セマンティックカラー活用 |
| モーション | `quick`/`tap` のみ |
| エレベーション | `level0-1`。ほぼフラット |

### 6. Data（データ可視化）

分析、フィットネス、金融チャート向け。

| 要素 | 傾向 |
|------|------|
| タイポグラフィ | 数値は `displaySmall`-`headlineLarge`。ラベルは `labelSmall` |
| スペーシング | グリッド準拠。`GridSpacing` を活用 |
| 角丸 | `md` 基本。グラフ要素は `xs` |
| カラー | Ocean テーマ。semantic colors で状態表現 |
| モーション | `slide` でチャートトランジション |
| エレベーション | カードのみ `level1`。それ以外はフラット |

---

## 4. Apple HIG の主要原則

### Clarity（明瞭さ）

テキストは読みやすく、アイコンは正確で、装飾は控えめに。

```swift
// Good: 明確な階層
VStack(alignment: .leading, spacing: spacing.sm) {
    Text("通知設定")
        .typography(.titleMedium)
        .foregroundStyle(colors.onSurface)
    Text("新しいメッセージの通知を管理します")
        .typography(.bodyMedium)
        .foregroundStyle(colors.onSurfaceVariant)
}

// Bad: 階層が不明確
VStack {
    Text("通知設定").font(.body).bold()
    Text("新しいメッセージの通知を管理します").font(.body)
}
```

### Deference（コンテンツ優先）

UI はコンテンツを支え、競合しない。

```swift
// Good: コンテンツが主役
ScrollView {
    LazyVStack(spacing: spacing.sm) {
        ForEach(photos) { photo in
            AsyncImage(url: photo.url)
                .aspectRatio(contentMode: .fill)
        }
    }
}
.background(colors.background)  // 控えめな背景

// Bad: UIが目立ちすぎる
ScrollView {
    LazyVStack(spacing: 20) {
        ForEach(photos) { photo in
            AsyncImage(url: photo.url)
                .padding()
                .background(Color.blue.opacity(0.1))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 10)
        }
    }
}
```

### Depth（奥行き）

レイヤーとモーションで空間的な関係を表現する。

```swift
// シートの階層表現
.sheet(isPresented: $showDetail) {
    DetailView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// カードの浮き具合で重要度を表現
Card(elevation: .level1) { regularContent }  // 通常
Card(elevation: .level3) { importantContent } // 強調
```

### iOS プラットフォーム規約

| パターン | 推奨実装 |
|---------|---------|
| ナビゲーション | `NavigationStack` + `.navigationTitle()` |
| タブ | `TabView` + SF Symbols |
| モーダル | `.sheet()` / `.fullScreenCover()` |
| アクションシート | `.confirmationDialog()` |
| コンテキストメニュー | `.contextMenu()` |
| 検索 | `.searchable()` |
| リフレッシュ | `.refreshable()` |
| スワイプアクション | `.swipeActions()` |

**HIG に従うべき場面:**
- ナビゲーション構造（TabView、NavigationStack）
- システム連携（Share Sheet、通知）
- アクセシビリティ（Dynamic Type、VoiceOver）
- セーフエリアの扱い

**創造性を発揮できる場面:**
- カードやセルの内部レイアウト
- カスタムトランジション
- データ可視化
- ブランド表現（色、タイポグラフィ）

---

## 5. SwiftUI 実装パターン

### タイポグラフィ階層

1画面に使うタイポグラフィスタイルは3-4種類に絞る。

```swift
// 推奨: 明確な階層（3段階）
VStack(alignment: .leading, spacing: spacing.md) {
    Text("セクションタイトル")           // Level 1: 見出し
        .typography(.headlineSmall)
        .foregroundStyle(colors.onBackground)

    Text("ここに本文テキストが入ります")   // Level 2: 本文
        .typography(.bodyLarge)
        .foregroundStyle(colors.onSurface)

    Text("2024年1月15日")              // Level 3: 補助情報
        .typography(.labelMedium)
        .foregroundStyle(colors.onSurfaceVariant)
}
```

### カラー使用パターン

```
背景の層:
┌─────────────────────────────────────┐
│  background (最背面)                  │
│  ┌──────────────────────────────────┐│
│  │  surface (カード)                 ││
│  │  ┌──────────────────────────────┐││
│  │  │  surfaceVariant (入力欄)     │││
│  │  │  ┌──────────────────────────┐│││
│  │  │  │  primaryContainer (強調) ││││
│  │  │  └──────────────────────────┘│││
│  │  └──────────────────────────────┘││
│  └──────────────────────────────────┘│
└─────────────────────────────────────┘

テキストカラーの原則:
- 背景が background → onBackground
- 背景が surface   → onSurface
- 背景が primary   → onPrimary
- 常に対応する on~ カラーを使う
```

**primary の使用ルール:**
- CTA ボタンの背景（1画面に1つが理想）
- 選択状態の表現
- リンクテキスト
- アクティブなアイコン

**使わない方がよい場面:**
- 装飾的な背景色 → `surfaceVariant` を使う
- 全アイコンの着色 → `onSurfaceVariant` を使う
- ボーダー → `outline` / `outlineVariant` を使う

### スペーシングとリズム

```
コンポーネント内部:    xs (4pt) - sm (8pt)
要素間:              md (12pt) - lg (16pt)
セクション間:         xl (24pt) - xxl (32pt)
ページ余白:          lg (16pt) - xl (24pt)
```

```swift
// 良いリズムの例
ScrollView {
    VStack(spacing: spacing.xxl) {        // セクション間: 32pt

        // セクション1
        VStack(alignment: .leading, spacing: spacing.md) {  // 要素間: 12pt
            Text("最近のアクティビティ")
                .typography(.titleMedium)
            Card {
                VStack(spacing: spacing.sm) {  // コンポーネント内: 8pt
                    ActivityRow(...)
                    ActivityRow(...)
                }
            }
        }

        // セクション2
        VStack(alignment: .leading, spacing: spacing.md) {
            Text("おすすめ")
                .typography(.titleMedium)
            // ...
        }
    }
    .padding(.horizontal, spacing.lg)     // ページ余白: 16pt
    .padding(.vertical, spacing.xl)
}
```

### モーション・アニメーション指針

**アニメーションをつけるべき場面:**
- ユーザーの直接操作への応答（タップ、スワイプ）
- 状態の切り替え（選択、展開/折りたたみ）
- コンテンツの出入り（リスト項目の追加/削除）

**アニメーションをつけない方がよい場面:**
- 初期描画
- データの更新（値の変化のみ）
- スクロール中の要素

```swift
// 適切なモーション使用例
@Environment(\.motion) var motion

// ボタンフィードバック: tap (110ms)
Button { action() } label: { ... }
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .animate(motion.tap, value: isPressed)

// 状態トグル: toggle (150ms)
.background(isSelected ? colors.primary : colors.surface)
.animate(motion.toggle, value: isSelected)

// パネル展開: slow (300ms)
.frame(height: isExpanded ? expandedHeight : collapsedHeight)
.animate(motion.slow, value: isExpanded)

// リスト項目の挿入: spring
.transition(.asymmetric(
    insertion: .scale.combined(with: .opacity),
    removal: .opacity
))
// withAnimation(motion.spring) { items.append(newItem) }
```

### SF Symbols 使用パターン

```swift
// Hierarchical: 単色で奥行き表現
Image(systemName: "folder.fill.badge.plus")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(colors.primary)

// Palette: 2-3色で意味の区別
Image(systemName: "person.crop.circle.badge.checkmark")
    .symbolRenderingMode(.palette)
    .foregroundStyle(colors.primary, colors.success)

// Multicolor: システム定義の自然な色
Image(systemName: "cloud.sun.rain.fill")
    .symbolRenderingMode(.multicolor)

// サイズの一貫性
Image(systemName: "gear")
    .font(.system(size: 20))              // 本文横のアイコン
Image(systemName: "plus")
    .font(.system(size: 24, weight: .semibold))  // FAB・ボタン内
Image(systemName: "house")
    .font(.system(size: 22))              // TabBar アイコン
```

---

## 6. 美的チェックリスト

UI を最終確認する際のチェック項目:

### 階層と構造
- [ ] 視線の流れが明確か（最も重要な情報が最初に目に入るか）
- [ ] タイポグラフィは3-4段階に収まっているか
- [ ] 1画面に Primary ボタンは1つだけか

### 色とコントラスト
- [ ] `on~` カラーを正しく対応させているか
- [ ] `primary` を装飾目的に使っていないか
- [ ] ダークモードで視認性を確認したか

### スペーシング
- [ ] セクション間 > 要素間 > コンポーネント内 の順序が守られているか
- [ ] 余白に「呼吸する空間」があるか
- [ ] 詰め込みすぎていないか

### モーション
- [ ] アニメーションはユーザーアクションへの応答のみか
- [ ] `.animate()` モディファイアでアクセシビリティ対応しているか
- [ ] motion トークンの適切なカテゴリを選んでいるか

### プラットフォーム
- [ ] iOS 標準のナビゲーションパターンを使っているか
- [ ] セーフエリアを適切に扱っているか
- [ ] Dynamic Type に対応しているか（`.typography()` 使用で自動対応）

### デザインシステム準拠
- [ ] ハードコードされた色・サイズ・余白がないか
- [ ] すべてのカラーが `@Environment(\.colorPalette)` 経由か
- [ ] すべてのスペーシングが `@Environment(\.spacingScale)` 経由か
- [ ] ThemeProvider でラップされているか
