# Revolt Claude Code チーム運用（設計書）

## このナレッジの目的

Claude Code を「個人の工夫」ではなく、**チームの標準プロセス**として運用するための設計書です。

この設計の狙いは次の 3 点です。

- **オペレーションを固定化**する：開発者が毎回長文で指示を書かず、`コマンド + タスクファイル` だけで回す。
- **品質を仕組みで担保**する：実装 → レビュー → 修正 → 再レビュー を自動的に回す。
- **共通資産を再利用**する：Skills / subagent / commands を `~/.claude/` で全社共通管理し、全プロジェクトで自動的に有効にする。

---

## 全体アーキテクチャ（結論）

### 共通資産の配置先

- **`~/.claude/` = テンプレートリポジトリそのもの**。開発者が clone するだけで全プロジェクトに共通ルールが適用される。
  - `~/.claude/agents/`
  - `~/.claude/skills/`
  - `~/.claude/commands/`
- **各プロジェクトの `.claude/`** にはプロジェクト固有のものだけを置く。
  - `.claude/project/`（タスク・設計・要件）
  - `.claude/CLAUDE.md`（入口）

agents / skills / commands はプロジェクトリポジトリには**置かない**。

### 配布・更新手法

- submodule・コピースクリプト・シンボリックリンクは使わない。
- 開発者は `~/.claude/` を git リポジトリとして管理し、`git pull` だけで最新化する。

### 実行は「コマンド + ファイル指定」に固定する

- 例：`/impl .claude/project/tasks/010-auth.md`
- 例：`/review .claude/project/tasks/010-auth.md`

**設計方針の理由**

Claude Code が agents / skills / commands を読み込むパスは `.claude/`（プロジェクト）と `~/.claude/`（グローバル）の直下のみ。ネストしたパスは一切読み込まれない。テンプレートリポジトリを `~/.claude/` として clone することで、構造をそのまま活かせる上に、更新も `git pull` 一発で完結する。

---

## ディレクトリ設計

```bash
.claude/
  CLAUDE.md        # 入口（読み順だけを書く）
  agents/          # subagent（技術スタック別専門家）
  skills/          # Skills（守らせたいことの強制）
  commands/        # 開発者の操作を固定化する入口
  project/         # プロジェクト固有コンテキスト（タスク/設計/要件）
```

### `.claude/CLAUDE.md`（入口ファイル）

このファイルは **短く**保ちます。詳細は agents / skills / commands / project に寄せます。

**読み順（優先順位）**

1. `.claude/skills/security-check/SKILL.md`（禁止事項・データ取り扱い）
2. `.claude/skills/quality-check/SKILL.md`（品質チェック）
3. `.claude/agents/*`（専門 subagent）
4. `.claude/commands/*`（運用コマンド）
5. `.claude/project/*`（このプロジェクト固有）

記入例：

```markdown
# Claude Code Entry Point (Project)
このリポジトリの Claude Code 運用は「コマンド + タスクファイル指定」で固定する。

## TL;DR（最短ルート）
- 実装: `/impl .claude/project/tasks/NNN-<slug>.md`
- レビュー: `/review .claude/project/tasks/NNN-<slug>.md`
- 実装↔レビューの反復: `/run .claude/project/tasks/NNN-<slug>.md`

## このプロジェクトの前提（最小）
- プロジェクト名: <PROJECT_NAME>
- 主要スタック: <STACK>（例: Next.js + TypeScript / FastAPI / etc）
- リポジトリの目的: <ONE_LINE_PURPOSE>

## 作業時の基本ルール
- 必ずタスクファイルを起点にする（チャットで長文指示を作らない）
- 迷ったら小さい番号のタスクから進める
- 変更したら関連ドキュメントも同期する（README / design / requirements）

## 重要: 触ってはいけないもの（プロジェクト固有追記）
- 秘密情報（APIキー、個人情報、顧客データ等）はコミットしない
```

---

## `.claude/project/`（プロジェクト固有コンテキスト）

Claude Code が迷わないために、**タスク → 設計 → 要件**を揃えます。

```bash
.claude/project/
  README.md                 # 前提サマリ（最初に読む）
  tasks/                    # タスクチケット（必ず番号付き）
    00001-main.md
  design/                   # 設計（アーキ/DB/IF/データフロー）
    architecture.md
    api-contracts.md
    data-model.md
  requirements/             # 要件定義（機能/非機能/受入条件）
    functional.md
    non-functional.md
    acceptance-criteria.md
  decisions/                # 意思決定ログ（ADR）
    use-supabase.md
```

### タスクのルール（必須）

- **ファイル名は連番**：`NNNNN-<slug>.md`（例：`00010-auth.md`）
- **番号＝実行順**：迷ったら番号が小さいものから進める。
- **1ファイル=1タスク**：大きければ分割して番号を増やす。
- 各タスクに最低限含める：
  - 目的
  - 背景
  - 受入条件（チェックリスト）
  - 影響範囲
  - 参照（設計・要件へのリンク）
- 例

