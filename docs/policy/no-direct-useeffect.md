# Policy: No Direct `useEffect`

## 目的

本ポリシーは、React コンポーネントの副作用制御を明示的かつ予測可能に保つために、`useEffect` の直接利用を禁止する。
これにより、無限ループ、依存配列の破綻、レースコンディション、意図しない再実行を減らし、保守性を向上させる。

## 適用範囲

- 対象: React フロントエンドコード（`*.tsx`, `*.ts` の UI 層）
- 対象外: インフラ設定、ビルド設定、React 非依存コード
- 施行対象: 人手実装コード、Agent 生成コードの両方

## 規範（MUST / SHOULD）

### MUST

- コンポーネント内で `useEffect` を直接呼び出してはならない
- 外部システムとの「マウント時同期」が必要な場合のみ、`useMountEffect` を使用する
- 既存コードの `useEffect` は、代替パターンに沿って順次置換する

### SHOULD

- 派生値は state 同期せず、レンダー中に計算する
- データ取得は Query ライブラリを使用する
- ユーザー操作起点の処理はイベントハンドラで実行する
- 「再初期化したい」は dependency 調整ではなく `key` 再マウントで表現する

## 禁止事項

- `useEffect(() => setState(...), [...])` による派生状態の同期
- `useEffect` 内での `fetch(...).then(setState)` 実装
- `setFlag(true) -> effect 実行 -> setFlag(false)` のフラグ中継
- ID/props 変更時の初期化を dependency 配列の調整で実現する実装
- 依存配列で「たまたま動く」状態に合わせ込む実装

## 許可される例外

「マウント時に一度だけ外部システムと同期する」用途に限り、`useMountEffect` を許可する。

```typescript
export function useMountEffect(effect: () => void | (() => void)) {
  /* eslint-disable no-restricted-syntax */
  useEffect(effect, []);
}
```

許可例:

- DOM 操作（focus / scroll）
- サードパーティウィジェットの初期化・破棄
- Browser API の subscription / cleanup

## 推奨代替パターン（標準5原則）

1. 派生状態は同期せず、その場で計算する  
2. データ取得は Query ライブラリに委譲する  
3. アクションは effect ではなくイベントハンドラで実行する  
4. 一度だけの外部同期は `useMountEffect` を使う  
5. リセットは effect ではなく `key` で再マウントする

## 背景と根拠

- `useEffect` は値間関係の暗黙同期を生み、結合が見えにくくなる
- effect 連鎖は時間依存制御フローとなり、調査コストが高い
- Agent 実装では「とりあえず effect」が入りやすく、将来不具合の温床になる

参考: [React - You Might Not Need an Effect](https://react.dev/learn/you-might-not-need-an-effect)

## 施行方法

### Lint

- `useEffect` を禁止するルールを有効化する（`no-restricted-imports` または `no-restricted-syntax`）
- `react-hooks/exhaustive-deps` の調整で運用を回避しない
- `useMountEffect` 定義ファイルのみ最小限の例外設定を許可する

## 移行手順（既存コード）

1. `useEffect` 利用箇所を棚卸しする
2. 用途を分類する（派生状態 / fetch / イベント / mount sync / reset）
3. 代替パターンへ置換する
4. Lint を有効化し、新規違反を CI でブロックする

## 受け入れ基準

- 新規コードに `useEffect` の直接利用が存在しない
- 例外利用は `useMountEffect` に集約されている
- CI/Lint で禁止ルールが継続的に担保されている

---

このポリシーは「厳格化」ではなく、制御フローを明示化するための安全装置である。
