# SectionCard パターン

タイトル + カードの組み合わせレイアウト。設定画面やダッシュボードに最適。

---

## 特徴

- タイトルとカードの一貫したスペーシング
- エレベーション指定可能
- 内部コンテンツは自由にレイアウト

---

## パラメータ

| パラメータ | 型 | デフォルト | 説明 |
|-----------|---|----------|------|
| `title` | `String` | - | セクションタイトル |
| `elevation` | `Elevation` | `.level2` | カードのエレベーション |
| `content` | `@ViewBuilder` | - | カード内コンテンツ |

---

## 基本使用法

```swift
import DesignSystem

@Environment(\.spacingScale) var spacing

SectionCard(title: "基本設定", elevation: .level2) {
    VStack(spacing: spacing.md) {
        Toggle("通知", isOn: $notificationEnabled)
        Toggle("ダークモード", isOn: $darkModeEnabled)
    }
}
```

---

## 設定画面

```swift
@Environment(\.spacingScale) var spacing

ScrollView {
    VStack(spacing: spacing.xl) {
        // アカウント設定
        SectionCard(title: "アカウント") {
            VStack(spacing: spacing.md) {
                NavigationLink("プロフィール編集") {
                    ProfileEditView()
                }
                NavigationLink("メールアドレス変更") {
                    EmailChangeView()
                }
                NavigationLink("パスワード変更") {
                    PasswordChangeView()
                }
            }
        }

        // 通知設定
        SectionCard(title: "通知") {
            VStack(spacing: spacing.md) {
                Toggle("プッシュ通知", isOn: $pushEnabled)
                Toggle("メール通知", isOn: $emailEnabled)
                Toggle("SMS通知", isOn: $smsEnabled)
            }
        }

        // プライバシー設定
        SectionCard(title: "プライバシー") {
            VStack(spacing: spacing.md) {
                Toggle("位置情報を共有", isOn: $locationSharing)
                Toggle("アクティビティを公開", isOn: $activityPublic)
            }
        }
    }
    .padding(spacing.lg)
}
```

---

## ダッシュボード

```swift
ScrollView {
    VStack(spacing: spacing.xl) {
        // 概要
        SectionCard(title: "今月の概要") {
            HStack(spacing: spacing.lg) {
                StatView(title: "売上", value: "¥1,234,567")
                StatView(title: "注文数", value: "123")
                StatView(title: "顧客数", value: "45")
            }
        }

        // 最近の注文
        SectionCard(title: "最近の注文") {
            VStack(spacing: spacing.sm) {
                ForEach(recentOrders.prefix(5)) { order in
                    OrderRow(order)
                    if order.id != recentOrders.prefix(5).last?.id {
                        Divider()
                    }
                }
            }
        }

        // 人気商品
        SectionCard(title: "人気商品") {
            AspectGrid(
                minItemWidth: 100,
                itemAspectRatio: 1.0,
                spacing: .sm
            ) {
                ForEach(popularProducts.prefix(4)) { product in
                    ProductThumbnail(product)
                }
            }
        }
    }
    .padding(spacing.lg)
}
```

---

## フォーム

```swift
ScrollView {
    VStack(spacing: spacing.xl) {
        // 基本情報
        SectionCard(title: "基本情報") {
            VStack(spacing: spacing.md) {
                LabeledContent("名前") {
                    TextField("名前を入力", text: $name)
                }
                LabeledContent("メール") {
                    TextField("メールアドレス", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }
                LabeledContent("電話番号") {
                    TextField("電話番号", text: $phone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                }
            }
        }

        // 住所
        SectionCard(title: "住所") {
            VStack(spacing: spacing.md) {
                LabeledContent("郵便番号") {
                    TextField("000-0000", text: $postalCode)
                        .keyboardType(.numberPad)
                }
                LabeledContent("都道府県") {
                    Picker("都道府県", selection: $prefecture) {
                        ForEach(prefectures, id: \.self) { Text($0) }
                    }
                }
                LabeledContent("市区町村") {
                    TextField("市区町村", text: $city)
                }
                LabeledContent("番地") {
                    TextField("番地", text: $address)
                }
            }
        }
    }
    .padding(spacing.lg)
}
```

---

## プロフィール画面

```swift
ScrollView {
    VStack(spacing: spacing.xl) {
        // プロフィールヘッダー（カードなし）
        VStack(spacing: spacing.md) {
            Image("avatar")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())

            Text("山田太郎")
                .typography(.headlineMedium)

            Text("@yamada_taro")
                .typography(.bodyMedium)
                .foregroundColor(colors.onSurfaceVariant)
        }
        .padding(.vertical, spacing.lg)

        // 統計
        SectionCard(title: "アクティビティ") {
            HStack(spacing: spacing.xl) {
                VStack {
                    Text("123")
                        .typography(.headlineLarge)
                    Text("投稿")
                        .typography(.labelMedium)
                        .foregroundColor(colors.onSurfaceVariant)
                }
                VStack {
                    Text("456")
                        .typography(.headlineLarge)
                    Text("フォロワー")
                        .typography(.labelMedium)
                        .foregroundColor(colors.onSurfaceVariant)
                }
                VStack {
                    Text("78")
                        .typography(.headlineLarge)
                    Text("フォロー中")
                        .typography(.labelMedium)
                        .foregroundColor(colors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity)
        }

        // 自己紹介
        SectionCard(title: "自己紹介") {
            Text("iOSエンジニア。SwiftUIが好きです。")
                .typography(.bodyMedium)
        }
    }
    .padding(spacing.lg)
}
```

---

## エレベーションの使い分け

```swift
// フラット（リスト内）
SectionCard(title: "設定", elevation: .level0) {
    // ...
}

// 標準
SectionCard(title: "設定", elevation: .level2) {
    // ...
}

// 強調
SectionCard(title: "重要な設定", elevation: .level3) {
    // ...
}
```

---

## Good / Bad パターン

```swift
// ✅ Good: SectionCardで統一されたレイアウト
SectionCard(title: "設定") {
    VStack(spacing: spacing.md) {
        Toggle("通知", isOn: $enabled)
    }
}

// ❌ Bad: 手動でタイトル+カードを組み立て
VStack(alignment: .leading) {
    Text("設定")
        .font(.headline)
        .padding(.horizontal, 16)

    RoundedRectangle(cornerRadius: 8)
        .fill(Color.white)
        .shadow(radius: 2)
        .overlay(
            VStack {
                Toggle("通知", isOn: $enabled)
            }
            .padding()
        )
}
```
