# ImagePicker コンポーネント

カメラまたはフォトライブラリから画像を選択。ViewModifier形式で提供。

---

## 特徴

- カメラとフォトライブラリの統合
- 包括的な権限処理（`.addOnly`）
- デバイス機能チェック（iPadカメラ対応）
- 画像圧縮（再帰的な品質調整）
- JPEG形式出力

---

## 基本使用法

```swift
import DesignSystem

@State private var selectedImage: UIImage?

Button {
    // ピッカーが表示される
} label: {
    if let image = selectedImage {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    } else {
        Circle()
            .fill(colors.surfaceVariant)
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "camera")
                    .font(.title)
                    .foregroundColor(colors.onSurfaceVariant)
            )
    }
}
.imagePicker($selectedImage)
```

---

## プロフィール画像編集

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing
@Environment(\.radiusScale) var radius

@State private var profileImage: UIImage?

VStack(spacing: spacing.lg) {
    // アバター表示
    ZStack(alignment: .bottomTrailing) {
        if let image = profileImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundColor(colors.onSurfaceVariant)
        }
    }
    .frame(width: 120, height: 120)
    .background(colors.surfaceVariant)
    .clipShape(Circle())
    .overlay(
        Circle()
            .stroke(colors.outline, lineWidth: 2)
    )

    // 編集ボタン
    Button("写真を変更") { }
        .buttonStyle(.secondary)
        .imagePicker($profileImage)
}
```

---

## カメラボタン付きアバター

```swift
@State private var avatar: UIImage?

ZStack(alignment: .bottomTrailing) {
    // アバター
    Group {
        if let image = avatar {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image(systemName: "person.fill")
                .font(.largeTitle)
                .foregroundColor(colors.onSurfaceVariant)
        }
    }
    .frame(width: 100, height: 100)
    .background(colors.surfaceVariant)
    .clipShape(Circle())

    // カメラボタン
    Button { } label: {
        Image(systemName: "camera.fill")
            .font(.caption)
            .foregroundColor(colors.onPrimary)
            .padding(spacing.xs)
            .background(colors.primary)
            .clipShape(Circle())
    }
    .imagePicker($avatar)
}
```

---

## カバー画像選択

```swift
@State private var coverImage: UIImage?

VStack(spacing: 0) {
    // カバー画像エリア
    ZStack {
        if let image = coverImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Rectangle()
                .fill(colors.surfaceVariant)
        }
    }
    .frame(height: 200)
    .clipped()
    .overlay(
        Button {
            // ピッカー表示
        } label: {
            Label("カバーを変更", systemImage: "photo")
                .typography(.labelMedium)
                .foregroundColor(colors.onSurface)
                .padding(.horizontal, spacing.md)
                .padding(.vertical, spacing.sm)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .imagePicker($coverImage)
        , alignment: .bottomTrailing
    )
    .padding(spacing.md)

    // 他のコンテンツ
    // ...
}
```

---

## フォーム内での使用

```swift
struct ProductForm: View {
    @State private var productImage: UIImage?
    @State private var productName = ""
    @State private var productDescription = ""

    var body: some View {
        Form {
            Section("商品画像") {
                HStack {
                    Spacer()

                    Button { } label: {
                        if let image = productImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: radius.md))
                        } else {
                            VStack(spacing: spacing.sm) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.largeTitle)
                                Text("画像を追加")
                                    .typography(.labelMedium)
                            }
                            .foregroundColor(colors.onSurfaceVariant)
                            .frame(width: 150, height: 150)
                            .background(colors.surfaceVariant)
                            .clipShape(RoundedRectangle(cornerRadius: radius.md))
                        }
                    }
                    .imagePicker($productImage)

                    Spacer()
                }
            }

            Section("商品情報") {
                TextField("商品名", text: $productName)
                TextField("説明", text: $productDescription)
            }
        }
    }
}
```

---

## 権限処理について

ImagePickerは内部で以下を自動処理します：
- カメラ権限のリクエストと状態確認
- フォトライブラリ権限（`.addOnly`）のリクエスト
- iPadでのカメラ有無チェック
- 権限拒否時の適切なフィードバック

---

## Good / Bad パターン

```swift
// ✅ Good: imagePickerモディファイアを使用
Button("画像を選択") { }
    .imagePicker($selectedImage)

// ❌ Bad: PHPickerを直接使用（権限処理なし）
.sheet(isPresented: $showPicker) {
    PHPickerViewController(...)
}
```
