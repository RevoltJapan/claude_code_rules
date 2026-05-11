---
name: design-doc-html
description: |
  AI 再入力前提の HTML 設計書を生成するためのスキル。
  装飾よりも構造化を優先し、JSON-LD・data-* 属性・セマンティックタグで
  「AI が何を重要視すべきか」を機械可読に明示する。
  人間レビュー時の見やすさは二次目的で、生成物は次のフェーズの AI が
  そのまま読み直して実装に落とせる形を保証する。

  <example>
  Context: 機能の設計書を HTML で起こす指示が出たとき
  user: "ユーザー認証機能の設計書を HTML で作って"
  assistant: "design-doc-html スキルを適用して、テンプレートに沿った設計書を生成します。"
  <commentary>
  「設計書」「仕様書」を HTML で生成する依頼を受けたら本スキルを必ず適用する。
  本スキルが指定する構造を逸脱した HTML（div の海、装飾過多、優先度欠落）を生成してはならない。
  </commentary>
  </example>
---

# Design Doc HTML Skill

AI が再度読み込んで実装に使うことを最優先にした HTML 設計書生成スキル。
リッチに描けるという HTML の特性は副次効果として活かすが、本スキルの一義は
**「AI が優先度・スコープ・決定事項を一意に解釈できる構造」** を強制することにある。

## 適用タイミング

- 「設計書」「仕様書」「Design Doc」「機能設計」を HTML で書く依頼を受けたとき
- 既存の Markdown 設計書を HTML に変換する依頼を受けたとき
- `.claude/project/tasks/NNNNN-*.md` から派生する設計書を作成するとき

## 設計思想（前提共有）

| 観点 | 本スキルの立場 |
|---|---|
| 主要読者 | **次フェーズの AI（実装エージェント・レビューエージェント）** |
| 副次読者 | 人間レビュアー |
| 装飾 | 最小限。色は意味（優先度・状態）にだけ使う |
| 単一ファイル原則 | 外部 CSS / 外部 JS / 画像参照は禁止。SVG はインラインで埋め込み可 |
| grep 可能性 | 必須。一意な id・data 属性・section ラベルで検索可能にする |
| 編集モデル | 人間が手で書き換える前提を捨て、AI に修正させる前提に立つ |

## 必須構造（この順序を逸脱しない）

```
<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <title>{機能名} 設計書</title>
  <script type="application/ld+json"> ... AI 向けメタデータ ... </script>
  <style> ... 最小限のインラインスタイル ... </style>
</head>
<body>
  <header data-section="summary">      ... サマリーカード（必須） ...
  <nav data-section="toc">              ... 目次（アンカー付き） ...
  <main>
    <section data-feature="..." data-priority="must|should|may">
      <h2>...</h2>
      <section data-block="context">    ... 背景・目的・利用者 ...
      <section data-block="input">      ... 入力項目（必須/任意） ...
      <section data-block="process">    ... 処理ステップ（番号付き） ...
      <section data-block="output">     ... 出力 ...
      <section data-block="exception">  ... 例外・エッジケース ...
      <section data-block="out-of-scope"> ... スコープ外（明示必須） ...
    </section>
    ...
  </main>
  <footer>
    <table data-section="decisions">    ... 決定事項一覧（必須） ...
    <table data-section="open-questions"> ... 未決事項一覧（必須） ...
    <button data-action="copy-as-prompt"> ... AI 再入力用エクスポート ...
  </footer>
</body>
</html>
```

雛形は `template.html`、記入済みサンプルは `example.html` を参照。

## JSON-LD メタデータ（必須）

`<head>` 内に下記を必ず埋め込む。実装フェーズの AI はここを最初に読む。

```json
{
  "@context": "https://schema.org",
  "@type": "TechArticle",
  "name": "{機能名} 設計書",
  "version": "0.1.0",
  "audience": "ai-implementation-agent",
  "scope": { "in": ["..."], "out": ["..."] },
  "decisions": [ { "id": "D-001", "summary": "..." } ],
  "openQuestions": [ { "id": "Q-001", "summary": "..." } ],
  "priority": "must|should|may"
}
```

## data-* 属性ルール（優先度の機械可読化）

