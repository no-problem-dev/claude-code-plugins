# ImagePicker コンポーネント

カメラまたはフォトライブラリから画像を選択するピッカー。View Extension 形式で提供（iOS 専用: `#if canImport(UIKit)`）。

---

## 特徴

- カメラとフォトライブラリの統合（confirmationDialog 自動表示）
- 包括的な権限処理（カメラ / フォトライブラリ）を内部で自動処理
- JPEG 形式の `Data?` として返却
- `ByteSize` による最大サイズ指定（再帰的に圧縮品質を下げる）
- iPadでのカメラ有無チェック

---

## API

```swift
// View Extension（iOS 専用）
func imagePicker(
    isPresented: Binding<Bool>,
    selectedImageData: Binding<Data?>,  // JPEG Data
    maxSize: ByteSize? = nil,           // 例: 1.mb, 500.kb
    onCompressionError: ((Error) -> Void)? = nil
) -> some View
```

---

## パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|-----|-----------|------|
| `isPresented` | `Binding<Bool>` | - | シート表示状態 |
| `selectedImageData` | `Binding<Data?>` | - | 選択画像の JPEG バイナリ |
| `maxSize` | `ByteSize?` | `nil` | 最大ファイルサイズ（例: `1.mb`, `500.kb`） |
| `onCompressionError` | `((Error) -> Void)?` | `nil` | 圧縮エラー時のコールバック |

### 重要

- **返却型は `Data?`（JPEG バイナリ）であって `UIImage?` ではない**
- 表示に使う場合は `UIImage(data:)` で変換する
- Info.plist に以下のキーが必要:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`

---

## 基本使用法

```swift
import DesignSystem

@State private var imageData: Data? = nil
@State private var showPicker = false

Button {
    showPicker = true
} label: {
    if let data = imageData, let uiImage = UIImage(data: data) {
        Image(uiImage: uiImage)
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
.imagePicker(
    isPresented: $showPicker,
    selectedImageData: $imageData
)
```

---

## 応用パターン

### サイズ制限付きプロフィール画像

```swift
@Environment(\.colorPalette) var colors
@Environment(\.spacingScale) var spacing
@Environment(\.radiusScale) var radius

@State private var profileImageData: Data? = nil
@State private var showPicker = false

VStack(spacing: spacing.lg) {
    // アバター表示
    ZStack(alignment: .bottomTrailing) {
        if let data = profileImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
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

    // 編集ボタン（1MB 上限）
    Button("写真を変更") {
        showPicker = true
    }
    .buttonStyle(.secondary)
    .imagePicker(
        isPresented: $showPicker,
        selectedImageData: $profileImageData,
        maxSize: 1.mb
    )
}
```

### カメラボタン付きアバター

```swift
@State private var avatarData: Data? = nil
@State private var showPicker = false

ZStack(alignment: .bottomTrailing) {
    // アバター
    Group {
        if let data = avatarData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
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
    Button {
        showPicker = true
    } label: {
        Image(systemName: "camera.fill")
            .font(.caption)
            .foregroundColor(colors.onPrimary)
            .padding(spacing.xs)
            .background(colors.primary)
            .clipShape(Circle())
    }
    .imagePicker(
        isPresented: $showPicker,
        selectedImageData: $avatarData,
        maxSize: 500.kb
    )
}
```

### 圧縮エラーハンドリング付き

```swift
@State private var imageData: Data? = nil
@State private var showPicker = false
@State private var showError = false
@State private var errorMessage = ""

Button("画像を選択") {
    showPicker = true
}
.imagePicker(
    isPresented: $showPicker,
    selectedImageData: $imageData,
    maxSize: 500.kb,
    onCompressionError: { error in
        errorMessage = error.localizedDescription
        showError = true
    }
)
.alert("圧縮エラー", isPresented: $showError) {
    Button("OK") { }
} message: {
    Text(errorMessage)
}
```

### カバー画像選択

```swift
@State private var coverImageData: Data? = nil
@State private var showPicker = false

VStack(spacing: 0) {
    // カバー画像エリア
    ZStack {
        if let data = coverImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
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
            showPicker = true
        } label: {
            Label("カバーを変更", systemImage: "photo")
                .typography(.labelMedium)
                .foregroundColor(colors.onSurface)
                .padding(.horizontal, spacing.md)
                .padding(.vertical, spacing.sm)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .imagePicker(
            isPresented: $showPicker,
            selectedImageData: $coverImageData
        )
        , alignment: .bottomTrailing
    )
    .padding(spacing.md)
}
```

### フォーム内での使用

```swift
struct ProductForm: View {
    @Environment(\.colorPalette) var colors
    @Environment(\.spacingScale) var spacing
    @Environment(\.radiusScale) var radius

    @State private var productImageData: Data? = nil
    @State private var productName = ""
    @State private var productDescription = ""
    @State private var showPicker = false

    var body: some View {
        Form {
            Section("商品画像") {
                HStack {
                    Spacer()

                    Button {
                        showPicker = true
                    } label: {
                        if let data = productImageData,
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
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
                    .imagePicker(
                        isPresented: $showPicker,
                        selectedImageData: $productImageData,
                        maxSize: 1.mb
                    )

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

ImagePicker は内部で以下を自動処理します:
- カメラ権限のリクエストと状態確認
- フォトライブラリ権限のリクエスト
- iPad でのカメラ有無チェック
- 権限拒否時の適切なフィードバック
- カメラ / フォトライブラリの選択 confirmationDialog

Info.plist に以下の必須キーを追加してください:
- `NSCameraUsageDescription` - カメラ使用理由
- `NSPhotoLibraryUsageDescription` - フォトライブラリ使用理由

---

## Good / Bad パターン

```swift
// ✅ Good: imagePicker View Extension を使用し、isPresented で制御
@State private var imageData: Data? = nil
@State private var showPicker = false

Button("画像を選択") { showPicker = true }
    .imagePicker(
        isPresented: $showPicker,
        selectedImageData: $imageData
    )

// ✅ Good: selectedImageData は Data?（JPEG バイナリ）を使用
@State private var imageData: Data? = nil

// ✅ Good: UIImage(data:) で表示用に変換
if let data = imageData, let uiImage = UIImage(data: data) {
    Image(uiImage: uiImage)
}

// ✅ Good: maxSize で圧縮上限を指定
.imagePicker(
    isPresented: $showPicker,
    selectedImageData: $imageData,
    maxSize: 1.mb
)

// ❌ Bad: selectedImageData に UIImage? を使用
@State private var selectedImage: UIImage? = nil

// ❌ Bad: PHPicker を直接使用（権限処理なし）
.sheet(isPresented: $showPicker) {
    PHPickerViewController(...)
}

// ❌ Bad: isPresented を省略して直接バインディングだけ渡す
.imagePicker($selectedImage)
```
