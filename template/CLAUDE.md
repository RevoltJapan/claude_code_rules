# Claude Code Configuration

このファイルは、Claude Codeがプロジェクトの設定とコマンドを読み込むための入口ファイルです。

## 読み込み順序

以下の順序でファイルが読み込まれます：

1. `.claude/common/policy/*` - 禁止事項・データ取り扱い
2. `.claude/common/playbooks/*` - 運用手順・定型プロセス
3. `.claude/common/skills/*` - 強制したいチェック
4. `.claude/common/agents/*` - 専門 subagent
5. `.claude/common/commands/*` - 運用コマンド（`/impl`, `/review`, `/run`等）
6. `.claude/project/*` - このプロジェクト固有の前提

## 利用可能なコマンド

### `/impl` - 実装コマンド
タスクファイルを元に実装を段階的に実行します。

**使用方法**:
```
/impl .claude/project/tasks/00004-admin-front-google-oauth.md
```

**詳細**: `.claude/common/commands/impl.md` を参照

### `/review` - レビューコマンド
コードレビューを実行します。

**使用方法**:
```
/review .claude/project/tasks/00004-admin-front-google-oauth.md
```

**詳細**: `.claude/common/commands/review.md` を参照（存在する場合）

### `/run` - 実装〜レビュー〜修正をまとめて実行
実装からレビュー、修正までを一連の流れで実行します。

**使用方法**:
```
/run .claude/project/tasks/00004-admin-front-google-oauth.md
```

**詳細**: `.claude/common/commands/run.md` を参照（存在する場合）

## プロジェクト固有の設定

プロジェクト固有の設定や要件は `.claude/project/` ディレクトリに配置してください。

## トラブルシューティング

### コマンドが認識されない場合

1. `.claude/common/` がsubmoduleとして正しく設定されているか確認
   ```bash
   git submodule status
   ```

2. `.claude/common/commands/` ディレクトリにコマンドファイルが存在するか確認
   ```bash
   ls -la .claude/common/commands/
   ```

3. Claude Codeを再起動する

4. このファイル（`.claude/CLAUDE.md`）がプロジェクトルートの `.claude/` ディレクトリに存在するか確認