| 属性 | 値 | 用途 |
|---|---|---|
| `data-priority` | `must` / `should` / `may` | section 単位の実装優先度 |
| `data-scope` | `in` / `out` | スコープ内外の明示。`out` のものは AI に実装させない |
| `data-status` | `決定` / `未決` / `要レビュー` | 決定状態の明示 |
| `data-feature` | 機能 ID（例 `auth.login`） | grep 用の一意キー |
| `data-block` | `context` / `input` / `process` / `output` / `exception` / `out-of-scope` | 5+1 区分の役割明示 |
| `data-ref` | `D-001` / `Q-001` などの ID | 決定・未決テーブルへの参照 |
| `data-for` | `ai` / `human` | 注記の対象読者を明示 |

## 5+1 区分セクション（機能ごとに必須）

各 `<section data-feature="...">` の内部は **必ず**以下の順序で 6 ブロックを置く。
該当なしの場合も「該当なし」と明記して空タグを残す（AI が見落とさないため）。

1. **context** — 背景・目的・利用者・既存システムとの関係
2. **input** — 入力項目（必須/任意、型、制約）。`<table>` 推奨
3. **process** — 処理ステップ（`<ol>` で番号付き、各 `<li>` に `data-step` 付与）
4. **output** — 出力（戻り値、副作用、永続化）
5. **exception** — エラー・エッジケース。`<table>` で網羅
6. **out-of-scope** — スコープ外項目。「○○は対象外」を明示的に列挙（暗黙前提の排除）

## サマリーカード（冒頭固定）

100 行を超えると読まれない問題への対策。`<header data-section="summary">` に：

- 機能名・1 行サマリー
- 影響範囲（ファイル数・モジュール数）
- 優先度（`must` / `should` / `may`）
- 想定実装規模（行数 or 工数）
- 未決事項の件数

を 1 画面で見せる。

## 末尾固定要素

- **決定事項テーブル**（`data-section="decisions"`）：`D-001` 形式 ID、決定内容、決定者、決定日
- **未決事項テーブル**（`data-section="open-questions"`）：`Q-001` 形式 ID、内容、ブロッカー有無、担当
- **Copy as Prompt ボタン**：本文を整形して clipboard に流すボタン。AI 再入力ループを閉じる

## 推奨ガイドライン（中庸：上限超過時は警告のみ）

| 項目 | 推奨 | 超過時の対応 |
|---|---|---|
| 1 ファイル行数 | 500 行以内 | 警告を出し、機能単位での分割を提案する |
| 1 機能の section | 80 行以内 | 警告を出し、サブ機能への分解を提案する |
| インライン SVG | 200 行以内 | 別ファイル化（`figures/*.svg`）を提案する |
| `<style>` ブロック | 100 行以内 | デザイントークンの共通化を提案する |
| 装飾色の種類 | 6 色以内（優先度 3 + 状態 3） | 7 色目以降は意味が薄いので統合を提案する |

これらは強制ではなく**警告**にとどめる。判断は実装者に委ねる。

## 出力チェックリスト（生成後に必ず自己点検）

- [ ] `<script type="application/ld+json">` に scope / decisions / openQuestions / priority が入っているか
- [ ] 全 `<section data-feature>` に `data-priority` が付いているか
- [ ] 各機能 section が 6 ブロック（context/input/process/output/exception/out-of-scope）を欠かさず持つか
- [ ] `out-of-scope` ブロックに具体的な「対象外項目」が 1 件以上書かれているか（空は不可）
- [ ] 決定事項テーブル・未決事項テーブルがあるか
- [ ] 外部 CSS / 外部 JS / 外部画像への参照がゼロか
- [ ] サマリーカードが冒頭にあり、優先度・規模・未決件数が一画面に収まるか
- [ ] 推奨上限（500 行 / 80 行 / 200 行 / 100 行 / 6 色）を超えていないか。超えていれば警告を出力したか

## 関連ファイル

- `template.html` — そのまま複製して使う雛形
- `example.html` — 「ユーザー認証機能」のサンプル設計書
- `anti-patterns.md` — 避けるべき書き方の事例集

## 注意事項

- Markdown 設計書を完全に置き換えるものではない。**正本・長期保守**の設計書は Markdown のままが望ましい。本スキルは **AI に渡す瞬間の中間生成物** または **レビュー共有用** の HTML を作るためのものとする。
- 「リッチに見せる」誘惑に負けないこと。装飾を増やすほど AI のトークン解析コストが上がり、優先度が埋もれる。
- 不明点は `<section data-block="out-of-scope">` に逃がさず、必ず未決事項テーブル（`Q-NNN`）に記録する。
