# AspectGrid パターン

アスペクト比を統一したレスポンシブグリッドレイアウト。

---

## 特徴

- 全アイテムのアスペクト比を統一
- 画面幅に応じた自動カラム数調整
- minItemWidth / maxItemWidth によるサイズ制御
- GridSpacing トークンによるガター制御

---

## パラメータ

| パラメータ | 型 | 説明 |
|-----------|---|------|
| `minItemWidth` | `CGFloat` | アイテムの最小幅 |
| `maxItemWidth` | `CGFloat?` | アイテムの最大幅（オプション） |
| `itemAspectRatio` | `CGFloat` | アイテムのアスペクト比（幅/高さ） |
| `spacing` | `GridSpacing` | グリッド間隔 |
| `content` | `@ViewBuilder` | グリッドコンテンツ |

---

## GridSpacing

| ケース | 値 | 用途 |
|-------|---|------|
| `.xs` | 8pt | アイコングリッド、タグ |
| `.sm` | 12pt | コンパクトカード |
| `.md` | 16pt | **標準グリッド** |
| `.lg` | 20pt | ゆったりレイアウト |
| `.xl` | 24pt | プレミアムコンテンツ |

---

## 基本使用法

```swift
import DesignSystem

AspectGrid(
    minItemWidth: 140,
    maxItemWidth: 200,
    itemAspectRatio: 1.0,  // 正方形
    spacing: .md
) {
    ForEach(items) { item in
        ItemView(item)
    }
}
```

---

## 一般的なアスペクト比

| 比率 | 値 | 用途 |
|-----|---|------|
| 正方形 | `1.0` | プロフィール、商品サムネイル |
| ポートレート | `0.75` (3:4) | 人物写真、カード |
| ランドスケープ | `1.33` (4:3) | 風景写真 |
| ワイド | `1.78` (16:9) | 動画サムネイル |
| 縦長カード | `0.67` (2:3) | 書籍、ポスター |

---

## 商品グリッド

```swift
AspectGrid(
    minItemWidth: 160,
    maxItemWidth: 200,
    itemAspectRatio: 1.2,  // やや縦長
    spacing: .md
) {
    ForEach(products) { product in
        Card(elevation: .level1) {
            VStack(alignment: .leading, spacing: 0) {
                // 商品画像
                Image(product.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()

                // 商品情報
                VStack(alignment: .leading, spacing: spacing.xs) {
                    Text(product.name)
                        .typography(.titleSmall)
                        .lineLimit(2)

                    Text("¥\(product.price)")
                        .typography(.labelLarge)
                        .foregroundColor(colors.primary)
                }
                .padding(spacing.sm)
            }
        }
    }
}
.padding(.horizontal, spacing.lg)
```

---

## フォトギャラリー

```swift
AspectGrid(
    minItemWidth: 100,
    itemAspectRatio: 1.0,
    spacing: .xs
) {
    ForEach(photos) { photo in
        Image(photo.name)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .onTapGesture {
                selectedPhoto = photo
            }
    }
}
```

---

## アイコングリッド

```swift
AspectGrid(
    minItemWidth: 80,
    maxItemWidth: 100,
    itemAspectRatio: 1.0,
    spacing: .xs
) {
    ForEach(icons, id: \.self) { icon in
        Button {
            selectedIcon = icon
        } label: {
            VStack(spacing: spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)

                Text(icon)
                    .typography(.labelSmall)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                selectedIcon == icon
                    ? colors.primaryContainer
                    : colors.surface
            )
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
        }
    }
}
```

---

## カテゴリグリッド

```swift
AspectGrid(
    minItemWidth: 140,
    itemAspectRatio: 1.0,
    spacing: .md
) {
    ForEach(categories) { category in
        NavigationLink(value: category) {
            ZStack {
                // 背景画像
                Image(category.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)

                // オーバーレイ
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // ラベル
                VStack {
                    Spacer()
                    Text(category.name)
                        .typography(.titleMedium)
                        .foregroundColor(.white)
                        .padding(spacing.md)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: radius.md))
        }
    }
}
```

---

## 動画サムネイルグリッド

```swift
AspectGrid(
    minItemWidth: 280,
    itemAspectRatio: 16/9,  // ワイド
    spacing: .lg
) {
    ForEach(videos) { video in
        Card(elevation: .level1) {
            VStack(alignment: .leading, spacing: 0) {
                // サムネイル
                ZStack {
                    Image(video.thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)

                    // 再生ボタン
                    Image(systemName: "play.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)

                    // 再生時間
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text(video.duration)
                                .typography(.labelSmall)
                                .foregroundColor(.white)
                                .padding(.horizontal, spacing.xs)
                                .padding(.vertical, spacing.xxs)
                                .background(Color.black.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: radius.xs))
                                .padding(spacing.xs)
                        }
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)

                // タイトル
                Text(video.title)
                    .typography(.titleSmall)
                    .lineLimit(2)
                    .padding(spacing.sm)
            }
        }
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: AspectGridで統一されたレイアウト
AspectGrid(
    minItemWidth: 160,
    itemAspectRatio: 1.0,
    spacing: .md
) {
    ForEach(items) { ItemView($0) }
}

// ❌ Bad: LazyVGridで手動計算
LazyVGrid(columns: [
    GridItem(.adaptive(minimum: 160))
]) {
    ForEach(items) { item in
        ItemView(item)
            .aspectRatio(1.0, contentMode: .fit) // 各アイテムで指定が必要
    }
}
```
