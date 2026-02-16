# VideoPlayerView コンポーネント

動画再生ビュー。AVPlayerViewController ベースで、メタデータ表示やアクション（共有・保存）をサポート。iOS 専用。

---

## 特徴

- `Data` または `URL` からの初期化
- AVPlayerViewController ベースの再生
- メタデータ表示（尺、解像度、ファイルサイズ）
- アクションボタン（再生/一時停止、共有、カメラロール保存）
- 内部で Snackbar, Chip コンポーネントを使用
- オーディオセッション自動設定（`.playback` カテゴリ）
- 一時ファイルの自動クリーンアップ

## 初期化

| イニシャライザ | 用途 |
|-------------|------|
| `init(data: Data)` | メモリ上の動画データから再生 |
| `init(url: URL)` | ローカル/リモート URL から再生 |

## アクション

| アクション | 説明 |
|-----------|------|
| `.play` | 再生/一時停止トグル |
| `.share` | 共有シートを表示 |
| `.saveToPhotos` | カメラロールに保存 |

---

## 基本使用法

```swift
import DesignSystem

// URL から再生
VideoPlayerView(url: videoURL)

// Data から再生
VideoPlayerView(data: videoData)
```

---

## メタデータ表示

```swift
// メタデータ（尺、解像度、ファイルサイズ）を表示
VideoPlayerView(url: videoURL)
    .showMetadata(true)
```

---

## アクションボタン付き

```swift
// 再生 + 共有 + 保存
VideoPlayerView(url: videoURL)
    .showMetadata(true)
    .showActions([.play, .share, .saveToPhotos])

// 再生のみ
VideoPlayerView(url: videoURL)
    .showActions([.play])

// 共有と保存のみ
VideoPlayerView(url: videoURL)
    .showActions([.share, .saveToPhotos])
```

---

## 動画プレビュー画面

```swift
@Environment(\.spacingScale) var spacing
@Environment(\.colorPalette) var colors

struct VideoPreviewScreen: View {
    let videoURL: URL
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            // 動画プレーヤー
            VideoPlayerView(url: videoURL)
                .showMetadata(true)
                .showActions([.play, .share, .saveToPhotos])
                .frame(maxHeight: 300)

            // 動画情報
            VStack(alignment: .leading, spacing: spacing.sm) {
                Text(title)
                    .typography(.titleLarge)

                HStack(spacing: spacing.sm) {
                    Chip("動画")
                        .chipStyle(.filled)
                        .chipSize(.small)
                    Chip("録画済み")
                        .chipStyle(.outlined)
                        .chipSize(.small)
                }
            }
            .padding(spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
    }
}
```

---

## データからの動画再生

```swift
struct RecordedVideoView: View {
    let recordedData: Data

    var body: some View {
        VideoPlayerView(data: recordedData)
            .showMetadata(true)
            .showActions([.play, .saveToPhotos])
    }
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: VideoPlayerView コンポーネントを使用
VideoPlayerView(url: videoURL)
    .showMetadata(true)
    .showActions([.play, .share, .saveToPhotos])

// ❌ Bad: AVPlayerViewController を直接使用
struct PlayerWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = AVPlayer(url: url)
        return controller
    }
    func updateUIViewController(_ controller: AVPlayerViewController, context: Context) {}
}

// ✅ Good: モディファイアでアクションを設定
VideoPlayerView(url: videoURL)
    .showActions([.share, .saveToPhotos])

// ❌ Bad: 外部に独自のアクションボタンを配置
VStack {
    VideoPlayerView(url: videoURL)
    HStack {
        Button("共有") { shareVideo() }
        Button("保存") { saveVideo() }
    }
}
```
