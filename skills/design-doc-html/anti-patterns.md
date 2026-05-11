# Anti-Patterns: HTML 設計書で避けるべき書き方

本スキルが回避すべきパターンの実例集。`SKILL.md` の必須構造から外れる典型ケースをここに列挙する。
レビュー時にこの一覧と照合して該当があれば指摘すること。

## 1. div の海（セマンティックタグの放棄）

**問題:** AI は `<div>` の入れ子から意図を推論できず、解析コストが跳ね上がる。

```html
<!-- ✗ NG -->
<div class="title">ログイン</div>
<div class="content">
  <div class="row">email: string</div>
  <div class="row">password: string</div>
</div>
```

```html
<!-- ✓ OK -->
<section data-feature="auth.login" data-priority="must">
  <h2>ログイン</h2>
  <section data-block="input">
    <table>
      <tr><th>email</th><td>string</td></tr>
      <tr><th>password</th><td>string</td></tr>
    </table>
  </section>
</section>
```

## 2. 優先度の欠落

**問題:** `data-priority` が無いと、実装エージェントはすべて同列に扱う。MUST と MAY が混ざる。

```html
<!-- ✗ NG: 優先度不明 -->
<section>
  <h2>ログイン</h2>
  <h2>二要素認証</h2>
</section>
```

```html
<!-- ✓ OK -->
<section data-feature="auth.login" data-priority="must">...</section>
<section data-feature="auth.2fa"   data-priority="may"  data-scope="out">...</section>
```

## 3. スコープ外の不明示（暗黙の前提）

**問題:** 「書いていない＝やらない」は AI には通じない。書いてないものは AI が気を利かせて実装してしまう。

```html
<!-- ✗ NG: パスワード再発行が「対象外」と書かれていない -->
<section data-block="process">
  <ol>
    <li>email でユーザー検索</li>
    <li>パスワード照合</li>
  </ol>
</section>
```

```html
<!-- ✓ OK: out-of-scope ブロックで明示 -->
<section data-block="out-of-scope">
  <h3>スコープ外（実装しないこと）</h3>
  <ul>
    <li>パスワード再発行フロー</li>
    <li>ソーシャルログイン</li>
    <li>二要素認証</li>
  </ul>
</section>
```

## 4. 装飾過多（色の意味インフレ）

**問題:** 色を 10 種類使うと、優先度を示す色なのか・状態を示す色なのか・単なる装飾なのかが解析不能になる。

```css
/* ✗ NG: 色がたくさんあって意味不明 */
.title-red, .title-blue, .title-green, .title-orange, .title-purple, .title-yellow, .title-pink { ... }
```

```css
/* ✓ OK: 色は「優先度 3 + 状態 3」の合計 6 色まで */
[data-priority="must"]    { color: var(--c-must); }
[data-priority="should"]  { color: var(--c-should); }
[data-priority="may"]     { color: var(--c-may); }
[data-status="決定"]       { ... }
[data-status="未決"]       { ... }
[data-status="要レビュー"]  { ... }
```

## 5. JSON-LD メタデータの欠落

**問題:** 実装エージェントは `<script type="application/ld+json">` を最初に読む。これが無いと、scope・priority・openQuestions を本文から推論する羽目になる。

```html
<!-- ✗ NG: head にメタデータがない -->
<head><title>設計書</title></head>
```

```html
<!-- ✓ OK: AI 用構造化メタデータが冒頭にある -->
<head>
  <title>設計書</title>
  <script type="application/ld+json">
  { "@type":"TechArticle","scope":{"in":[...],"out":[...]},"priority":"must", ... }
  </script>
</head>
```

## 6. 200 行のフラット構造

**問題:** 「読まれない壁」（100 行超で読まれない）に直撃する。AI もアテンションが分散する。

**対策:**
- サマリーカード冒頭固定
- 機能ごとに `<section data-feature>` で囲む
- 詳細を `<details>` で折りたたむ
- 1 ファイル 500 行超は機能単位で分割（`auth-login.html`, `auth-logout.html` ...）

## 7. 外部 CSS / 外部 JS への依存

**問題:** 単一ファイル原則を破ると、配布先で崩れる・ローカル展開できない・AI が「style.css の中身は何か」を推論できない。

```html
<!-- ✗ NG -->
<link rel="stylesheet" href="/assets/design-doc.css">
<script src="/assets/copy-button.js"></script>
```

```html
<!-- ✓ OK -->
<style> /* インライン */ </style>
<button onclick="navigator.clipboard.writeText(...)">Copy</button>
```

## 8. 画像（PNG / JPG）でフロー図を描く

**問題:** AI は PNG を読めない（読めても OCR ノイズが乗る）。SVG ならテキストとして読める。

```html
<!-- ✗ NG -->
<img src="flow.png" alt="認証フロー">
```

```html
<!-- ✓ OK: インライン SVG または Mermaid 由来のテキスト図 -->
<svg viewBox="0 0 400 200" role="img" aria-label="認証フロー">
  <rect x="10" y="10" width="100" height="40"></rect>
  <text x="60" y="35" text-anchor="middle">Client</text>
  ...
</svg>
```

## 9. 決定事項・未決事項テーブルの欠落

**問題:** 文章中に「JWT を採用しました」「レート制限値は要検討」と散らばっていると、AI が決定事項を一覧化できず、後続フェーズで「再検討」してしまう。

**対策:** 末尾に `<table data-section="decisions">` と `<table data-section="open-questions">` を必ず置く。本文中の決定は `data-ref="D-001"` でテーブルにリンクさせる。

## 10. 「Copy as Prompt」エクスポートの欠如

**問題:** HTML を AI に再入力するループが閉じない。人間が手でコピペすると揺らぐ。

```html
<!-- ✓ OK: 末尾に必ず配置 -->
<button data-action="copy-as-prompt" onclick="
  navigator.clipboard.writeText(document.documentElement.outerHTML);
">Copy as Prompt</button>
```

## 11. grep 不能な ID・クラス命名

**問題:** `<section class="card-1">` のような連番命名は検索性が低い。

```html
<!-- ✗ NG -->
<section class="card-1">
<section class="card-2">
```

```html
<!-- ✓ OK: 機能 ID をそのまま data-feature に -->
<section id="feat-login"  data-feature="auth.login">
<section id="feat-logout" data-feature="auth.logout">
```

## 12. AI 向け注記と人間向け注記の混在

**問題:** `<aside>` で書いた注記が誰宛か判別できない。

```html
<!-- ✓ OK: data-for で対象を明示 -->
<aside data-for="ai">タイミング攻撃対策で bcrypt.compare を必ず使う</aside>
<aside data-for="human">レビュー時はパフォーマンス計測も依頼してください</aside>
```
