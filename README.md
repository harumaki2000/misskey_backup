## misskey_backup
chatGPTに書かせましたが自分の環境では動いております。

## 必要なコマンド
このスクリプトではgoogle-drive-ocamlfuseを使用しています。
```
# google-drive-ocamlfuseをインストール
sudo add-apt-repository ppa:alessandro-strada/ppa
sudo apt update
sudo apt install google-drive-ocamlfuse
```
詳しい設定はhttps://zenn.dev/harumaki2000/articles/5ec7fb4cb33d1c

## GoogleDrive用マウントディレクトリ作成
```
# misskeyユーザーのホームディレクトリ
mkdir GoogleDrive
google-drive-ocamlfuse -o allow_other GoogleDrive
```

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
