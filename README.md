## misskey_backup
chatGPTに書かせましたが自分の環境では動いております。

## 必要なコマンド
このスクリプトではrcloneを使用しています。

## 一時的なバックアップ用ディレクトリ作成
```
# Dockerを動かしているユーザーに入る(例：misskey)
# バックアップ用ディレクトリ作成
mkdir mi_backup
```

## 実行権限付与・(自動化する場合)cron設定
```
# 実行権限を付与する
chmod +x backup.sh

# crontabを開く
crontab -e

# 毎日4時に実行する場合
0 4 * * * /home/misskey/backup.sh
```
