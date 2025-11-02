#!/bin/bash
# クイックチェック用のコマンド集
# このスクリプトをサーバー上で実行して、各項目を確認できます

echo "=========================================="
echo "Nginx & アプリケーション動作確認スクリプト"
echo "=========================================="
echo ""

# 色の定義（ターミナルで色付きで表示）
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Unicornプロセス確認
echo "1. Unicornプロセスの確認"
if ps aux | grep -v grep | grep unicorn > /dev/null; then
    echo -e "${GREEN}✓ Unicornは起動しています${NC}"
    ps aux | grep -v grep | grep unicorn
else
    echo -e "${RED}✗ Unicornが起動していません${NC}"
fi
echo ""

# 2. PIDファイル確認
echo "2. Unicorn PIDファイルの確認"
if [ -f /var/www/furima-46419/shared/tmp/pids/unicorn.pid ]; then
    echo -e "${GREEN}✓ PIDファイルが存在します${NC}"
    echo "PID: $(cat /var/www/furima-46419/shared/tmp/pids/unicorn.pid)"
else
    echo -e "${RED}✗ PIDファイルが見つかりません${NC}"
fi
echo ""

# 3. ソケットファイル確認
echo "3. Unicornソケットファイルの確認"
if [ -S /var/www/furima-46419/current/tmp/sockets/unicorn.sock ]; then
    echo -e "${GREEN}✓ ソケットファイルが存在します${NC}"
    ls -l /var/www/furima-46419/current/tmp/sockets/unicorn.sock
else
    echo -e "${RED}✗ ソケットファイルが見つかりません${NC}"
fi
echo ""

# 4. Nginxの動作確認
echo "4. Nginxの動作確認"
if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✓ Nginxは起動しています${NC}"
else
    echo -e "${RED}✗ Nginxが起動していません${NC}"
fi
echo ""

# 5. Nginx設定の構文チェック
echo "5. Nginx設定の構文チェック"
if sudo nginx -t 2>&1 | grep -q "syntax is ok"; then
    echo -e "${GREEN}✓ Nginx設定に問題ありません${NC}"
else
    echo -e "${RED}✗ Nginx設定に問題があります${NC}"
    sudo nginx -t
fi
echo ""

# 6. ログファイルの最新エラー確認
echo "6. 最新のエラーログ確認（最後の5行）"
echo "--- Unicornエラーログ ---"
if [ -f /var/www/furima-46419/shared/log/unicorn.stderr.log ]; then
    tail -5 /var/www/furima-46419/shared/log/unicorn.stderr.log
else
    echo "ログファイルが見つかりません"
fi
echo ""

echo "--- Nginxエラーログ ---"
if sudo test -f /var/log/nginx/error.log; then
    sudo tail -5 /var/log/nginx/error.log
else
    echo "ログファイルが見つかりません"
fi
echo ""

echo "--- Railsアプリケーションログ ---"
if [ -f /var/www/furima-46419/shared/log/production.log ]; then
    tail -5 /var/www/furima-46419/shared/log/production.log
else
    echo "ログファイルが見つかりません"
fi
echo ""

# 7. ディレクトリの存在確認
echo "7. 重要なディレクトリの存在確認"
DIRS=(
    "/var/www/furima-46419/current"
    "/var/www/furima-46419/shared"
    "/var/www/furima-46419/current/public"
    "/var/www/furima-46419/shared/log"
    "/var/www/furima-46419/shared/tmp/pids"
    "/var/www/furima-46419/current/tmp/sockets"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓ $dir が存在します${NC}"
    else
        echo -e "${RED}✗ $dir が見つかりません${NC}"
    fi
done
echo ""

echo "=========================================="
echo "確認完了"
echo "=========================================="

