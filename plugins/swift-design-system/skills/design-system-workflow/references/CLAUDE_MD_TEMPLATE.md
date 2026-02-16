# CLAUDE.md デザインセクション テンプレート

## このファイルについて

iOS アプリプロジェクトの CLAUDE.md に追加するデザイン制約セクションのテンプレートです。
swift-design-system パッケージを使用するプロジェクトでは、以下のセクションを CLAUDE.md に追加して、
Claude Code がデザインシステムの規約に従ったコードを生成するようにしてください。

## 使い方

1. 以下のテンプレートをプロジェクトの CLAUDE.md にコピー
2. `[アプリ名]` 等のプレースホルダーを実際の値に置換
3. プロジェクト固有の追加ルールがあれば末尾に追記

---

## テンプレート（ここからコピー）

```markdown
## デザインシステム

本プロジェクトは `swift-design-system` パッケージを使用する。
詳細なトークン・コンポーネントリファレンスは `.claude/contexts/design-system.md` を参照。

### 必須ルール

- 色は `@Environment(\.colorPalette)` のトークンのみ使用する（`Color.blue` 等のハードコード禁止）
- 間隔は `@Environment(\.spacingScale)` のトークンのみ使用する（`.padding(16)` 等のマジックナンバー禁止）
- 角丸は `@Environment(\.radiusScale)` のトークンのみ使用する
- テキストは `.typography()` モディファイアを使用する（`.font(.system(size:))` 禁止）
- 影は `.elevation()` モディファイアを使用する（`.shadow()` 直接使用禁止）
- アニメーションは `.animate()` モディファイアを使用する（a11y 自動対応のため）
- ボタンは `.buttonStyle(.primary/.secondary/.tertiary)` を使用する
- アプリのルートビューに `.theme(themeProvider)` を適用する（ThemeProvider 必須）

### 美的方向性

- Apple Human Interface Guidelines に準拠したクリーンなデザイン
- 余白を十分に取り、情報密度を抑える（spacing.lg 以上を基本とする）
- AI が生成した「それっぽい」デザインを避ける：グラデーション過多、装飾過多、影の多用は禁止
- コンポーネントはデザインシステムの提供するものを優先使用する
- カスタムコンポーネントを作る場合もデザイントークンに従う

### アクセシビリティ

- 全てのインタラクティブ要素に `.accessibilityLabel()` を付与する
- タップターゲットは最低 44x44pt を確保する
- VoiceOver での操作を考慮した要素順序にする
- `.animate()` を使用することで `accessibilityReduceMotion` に自動対応する
- HighContrast テーマでの表示を確認する

### Preview 要件

全ての View に最低 3 つの Preview を用意する:
1. **Default** - ライトモード、標準テキストサイズ
2. **Dark** - ダークモード
3. **Large Text** - `.dynamicTypeSize(.xxxLarge)` でのアクセシビリティ確認

```swift
#Preview("Default") {
    MyView()
        .theme(ThemeProvider())
}

#Preview("Dark") {
    MyView()
        .theme(ThemeProvider(initialMode: .dark))
}

#Preview("Large Text") {
    MyView()
        .theme(ThemeProvider())
        .dynamicTypeSize(.xxxLarge)
}
```

### コンポーネント規約

- 1 画面につき PrimaryButton は最大 1 つ
- Card の elevation はデフォルト `.level1`、強調時 `.level2` まで
- Snackbar のメッセージは 1-2 行、アクションは最大 2 つ
- DSTextField には必ず label を設定する
- SectionCard 使用時は `.padding(.horizontal)` を View 側で付けない（自動管理）
```