```markdown
---
status: pending
completed_at: null
---

# 00002: Terraform/IAM - posting-service Task Role に Secrets Manager read 権限を追加

## 目的

posting-serviceがGoogleカレンダー連携用のSecrets Managerからrefresh tokenを読み取れるように、IAM権限を設定する。

## 背景

- posting-serviceは`posting.google_calendar_connections`テーブルから`secret_arn`を参照し、Secrets Managerから認証情報を取得する必要がある
- 最小権限の原則に従い、必要なSecretsのみ読み取れるようにする

## 受入条件

- [ ] posting-serviceのECS Task RoleにSecrets Manager読み取り権限を追加
- [ ] 最小権限の原則：`google-calendar-oauth/*`のprefixのみ許可
- [ ] TerraformでIAMポリシーを定義
- [ ] 動作確認（posting-serviceからSecrets Managerへのアクセステスト）

## 影響範囲

- `infra/modules/ecs/` - ECS Task Role定義
- `infra/modules/iam/` - IAMポリシー定義

## 参照

- `.claude/project/design/architecture.md` - IAM設計、セキュリティ設計
```

---

## `.claude/agents/`（subagent）

### 目的

- 技術スタックごとの「守ってほしい癖」を subagent に隔離する。
- プロンプト本文に長文の規約を毎回貼らない。

### 配置

- `.claude/agents/<name>.md`

### 命名

- `react-vite-spa-typescript-expert`
- `fastapi-python-expert`
- `quality-review-expert`

---

## `.claude/skills/`（Skills）

### 目的

CLAUDE.md / subagent.md に書いても守られにくい項目を「スキル」として定義し、**毎回の工程に差し込む**。

### 最低限用意する Skills（v1）

- `quality-check`
  - 未使用コード・到達不能分岐・後方互換の残骸の排除
  - 受入条件の充足確認
  - テスト/静的解析の確認
- `security-check`
  - 機密/秘密情報の混入防止
  - 危険な実装パターンの検出
- `doc-sync`
  - 実装に同期した README / 設計 / テストの更新促進

---

## `.claude/commands/`（コマンド）

### ねらい

- 実装者が毎回長文で指示を書かない。
- 指示は **タスク md に集約**し、実行のたびにオペレーションを一定化する。
- **実装 ↔ レビュー**を交互に回し、品質を上げる。

### 推奨オペレーション

- 実装開始：`/impl .claude/project/tasks/010-auth.md`
- レビューだけ：`/review .claude/project/tasks/010-auth.md`
- 実装〜レビュー〜修正ループをまとめて回す：`/run .claude/project/tasks/010-auth.md`

### コマンドの責務

- `impl.md` — タスクを読み、対象モジュールを判定し、適切な subagent を選択して実装する。
- `review.md` — `skills/quality-check` を必ず通し、指摘があれば修正方針を出す。
- `run.md` — `impl` → `quality-check` → 修正 → `quality-check` を受入条件が満たされるまで繰り返す。

注意：自動ループは実装時間・トークン消費が増える。並列開発（worktree等）前提で運用する。

---

## 導入手順

### 開発者のマシンセットアップ（初回のみ）

テンプレートリポジトリの `setup.sh` を実行する。

```bash
git clone git@github.com:revolt-inc/revolt-claude-template.git
bash revolt-claude-template/setup.sh
```

`setup.sh` の内容：

```bash
#!/bin/bash
set -e

# ~/.claude/ にリポジトリを clone（すでに存在する場合はスキップ）
if [ ! -d "$HOME/.claude/.git" ]; then
  git clone git@github.com:revolt-inc/revolt-claude-template.git ~/.claude
fi

# Claude Code が書き込むファイルを git 追跡から除外
cat > ~/.claude/.gitignore << 'EOF'
# Claude Code が自動生成するファイル
settings.local.json
*.log
.cache/
EOF

echo "セットアップ完了。"
```

### 新規プロジェクトのセットアップ

```bash
mkdir -p .claude/project/tasks .claude/project/design .claude/project/requirements .claude/project/decisions
touch .claude/project/README.md .claude/CLAUDE.md
```

`.claude/CLAUDE.md` にスタック・目的・基本ルールを記載する。agents / skills / commands はグローバルで管理するため、プロジェクト側には置かない。

---

## 共通資産の更新運用

### 更新手順

`update.sh` を実行する。

```bash
bash ~/.claude/update.sh
```

`update.sh` の内容：

```bash
#!/bin/bash
set -e

cd ~/.claude
git pull
echo "更新完了。"
```

### テンプレートリポジトリの構成

リポジトリ自体が `~/.claude/` の内容そのもの。

```bash
(revolt-claude-template = ~/.claude/)
  agents/
    react-expert.md
    next-expert.md
    go-expert.md
    latex-agent.md
  skills/
    quality-check/
      SKILL.md
    security-check/
      SKILL.md
    doc-sync/
      SKILL.md
    ...                       # その他のスキル
  commands/
    impl.md
    review.md
    run.md
  CLAUDE.md          # グローバル共通の入口（読み順・全社ルール）
  setup.sh           # 初回セットアップ（clone + .gitignore 生成）
  update.sh          # 更新（git pull）
  VERSION
  CHANGELOG.md
  README.md
  docs/policy/       # 任意: チーム向けポリシー文書（Claude Code の読み込み対象外）
```

### 共通資産に変更を加えるとき

1. テンプレートリポジトリでファイルを修正・PR・マージ
2. 各開発者に周知する（Slack 等）
3. 各開発者が `bash ~/.claude/update.sh` を実行

---

## バージョニング

- Git tag：`vX.Y.Z`（SemVer）
- `VERSION`：例 `1.0.0`
- `CHANGELOG.md` を運用

---

## Contributing

1. 変更は必ず PR で行う
2. Skills / Commands / Agents は互換性を意識する
3. 破壊的変更は SemVer のメジャーを上げ、CHANGELOG に明記する

---

## License

TBD（社内利用前提の場合は Private / Internal を明記）
