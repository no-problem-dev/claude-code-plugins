# 自己進化メカニズム

## 概要

ios-qa-agent は使うほど賢くなる。テスト実行のたびに UI の知識が蓄積され、次回はより効率的に、より正確に操作できるようになる。

これは「学習」ではない。「記録と活用」だ。AI が何かを学ぶのではなく、発見した事実を構造化して記録し、次回のプロンプトに注入する。

## App Map — UI ナレッジの蓄積

App Map (`tests/app-map.md`) はアプリの UI 構造を記録するナレッジベース。

### 成長のサイクル

```
1回目のテスト: App Map なし
  → qa-runner がすべての画面を探索（snapshot_ui を多用）
  → Discoveries として全画面・要素・遷移を報告
  → ios-qa-workflow が App Map を新規作成

2回目のテスト: App Map あり
  → qa-runner が App Map を参照して即座に操作
  → snapshot_ui の呼び出し回数が半減
  → 未知の画面に遭遇した場合のみ Discoveries を追加

3回目以降: App Map が成熟
  → 既知の操作は高速に実行
  → 新しい Discoveries は差分のみ
  → Known Issues で操作の落とし穴を事前回避
```

### App Map に記録されるもの

| カテゴリ | 内容 | 例 |
|---------|------|-----|
| **画面** | 識別条件、操作可能要素、観測用要素 | home: 「こんにちは」テキストで識別 |
| **遷移** | 画面間の操作と結果 | home → tap "Compose" → session_setup |
| **信頼度** | 各要素の操作方法の安定性 | [HIGH] label タップ可 / [LOW] 座標のみ |
| **Operation Patterns** | 効率的な操作手順 | 日本語入力: pbcopy + long_press + Paste |
| **Known Issues** | 操作の落とし穴 | 歯車ボタンは tap(id:) 不可、座標必須 |
| **QA Readiness** | テスト実施可能性の定量評価 | Score: 72% (Conditional) |

### App Map に記録されないもの

- テスト結果（成功率、失敗パターン）— 確認バイアスの源泉になる
- 期待結果 — runner に見えてはいけない
- 主観的な評価 — 「良い UI」「使いにくい」等

## 信頼度と日付 — 自然な品質管理

各要素には信頼度と最終確認日が付く:

```
[HIGH, 2026-03-15] Button "Compose" (id="square.and.pencil")
[LOW, 2026-03-15] Button "gearshape" — 座標必須
[MED, unverified] モデル行 — 観察のみ、操作未確認
```

### 信頼度の意味

| レベル | 意味 | runner の操作方法 |
|--------|------|-----------------|
| `[HIGH]` | label/id でタップ可能。安定して動作 | 即座に label/id でタップ |
| `[MED]` | label でタップ可能だが不安定、または未検証 | label → id → 座標のフォールバック |
| `[LOW]` | 座標タップのみ。ID/label では操作不可 | 最初から座標タップ |

### 自然な劣化と更新

機械的なカウンターやルールは使わない。

- runner が操作して**成功** → 日付を更新（鮮度が保たれる）
- runner が操作して**失敗** → 信頼度を1段階下げ、日付を更新
- 7日以上操作されていない → `[unverified]` マーク（削除はしない）

「N回失敗したら降格」のようなルールベースではなく、**直近の実績と鮮度で自然に品質が管理される**。

## Discoveries — 発見の報告

qa-runner はテスト実行中に発見した新しい情報を Discoveries として報告する。

### 確度の付与

各発見には確度が付く:

| 確度 | 意味 | App Map への反映 |
|------|------|----------------|
| `[interacted]` | 実際にタップ・入力・遷移を実行して確認 | 即座に反映 |
| `[observed]` | snapshot_ui で見えたが操作はしていない | `[unverified]` マーク付きで反映 |

これは「N回確認したら永続化」のような機械的ゲートではなく、**情報の質で自然にフィルタリングされる**仕組み。

### Discoveries のカテゴリ

```markdown
### Discoveries

#### 新規画面 [interacted]
- **settings**: 識別条件=..., 主要素=...

#### 新規遷移 [interacted]
- home → tap "Compose" → session_setup

#### 要素の更新 [observed]
- session_active: 処理中に「思考中」ボタンが出現

#### 操作パターン [interacted]
- 日本語入力: pbcopy + long_press + Paste で成功

#### 信頼度変更
- home: Button "gearshape" — tap(id:) 失敗 → [LOW] に降格推奨

#### QA Readiness Observations
- home: セッション行に accessibilityId なし → 座標タップ必須
```

## Known Issues — 操作の落とし穴

テスト実行中に発見された操作の落とし穴は、App Map の Operation Patterns に Known Issues として蓄積される。

```markdown
### Known Issues
- session_active: クレジット枯渇時にプレースホルダーが変化、Send→Play に切替
- model_select: タップ後にリストが自動スクロールし座標がずれる
- home: 歯車ボタンは座標タップのみ有効
- type_text: 日本語非対応。pbcopy + Paste で回避必須
```

次回の qa-runner はこの Known Issues を読んで、**同じ落とし穴にはまらない**。

## QA Readiness — テスト実施可能性の評価

アプリがそもそも AI QA に対応できる状態かを 5軸で評価する:

| 軸 | 意味 | 重み |
|----|------|------|
| 要素識別性 | UI 要素が ID/label で特定できるか | 30% |
| 操作可能性 | tap で実際に操作できるか | 25% |
| 状態観測性 | 操作結果が snapshot_ui で読み取れるか | 25% |
| 遷移追跡性 | 画面遷移が追跡できるか | 10% |
| 入力互換性 | テスト入力方法が利用可能か | 10% |

| レベル | スコア | 意味 |
|--------|--------|------|
| Ready | 80-100% | そのままテスト実行可能 |
| Conditional | 50-79% | 回避策ありでテスト可能 |
| Not Ready | 0-49% | 改修が必要 |

QA Readiness Score が低い場合、レポートに具体的な改善提案が出力される。

## 自己進化の全体像

```
テスト実行
  │
  ├─ qa-runner: 操作・観察・Discoveries 報告
  │   ├─ [interacted] 確認済みの画面・遷移・要素
  │   ├─ [observed] 観察のみの画面・要素
  │   ├─ 信頼度変更（操作失敗時）
  │   └─ QA Readiness Observations
  │
  ├─ qa-judge: 独立判定
  │   └─ Pass/Fail/Inconclusive（自己進化には関与しない）
  │
  └─ ios-qa-workflow Phase 3.5: App Map 更新
      ├─ [interacted] → 即座に反映
      ├─ [observed] → [unverified] マーク付きで追加
      ├─ 信頼度変更 → 降格を適用
      ├─ Known Issues → Operation Patterns に追記
      └─ QA Readiness Score → フロントマターに記録
          │
          ▼
      App Map v(N+1) — 次回のテストで活用
```
