# クイックリファレンス - Nginx & アプリケーション確認

初心者の方でも簡単に実行できる、よく使うコマンド一覧です。

## 📋 目次

1. [サーバーに接続する](#サーバーに接続する)
2. [基本確認コマンド](#基本確認コマンド)
3. [ログを確認する](#ログを確認する)
4. [よくあるトラブルと解決方法](#よくあるトラブルと解決方法)

---

## 🔌 サーバーに接続する

### コマンド（コピー＆ペーストで実行）

```bash
ssh -i ~/.ssh/my-key-pair.pem ec2-user@3.115.160.151
```

### 接続が成功したら
以下のような表示が出ます：
```
[ec2-user@ip-xxx-xxx-xxx-xxx ~]$
```

### 接続を終了する
```bash
exit
```

---

## ✅ 基本確認コマンド

### 1. Unicornが動いているか確認

```bash
ps aux | grep unicorn
```

**✅ 正常な場合:** `unicorn master` という行が表示される  
**❌ 異常な場合:** 何も表示されない（起動していない）

---

### 2. Nginxが動いているか確認

```bash
sudo systemctl status nginx
```

**✅ 正常な場合:** `Active: active (running)` と表示される

---

### 3. すべてを一度に確認（便利なスクリプト）

サーバーに接続後、以下のコマンドを実行：

```bash
chmod +x /path/to/quick_check_commands.sh
bash /path/to/quick_check_commands.sh
```

※スクリプトファイルをサーバーにアップロードする必要があります

---

## 📝 ログを確認する

### Unicornのエラーログ（最後の20行）

```bash
tail -20 /var/www/furima-46419/shared/log/unicorn.stderr.log
```

### Railsアプリのログ（最後の20行）

```bash
tail -20 /var/www/furima-46419/shared/log/production.log
```

### Nginxのエラーログ（最後の20行）

```bash
sudo tail -20 /var/log/nginx/error.log
```

### Nginxのアクセスログ（最後の20行）

```bash
sudo tail -20 /var/log/nginx/access.log
```

---

## 🔧 よくあるトラブルと解決方法

### ❌ Unicornが起動していない

**確認コマンド:**
```bash
ps aux | grep unicorn
```

**解決方法:**
1. エラーログを確認
   ```bash
   tail -50 /var/www/furima-46419/shared/log/unicorn.stderr.log
   ```
2. 手動で起動を試みる
   ```bash
   cd /var/www/furima-46419/current
   $HOME/.rbenv/bin/rbenv exec bundle exec unicorn -c config/unicorn.rb -E production -D
   ```

---

### ❌ 502 Bad Gateway エラー

**原因:** NginxとUnicornの接続に問題がある

**確認コマンド:**
```bash
# 1. Unicornが起動しているか
ps aux | grep unicorn

# 2. ソケットファイルが存在するか
ls -l /var/www/furima-46419/current/tmp/sockets/unicorn.sock
```

**解決方法:**
- Unicornが起動していない場合は、上記の方法で起動
- ソケットファイルがない場合は、Unicornを再起動

---

### ❌ 500 Internal Server Error

**原因:** Railsアプリケーション側のエラー

**確認コマンド:**
```bash
tail -50 /var/www/furima-46419/shared/log/production.log
```

**よくある原因:**
- データベース接続エラー
- アプリケーションコードのエラー
- 環境変数の設定ミス

---

### ❌ Nginx設定エラー

**確認コマンド:**
```bash
sudo nginx -t
```

**解決方法:**
エラーメッセージに従って設定ファイルを修正し、再読み込み：
```bash
sudo systemctl reload nginx
```

---

## 🚀 再起動コマンド

### Unicornを再起動

```bash
cd /var/www/furima-46419/current
# 現在のUnicornを停止
kill -QUIT $(cat /var/www/furima-46419/shared/tmp/pids/unicorn.pid)
# 新しいUnicornを起動
$HOME/.rbenv/bin/rbenv exec bundle exec unicorn -c config/unicorn.rb -E production -D
```

### Nginxを再起動

```bash
sudo systemctl restart nginx
```

### Nginx設定を再読み込み（サービスを止めずに設定だけ反映）

```bash
sudo systemctl reload nginx
```

---

## 📍 重要なファイルの場所

| ファイル/ディレクトリ | パス |
|---------------------|------|
| アプリケーション本体 | `/var/www/furima-46419/current` |
| 共有ログ | `/var/www/furima-46419/shared/log` |
| Unicorn PIDファイル | `/var/www/furima-46419/shared/tmp/pids/unicorn.pid` |
| Unicornソケット | `/var/www/furima-46419/current/tmp/sockets/unicorn.sock` |
| Nginx設定 | `/etc/nginx/sites-enabled/` または `/etc/nginx/conf.d/` |
| Nginxログ | `/var/log/nginx/` |

---

## 💡 便利なコマンド集

### リアルタイムでログを監視（Ctrl+Cで終了）

```bash
# Unicornエラーログを監視
tail -f /var/www/furima-46419/shared/log/unicorn.stderr.log

# Railsアプリのログを監視
tail -f /var/www/furima-46419/shared/log/production.log
```

### ファイルの内容を確認

```bash
# 設定ファイルを確認
cat /etc/nginx/sites-enabled/furima-46419

# ログファイルの最後の100行を確認
tail -100 /var/www/furima-46419/shared/log/production.log
```

### プロセスを検索

```bash
# Unicornプロセスを検索
ps aux | grep unicorn

# Nginxプロセスを検索
ps aux | grep nginx
```

---

## ✅ 動作確認チェックリスト

デプロイ後、以下を確認してください：

- [ ] Unicornプロセスが起動している
  ```bash
  ps aux | grep unicorn
  ```

- [ ] ソケットファイルが存在する
  ```bash
  ls -l /var/www/furima-46419/current/tmp/sockets/unicorn.sock
  ```

- [ ] Nginxが起動している
  ```bash
  sudo systemctl status nginx
  ```

- [ ] Nginx設定に問題がない
  ```bash
  sudo nginx -t
  ```

- [ ] ブラウザでアクセスできる
  - `http://3.115.160.151` にアクセス

- [ ] エラーログに問題がない
  ```bash
  tail -20 /var/www/furima-46419/shared/log/unicorn.stderr.log
  tail -20 /var/www/furima-46419/shared/log/production.log
  ```

---

## 📚 もっと詳しく知りたい方へ

詳細な手順については、`docs/nginx_application_check_guide.md` を参照してください。

