# App Map 仕様書

## ファイル配置

```
tests/
├── qa-suite.md     # テストスイート定義
├── app-map.md      # App Map（このファイル）
└── cases/
    └── TC-*.md     # テストケース
```

テストスイートと同じディレクトリに `app-map.md` として配置。

## フォーマット（v5）

### フロントマター

```yaml
---
app: MyApp                           # アプリ名
scheme: MyApp                        # Xcode scheme
last_updated: 2026-03-15T14:00:00+09:00  # 最終更新日時
version: 6                           # App Map のバージョン（更新のたびにインクリメント）
format_version: 5                    # フォーマットバージョン（構造変更時のみ更新）
screens_count: 5                     # 画面数
qa_readiness_score: 72               # QA Readiness スコア（0-100）
qa_readiness_level: Conditional      # Ready / Conditional / Not Ready
---
```

### QA Readiness Summary

```markdown
## QA Readiness Summary
- **Score**: 72% (Conditional)
- **要素識別性**: 70%
- **操作可能性**: 65%
- **状態観測性**: 75%
- **遷移追跡性**: 90%
- **入力互換性**: 60%
```

### Screens

```markdown
### [画面名] [verified: YYYY-MM-DD]

- **識別**: [この画面を一意に特定する条件]
- **表示形式**: [NavigationView / Sheet / Modal 等。省略可]
- **UIパターン**: [特殊な UI パターンがあれば]
- **操作可能要素**:
  - [信頼度, 日付] [要素タイプ] "[label/id]" — [説明] → [遷移先]
- **観測用要素**:
  - [要素タイプ] "[label]" — [説明]
- **処理中の中間状態** [observed]:（あれば）
  - [中間状態の要素]
- **エラー発生時**:（あれば）
  - [エラー時の UI 変化]
- **QA Issues**: [テスト実施上の問題点]
```

### 信頼度の記法

```
[HIGH, 2026-03-15]  — label/id でタップ可能。最終確認日
[MED, 2026-03-15]   — label でタップ可能だが不安定。最終確認日
[LOW, 2026-03-15]   — 座標タップのみ。最終確認日
[MED, unverified]   — 観察のみ。操作未確認
```

### Transitions

```markdown
## Transitions

| From | Action | To | 信頼度 |
|------|--------|----|--------|
| home | tap "Compose" | session_setup | [HIGH, 2026-03-15] |
| home | tap gearshape (座標 338,75) | session_setup | [LOW, 2026-03-15] |
```

### Operation Patterns

```markdown
## Operation Patterns

### [パターン名]
[手順の説明]

### Known Issues
- **[画面名]**: [操作の落とし穴の説明]
```

## サイズ制約

| 項目 | 上限 | 理由 |
|------|------|------|
| 画面数 | 15 | コンテキスト効率 |
| 操作可能要素/画面 | 8 | 操作対象に絞る |
| 観測用要素/画面 | 5 | 検証に必要な最小限 |
| Operation Patterns | 5+Known Issues | 汎用パターンに絞る |
| 全体トークン数 | ~2,000（5画面）| qa-runner への注入サイズ |

15画面を超える場合は、テスト対象画面のみ抽出した compact 版を生成する。

## 自動更新のルール

### 反映ルール

| Discoveries の確度 | 反映方法 |
|-------------------|---------|
| `[interacted]` | 即座に反映。信頼度 [HIGH] または [MED]、日付を今日に |
| `[observed]` | `[MED, unverified]` マーク付きで追加 |

### 信頼度の更新

| イベント | 更新内容 |
|---------|---------|
| 操作成功 | 日付を更新。信頼度は維持 |
| 操作失敗（tap が効かない等） | 信頼度を1段階下げ、日付を更新 |
| 7日以上未操作 | `[unverified]` マーク追加（信頼度は下げない） |

### Known Issues の追記

runner の Issues/Observations から、操作の落とし穴を抽出して追記:
- 同じ問題が既に記録済み → スキップ
- 新しい問題 → Known Issues に追加

### バージョニング

- `version`: 更新のたびにインクリメント（内容の変更）
- `format_version`: フォーマット構造の変更時のみ更新（v5 → v6 等）
- `last_updated`: 更新日時

## App Map に含めないもの

- **テスト結果**: 成功率、失敗回数等 → 確認バイアスの源泉
- **期待結果**: テストケースの「期待結果」に関する情報 → runner に見えてはいけない
- **主観的評価**: 「使いにくい」「レイアウトが悪い」等
- **アプリのビジネスロジック**: API のレスポンス内容等
