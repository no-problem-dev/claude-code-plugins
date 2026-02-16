# DSTextField コンポーネント

デザインシステム統合のテキスト入力フィールド。ラベル、バリデーション、アイコン装飾を備えた一貫性のある入力 UI を提供。

---

## スタイル

| スタイル | 視覚的特徴 | 用途 |
|---------|-----------|------|
| `.outlined` | 枠線のみ（デフォルト） | フォーム全般 |
| `.filled` | 背景色あり | 密集したレイアウト |

## 特徴

- フローティングラベル（フォーカス時にラベルが上部へ移動）
- 先頭/末尾アイコン（SF Symbols）
- エラー状態（赤色ボーダー + エラーメッセージ）
- サポートテキスト（入力のヒント表示）
- フォーカス時のボーダー変化アニメーション

---

## 基本使用法

```swift
import DesignSystem

@State private var name = ""

// シンプルなテキストフィールド
DSTextField("名前", text: $name, placeholder: "山田太郎")

// スタイル指定
DSTextField("名前", text: $name, placeholder: "山田太郎", style: .filled)
```

---

## アイコン付き

```swift
@State private var email = ""
@State private var search = ""

// 先頭アイコン
DSTextField(
    "メールアドレス",
    text: $email,
    placeholder: "example@email.com",
    leadingIcon: "envelope"
)

// 先頭 + 末尾アイコン
DSTextField(
    "検索",
    text: $search,
    placeholder: "キーワードを入力",
    leadingIcon: "magnifyingglass",
    trailingIcon: "mic"
)
```

---

## バリデーション・エラー表示

```swift
@State private var email = ""
@State private var emailError: String? = nil

DSTextField(
    "メールアドレス",
    text: $email,
    placeholder: "example@email.com",
    error: emailError,
    leadingIcon: "envelope"
)
.onChange(of: email) { _, newValue in
    if newValue.isEmpty {
        emailError = "メールアドレスは必須です"
    } else if !newValue.contains("@") {
        emailError = "有効なメールアドレスを入力してください"
    } else {
        emailError = nil
    }
}
```

---

## サポートテキスト

```swift
@State private var password = ""

DSTextField(
    "パスワード",
    text: $password,
    placeholder: "8文字以上",
    supportingText: "英数字を組み合わせてください",
    leadingIcon: "lock"
)
```

---

## フォームレイアウト

```swift
@Environment(\.spacingScale) var spacing

@State private var username = ""
@State private var email = ""
@State private var phone = ""

VStack(spacing: spacing.lg) {
    DSTextField(
        "ユーザー名",
        text: $username,
        placeholder: "user123",
        leadingIcon: "person"
    )

    DSTextField(
        "メールアドレス",
        text: $email,
        placeholder: "example@email.com",
        leadingIcon: "envelope"
    )

    DSTextField(
        "電話番号",
        text: $phone,
        placeholder: "090-1234-5678",
        supportingText: "ハイフンなしでも入力可能です",
        leadingIcon: "phone"
    )

    Button("登録する") {
        submitForm()
    }
    .buttonStyle(.primary)
    .buttonSize(.large)
    .frame(maxWidth: .infinity)
}
.padding(spacing.lg)
```

---

## Good / Bad パターン

```swift
// ✅ Good: DSTextField コンポーネントを使用
DSTextField(
    "メール",
    text: $email,
    placeholder: "example@email.com",
    error: emailError,
    leadingIcon: "envelope"
)

// ❌ Bad: 標準 TextField + 独自装飾
VStack(alignment: .leading) {
    Text("メール")
        .font(.caption)
    HStack {
        Image(systemName: "envelope")
        TextField("example@email.com", text: $email)
    }
    .padding()
    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
    if let error = emailError {
        Text(error).foregroundColor(.red).font(.caption)
    }
}

// ✅ Good: エラーはerrorパラメータで渡す
DSTextField("名前", text: $name, error: nameError)

// ❌ Bad: エラー表示を外側で独自実装
DSTextField("名前", text: $name)
if let error = nameError {
    Text(error).foregroundColor(.red)
}
```
