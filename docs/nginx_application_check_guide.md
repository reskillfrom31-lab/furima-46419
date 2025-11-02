# Nginx設定確認とアプリケーション動作確認ガイド

このガイドでは、サーバー上のNginx設定を確認し、アプリケーションが正常に動作しているかを確認する手順を説明します。

## 前提条件

- サーバーIPアドレス: `3.115.160.151`
- ユーザー名: `ec2-user`
- SSH鍵ファイル: `~/.ssh/my-key-pair.pem`

---

## ステップ1: サーバーにSSH接続する

### Windows (WSL)の場合

ターミナルを開き、以下のコマンドを実行します：

```bash
ssh -i ~/.ssh/my-key-pair.pem ec2-user@3.115.160.151
```

**重要ポイント:**
- `-i` オプションでSSH鍵ファイルのパスを指定します
- 初回接続時は「Are you sure you want to continue connecting (yes/no)?」と聞かれるので、`yes` と入力してEnterキーを押してください

### SSH接続が成功したら

接続が成功すると、以下のような表示になります：

```
[ec2-user@ip-xxx-xxx-xxx-xxx ~]$
```

これでサーバーに接続できました！

---

## ステップ2: Unicornの動作状態を確認する

### 2-1. Unicornプロセスが起動しているか確認

以下のコマンドを実行します：

```bash
ps aux | grep unicorn
```

**期待される結果:**
- `unicorn master` という行が表示されれば正常に起動しています
- `unicorn worker` という行も表示される場合があります

**もし何も表示されない場合:**
Unicornが起動していない可能性があります。後述の「ステップ6: トラブルシューティング」を参照してください。

### 2-2. PIDファイルの存在を確認

以下のコマンドを実行します：

```bash
ls -l /var/www/furima-46419/shared/tmp/pids/unicorn.pid
```

**期待される結果:**
- ファイルが存在し、パーミッションが表示されます
- ファイルが存在しない場合は、Unicornが正常に起動していない可能性があります

### 2-3. Unicornソケットファイルの存在を確認

以下のコマンドを実行します：

```bash
ls -l /var/www/furima-46419/current/tmp/sockets/unicorn.sock
```

**期待される結果:**
- ソケットファイルが存在し、パーミッションが `srw-rw-rw-` のような形式で表示されます
- このソケットファイルはNginxとUnicornが通信するために使用されます

---

## ステップ3: Nginx設定ファイルの確認

### 3-1. Nginx設定ファイルの場所を確認

通常、Nginx設定ファイルは以下の場所にあります：

```bash
ls -la /etc/nginx/sites-enabled/
```

または

```bash
ls -la /etc/nginx/conf.d/
```

### 3-2. アプリケーション用のNginx設定ファイルを確認

設定ファイル名は通常、アプリケーション名（`furima-46419`）や `default` という名前になっています。

以下のコマンドでファイルを確認します（ファイル名は環境によって異なる場合があります）：

```bash
cat /etc/nginx/sites-enabled/furima-46419
```

または

```bash
cat /etc/nginx/conf.d/furima-46419.conf
```

**確認すべき重要なポイント:**

1. **server_name**: サーバーのドメイン名またはIPアドレスが設定されているか
2. **root**: アプリケーションのpublicディレクトリを指しているか
   ```
   root /var/www/furima-46419/current/public;
   ```
3. **upstream unicorn**: Unicornソケットファイルへのパスが正しいか
   ```
   upstream unicorn {
     server unix:/var/www/furima-46419/current/tmp/sockets/unicorn.sock;
   }
   ```
4. **proxy_pass**: upstream unicornを参照しているか
   ```
   location / {
     proxy_pass http://unicorn;
     ...
   }
   ```

### 3-3. Nginx設定の構文チェック

設定ファイルに問題がないか確認します：

```bash
sudo nginx -t
```

**期待される結果:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

エラーが表示された場合は、エラーメッセージを確認して修正が必要です。

---

## ステップ4: Nginxの動作状態を確認する

### 4-1. Nginxが起動しているか確認

