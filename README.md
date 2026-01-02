# Revolt Claude Common Rules

Revolt inc. で **Claude Code をチーム標準プロセスとして運用**するための共通ルール集です。  
各プロジェクトは本リポジトリを `.claude/common/` に **submodule** として取り込み、実行は **「コマンド + タスクファイル指定」** に固定します。

---

## 目的（Why）

- **オペレーションを固定化**：毎回長文の指示を書かず、`/impl` や `/review` とタスクファイルで回す
- **品質を仕組みで担保**：実装→レビュー→修正→再レビューを繰り返せるようにする
- **共通資産を再利用**：Skills / Agents / Commands / Policy / Templates を中央管理し全PJで使い回す

---

## 全体像（How it works）

各プロジェクトは `.claude/` 配下を次の3点セットで構成します。

- `.claude/common/`：本リポジトリ（唯一の正。submodule）
- `.claude/project/`：プロジェクト固有（タスク・設計・要件）
- `.claude/[CLAUDE.md](http://CLAUDE.md)`：入口（短く保つ。読み順を定義）

### 入口ファイルの読み順（優先順位）

1. `.claude/common/policy/*`（禁止事項・データ取り扱い）
2. `.claude/common/playbooks/*`（運用の型）
3. `.claude/common/skills/*`（強制したいチェック）
4. `.claude/common/agents/*`（専門 subagent）
5. `.claude/common/commands/*`（運用コマンド）
6. `.claude/project/*`（このPJ固有の前提）

---

## ディレクトリ構成

```
.
├─ policy/        # 機密/外部公開/禁止事項など
├─ playbooks/     # 運用手順・定型プロセス
├─ skills/        # 品質/セキュリティ/ドキュメント同期などの強制チェック
├─ agents/        # 技術スタック別の専門 subagent
├─ commands/      # /impl /review /run の挙動定義
└─ templates/     # タスクチケットや運用テンプレ

```

---

## 使い方（プロジェクト側）

### 1. submodule を追加

```

git submodule add <COMMON_REPO_URL> .claude/common
git commit -m "Add Claude common rules as submodule"

```

### 2. clone/セットアップ

初回clone：

```

git clone --recurse-submodules <repo>

```

既にclone済み：

```

git submodule update --init --recursive

```

---

## 運用の基本：コマンド + タスクファイル指定

### 実行例

- 実装開始
  - `/impl .claude/project/01-tasks/NNN-*.md`
- レビューだけ
  - `/review .claude/project/01-tasks/NNN-*.md`
- 実装〜レビュー〜修正をまとめて回す
  - `/run .claude/project/01-tasks/NNN-*.md`

> 推奨：タスクは `NNN-<slug>.md` の連番にし、番号＝実行順で迷いを消す。

---

## ルール（Rules）

### Skills（必須）

- Skills の正規パスは `.claude/common/skills/`
- 「守らせたいこと」は原則 Skills に寄せる
- プロジェクト固有のスキルは原則作らない  
  （必要な場合のみ `.claude/project/skills/` を許可）

### subagent（推奨）

- `.claude/common/agents/<name>.md`
- 技術スタックごとの癖（設計・実装方針・アンチパターン）を隔離する

### タスク（プロジェクト側で必須）

- `NNN-<slug>.md`（番号＝実行順）
- 1ファイル = 1タスク（大きければ分割）
- 最低限含める：
  - 目的
  - 背景
  - 受入条件（チェックリスト）
  - 影響範囲
  - 参照（設計・要件へのリンク）

---

## バージョニング

- Git tag：`vX.Y.Z`（SemVer）
- `VERSION`：例 `1.0.0`
- `[CHANGELOG.md](http://CHANGELOG.md)` を運用

submodule は特定コミット参照になるため、タグ + CHANGELOG が追跡しやすいです。

---

## 更新（追従）運用

方針：強制配布ではなく、各プロジェクトで **追従PRを自動作成**して可視化する。  
（例：GitHub Actions で submodule を更新して PR 作成）

---

## Contributing（変更フロー）

1. 変更は必ずPRで行う
2. Policy / Skills / Commands は互換性を意識する
3. 破壊的変更は SemVer のメジャーを上げ、CHANGELOG に明記する

---

## License

TBD（社内利用前提の場合は Private / Internal を明記）