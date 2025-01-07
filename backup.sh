#!/bin/bash

BACKUP_FILE="db_dump_$(date +%Y%m%d_%H%M%S).sql" # バックアップファイル名
BACKUP_DIR="/home/misskey/mi_backup" #バックアップファイルの一時的な保存先
DOCKER_DIR="/home/misskey/misskey" # docker-compose.ymlがあるディレクトリ
CONTAINER_NAME="containar_name" # Postgresqlが動いているコンテナ名
DB_USER="your_db_user_name" # Postgresqlユーザー名
DB_NAME="your_db_database_name" # Postgresqlデータベース名
GD_DIR="/home/misskey/GoogleDrive" # GoogleDriveマウントディレクトリ

# Discord Webhook URL
DISCORD_WEBHOOK_URL="your_discord_webhook_url"

# sudoパスワード
PASSWORD="your_password"

# docker-compose.ymlがあるディレクトリに移動
cd "${DOCKER_DIR}"

# バックアップ開始通知
curl -H "Content-Type: application/json" -X POST -d "{\"content\": \"📌 データベースのバックアップを開始します。\"}" "$DISCORD_WEBHOOK_URL"

# バックアップを作成
echo $PASSWORD | sudo -S docker compose exec "${CONTAINER_NAME}" pg_dump -U "${DB_USER}" "${DB_NAME}" > "${BACKUP_DIR}/${BACKUP_FILE}"

if [ $? -eq 0 ]; then
    echo "Database backup successful: ${BACKUP_FILE}"

    # Google Driveにコピー
    cp "${BACKUP_DIR}/${BACKUP_FILE}" "${GD_DIR}"

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