```bash
sudo systemctl status nginx
```

**期待される結果:**
- `Active: active (running)` と表示されれば正常に動作しています

### 4-2. Nginxを再起動（設定を変更した場合）

```bash
sudo systemctl restart nginx
```

---

## ステップ5: ログファイルの確認

### 5-1. Unicornのエラーログを確認

```bash
tail -50 /var/www/furima-46419/shared/log/unicorn.stderr.log
```

エラーがない場合は、何も表示されないか、正常な動作ログのみが表示されます。

### 5-2. Unicornの標準出力ログを確認

```bash
tail -50 /var/www/furima-46419/shared/log/unicorn.stdout.log
```

### 5-3. Railsアプリケーションのログを確認

```bash
tail -50 /var/www/furima-46419/shared/log/production.log
```

### 5-4. Nginxのエラーログを確認

```bash
sudo tail -50 /var/log/nginx/error.log
```

### 5-5. Nginxのアクセスログを確認

```bash
sudo tail -50 /var/log/nginx/access.log
```

---

## ステップ6: ブラウザでの動作確認

### 6-1. サーバーのIPアドレスでアクセス

ブラウザを開き、以下のURLにアクセスします：

```
http://3.115.160.151
```

**期待される動作:**
- アプリケーションのトップページが表示される
- エラーが表示されない

### 6-2. 確認すべきポイント

- ✅ ページが正常に表示される
- ✅ スタイルシート（CSS）が正しく読み込まれている
- ✅ JavaScriptが動作している
- ✅ 画像が表示されている
- ✅ リンクが正常に動作する

### 6-3. エラーが表示される場合

**500 Internal Server Error が表示される場合:**
- UnicornまたはRailsアプリケーションに問題があります
- ステップ5のログを確認してください

**502 Bad Gateway が表示される場合:**
- NginxとUnicornの接続に問題があります
- Unicornが起動しているか、ソケットファイルが正しいか確認してください

**404 Not Found が表示される場合:**
- ルーティングに問題がある可能性があります
- Nginx設定の`root`ディレクトリが正しいか確認してください

---

## ステップ7: トラブルシューティング

### Unicornが起動していない場合

1. **手動でUnicornを起動してみる:**

```bash
cd /var/www/furima-46419/current
$HOME/.rbenv/bin/rbenv exec bundle exec unicorn -c config/unicorn.rb -E production -D
```

2. **エラーメッセージを確認:**
エラーメッセージが表示された場合は、その内容を確認して問題を解決してください。

### Nginx設定を修正した場合

1. **設定ファイルの構文をチェック:**
```bash
sudo nginx -t
```

2. **Nginxを再読み込み:**
```bash
sudo systemctl reload nginx
```

### パーミッションエラーが発生する場合

以下のコマンドでパーミッションを修正します：

```bash
sudo chown -R ec2-user:ec2-user /var/www/furima-46419
sudo chmod -R 755 /var/www/furima-46419
```

---

## よくある質問（FAQ）

### Q1: SSH接続ができない

**A:** 以下を確認してください：
- SSH鍵ファイル（`~/.ssh/my-key-pair.pem`）が存在するか
- 鍵ファイルのパーミッションが正しいか（`chmod 600 ~/.ssh/my-key-pair.pem`）
- サーバーのIPアドレスが正しいか
- セキュリティグループでSSH接続が許可されているか

### Q2: Unicornが起動しない

**A:** 以下を確認してください：
- データベース接続が正常か（`config/database.yml`の設定）
- `master.key`ファイルが存在するか
- ログファイルにエラーが記録されていないか

### Q3: Nginx設定ファイルが見つからない

**A:** 以下のコマンドで検索してください：

```bash
sudo find /etc/nginx -name "*furima*"
```

または、デフォルト設定を確認：

```bash
cat /etc/nginx/nginx.conf
```

---

## 次のステップ

すべての確認が完了したら：
1. アプリケーションの主要機能をテストする
2. パフォーマンスを確認する
3. セキュリティ設定を確認する

以上で、Nginx設定とアプリケーション動作の確認は完了です！

