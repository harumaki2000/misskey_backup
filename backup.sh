#!/bin/bash

# バックアップ保存ディレクトリとファイル名
BACKUP_FILE="db_dump_$(date +%Y%m%d_%H%M%S).sql"
BACKUP_DIR="/home/misskey/mi_backup"

# Discord Webhook URL
DISCORD_WEBHOOK_URL="your_discord_webhook_url"

# sudoパスワード
PASSWORD="your_password"

# バックアップフォルダに移動
cd /home/misskey/misskey

# バックアップ開始通知
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"📌 データベースのバックアップを開始します。\"}" $DISCORD_WEBHOOK_URL

# バックアップを作成
echo $PASSWORD | sudo -S docker compose exec コンテナ名 pg_dump -U DBユーザー名 DB名 > "${BACKUP_DIR}/${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "Database backup successful: ${BACKUP_FILE}"

    # Google Driveにコピー
    cp "${BACKUP_DIR}/${BACKUP_FILE}" "/home/misskey/GoogleDrive"

    if [ $? -eq 0 ]; then
        echo "Backup copied to Google Drive."

        # Discordに成功通知
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"✅ データベースのバックアップが完了し、Google Driveにアップロードされました: ${BACKUP_FILE}\"}" "$DISCORD_WEBHOOK_URL"
    else
        echo "Failed to copy backup to Google Drive."

        # Discordにエラー通知
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"⚠ データベースのバックアップコピーに失敗しました: ${BACKUP_FILE}\"}" "$DISCORD_WEBHOOK_URL"
    fi

    # 7日以上前のバックアップを削除
    find "${BACKUP_DIR}" -type f -name "db_dump_*.sql" -mtime +7 -exec rm {} \;

    if [ $? -eq 0 ]; then
        echo "Old backups deleted successfully."
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"🧹 7日以上前のローカルバックアップファイルを削除しました。\"}" "$DISCORD_WEBHOOK_URL"
    else
        echo "Failed to delete old backups."
        curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"⚠ 7日以上前のローカルバックアップファイルの削除に失敗しました。\"}" "$DISCORD_WEBHOOK_URL"
    fi

else
    echo "Database backup failed."

    # Discordにエラー通知
    curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"❌ データベースのバックアップに失敗しました。\"}" "$DISCORD_WEBHOOK_URL"
fi
