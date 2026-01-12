---
name: changelog-generator
description: |
  CHANGELOGの自動生成・更新を支援するスキル。
  コミット履歴やPR情報からCHANGELOGエントリを生成し、
  バージョン管理とリリースノート作成を自動化します。

  <example>
  Context: リリース前またはバージョン更新時
  user: "CHANGELOGを更新して"
  assistant: "changelog-generatorスキルを適用して、最新のコミット履歴からCHANGELOGエントリを生成します。"
  <commentary>
  CHANGELOGの自動生成により、リリースノート作成の負担を軽減し、変更履歴の追跡性を向上させます。
  </commentary>
  </example>
---

# Changelog Generator Skill

CHANGELOGの自動生成・更新を支援するスキルです。
コミット履歴やPR情報からCHANGELOGエントリを生成し、バージョン管理とリリースノート作成を自動化します。

## 使用タイミング

- リリース前
- バージョン更新時
- マージ後（自動更新推奨）
- 手動でCHANGELOGを更新したい時

## 機能

### 1. CHANGELOGエントリの自動生成

コミット履歴から以下の情報を抽出してCHANGELOGエントリを生成：

- 変更タイプ（Added/Changed/Fixed/Removed/Security/Deprecated）
- 変更内容の要約
- 関連するPR/Issue番号
- 変更者情報（オプション）

### 2. バージョン管理

- SemVer形式（MAJOR.MINOR.PATCH）に基づくバージョン番号の更新
- 破壊的変更の検出とMAJORバージョンの更新提案
- バージョンタグとの整合性確認

### 3. セクション分類

変更内容を以下のセクションに自動分類：

- **Added**: 新機能
- **Changed**: 既存機能の変更
- **Deprecated**: 非推奨になった機能
- **Removed**: 削除された機能
- **Fixed**: バグ修正
- **Security**: セキュリティ修正

## CHANGELOG形式

### 標準形式（Keep a Changelog準拠）

```markdown
## [1.2.0] - 2024-01-15

### Added
- 新機能の説明（#123）
- 別の新機能の説明（#456）

### Changed
- 既存機能の変更内容（#789）

### Fixed
- バグ修正の説明（#101）

### Security
- セキュリティ修正の説明（#202）

## [1.1.0] - 2024-01-01
...
```

### アンカード形式（推奨）

```markdown
## [Unreleased]

### Added
- 未リリースの新機能

## [1.2.0] - 2024-01-15
...
```

## チェック項目

### 1. CHANGELOGの存在

- [ ] CHANGELOG.mdファイルが存在するか
- [ ] CHANGELOGが最新の状態か

### 2. エントリの形式

- [ ] エントリが標準形式に従っているか
- [ ] バージョン番号がSemVer形式か
- [ ] 日付が正しい形式か（YYYY-MM-DD）
- [ ] セクションが適切に分類されているか

### 3. 内容の完全性

- [ ] すべての重要な変更が記載されているか
- [ ] 破壊的変更が明記されているか
- [ ] 関連するPR/Issue番号が記載されているか
- [ ] 変更内容が明確に記述されているか

### 4. バージョン整合性

- [ ] CHANGELOGのバージョンとVERSIONファイルが一致しているか
- [ ] Gitタグとバージョンが一致しているか
- [ ] バージョン番号が適切にインクリメントされているか

## 自動生成のルール

### コミットメッセージからの抽出

Conventional Commits形式のコミットメッセージから自動抽出：

- `feat`: → Added
- `fix`: → Fixed
- `perf`: → Changed
- `refactor`: → Changed
- `security`: → Security
- `deprecate`: → Deprecated
- `remove`: → Removed

### PR情報からの抽出

PRのタイトルと説明から変更内容を抽出し、適切なセクションに分類。

## 出力形式

```
## Changelog Generator 結果

### ✅ 更新完了
CHANGELOGを更新しました。

**追加されたエントリ**:
- [セクション]: [変更内容]

**バージョン**: [X.Y.Z] → [X.Y.Z+1]

### ⚠️ 確認が必要
以下の変更が検出されましたが、手動確認を推奨します：

- [変更内容]: [理由]

### ❌ エラー
以下の問題が検出されました：

- [問題]: [詳細と修正方法]
```

## 使用方法

### 自動生成

```bash
# 最新のコミットからCHANGELOGを生成
changelog-generatorを適用してCHANGELOGを更新して

# 特定のバージョン範囲から生成
v1.1.0からv1.2.0までの変更でCHANGELOGを更新して
```

### 手動更新の支援

CHANGELOGの手動更新時も、形式チェックと整合性確認を実行します。

## 注意事項

- 自動生成されたエントリは必ずレビューする
- 機密情報や内部的な変更はCHANGELOGに含めない
- 破壊的変更は必ず明記する
- リリース前にCHANGELOGの内容を確認する

## 参考資料

- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
