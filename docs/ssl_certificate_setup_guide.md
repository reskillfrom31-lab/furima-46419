# SSL証明書設定ガイド（Let's Encrypt使用）

このガイドでは、Let's Encryptを使って無料のSSL証明書を取得し、NginxでHTTPSを有効にする手順を説明します。

## 📋 目次

1. [SSL証明書とは？](#ssl証明書とは)
2. [前提条件の確認](#前提条件の確認)
3. [Certbotのインストール](#certbotのインストール)
4. [ドメイン名の設定](#ドメイン名の設定)
5. [SSL証明書の取得](#ssl証明書の取得)
6. [Nginx設定の更新](#nginx設定の更新)
7. [Rails設定の更新](#rails設定の更新)
8. [動作確認](#動作確認)
9. [証明書の自動更新設定](#証明書の自動更新設定)

---

## 🔒 SSL証明書とは？

### SSL証明書の役割

- **暗号化通信**: ブラウザとサーバー間の通信を暗号化します
- **安全性**: データの盗聴や改ざんを防ぎます
- **信頼性**: ブラウザに「このサイトは安全です」と表示されます
- **SEO**: 検索エンジンで優先的に表示されることがあります

### HTTPSとは？

- **HTTP**: 暗号化されていない通信（`http://`）
- **HTTPS**: 暗号化された通信（`https://`）
- SSL証明書を設定すると、HTTPSでアクセスできるようになります

---

## ✅ 前提条件の確認

SSL証明書を取得するには、**ドメイン名**が必要です。

### ドメイン名がある場合

✅ このガイドに従って設定してください

### ドメイン名がない場合（IPアドレスのみ）

❌ **Let's EncryptはIPアドレスのみでは証明書を発行できません**

**選択肢：**
1. **無料ドメインを取得する**
   - Freenom（.tk, .ml, .ga, .cfなど）
   - ただし、信頼性が低い場合があります

2. **有料ドメインを取得する**
   - 一般的には月額数百円程度
   - 例：お名前.com、ムームードメインなど

3. **開発・テスト環境としてHTTPのまま使用する**
   - 本番環境ではない場合は、この方法も可能です
   - ただし、セキュリティ上のリスクがあります

---

## 📝 ステップ1: ドメイン名の設定

### ドメイン名をDNSに設定する

ドメイン名を取得したら、以下のようにDNS設定を行います：

1. **Aレコードを設定**
   - ホスト名: `@` または空白
   - 値: `3.115.160.151`（サーバーのIPアドレス）
   - TTL: デフォルト（または3600）

2. **設定例**
   ```
   ドメイン名: example.com
   Aレコード: example.com → 3.115.160.151
   ```

3. **DNS反映の確認**
   DNS設定が反映されるまで、数分〜24時間かかることがあります。
   
   反映を確認するコマンド（ローカルPCのターミナルで実行）：
   ```bash
   nslookup example.com
   ```
   または
   ```bash
   dig example.com
   ```
   
   IPアドレスが `3.115.160.151` と表示されれば、設定完了です。

---

## 📦 ステップ2: Certbotのインストール

Certbotは、Let's Encryptの証明書を取得・更新するためのツールです。

### Amazon Linux 2でのインストール手順

サーバーにSSH接続して、以下のコマンドを順番に実行します：

```bash
# 1. サーバーに接続
ssh -i ~/.ssh/my-key-pair.pem ec2-user@3.115.160.151

# 2. EPELリポジトリを有効化（Certbotに必要）
sudo amazon-linux-extras install epel -y

# 3. Certbotをインストール
sudo yum install -y certbot python3-certbot-nginx

# 4. インストール確認
certbot --version
```

**期待される結果:**
```
certbot 2.x.x
```

---

## 🔐 ステップ3: SSL証明書の取得

### 3-1. Nginxを停止（一時的）

証明書取得中はNginxを停止する必要があります：

```bash
sudo systemctl stop nginx
```

### 3-2. 証明書を取得

以下のコマンドで証明書を取得します（`example.com` を実際のドメイン名に置き換えてください）：

```bash
sudo certbot certonly --standalone -d example.com
```

**実行時の注意点:**

1. **メールアドレスの入力**
   - Let's Encryptから通知メールが届きます
   - 重要なお知らせがある場合に使用されます

2. **利用規約への同意**
   - `(A)gree` と入力してEnter

3. **メールアドレスの共有に関する質問**
   - `(Y)es` または `(N)o` を選択
   - どちらでも問題ありません

4. **成功メッセージ**
   ```
   Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/example.com/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/example.com/privkey.pem
   ```

### 3-3. Nginxを再起動

```bash
sudo systemctl start nginx
```

---

## ⚙️ ステップ4: Nginx設定の更新

証明書を取得したら、Nginx設定をHTTPS対応に更新します。

### 4-1. 現在の設定をバックアップ

```bash
sudo cp /etc/nginx/conf.d/rails.conf /etc/nginx/conf.d/rails.conf.backup
```

### 4-2. 設定ファイルを編集

```bash
sudo vi /etc/nginx/conf.d/rails.conf
```

または

```bash
sudo nano /etc/nginx/conf.d/rails.conf
```

### 4-3. HTTPS設定を追加

以下のように設定ファイルを更新します（`example.com` を実際のドメイン名に置き換えてください）：

```nginx
upstream app_server {
  server unix:/var/www/furima-46419/current/tmp/sockets/unicorn.sock;
}

# HTTPをHTTPSにリダイレクト
server {
  listen 80;
  server_name example.com 3.115.160.151;
  
  # HTTPからのアクセスをHTTPSにリダイレクト
  return 301 https://$server_name$request_uri;
}

# HTTPS設定
server {
  listen 443 ssl http2;
  server_name example.com 3.115.160.151;

  # SSL証明書のパス
  ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

  # SSL設定（セキュリティを強化）
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  client_max_body_size 2g;

  root /var/www/furima-46419/current/public;

  location / {
    try_files $uri @unicorn;
  }

  location ^~ /assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
    root /var/www/furima-46419/current/public;
  }

  location @unicorn {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://app_server;
  }

  error_page 500 502 503 504 /500.html;
}
```

### 4-4. viエディタでの編集手順

1. `sudo vi /etc/nginx/conf.d/rails.conf` を実行
2. `i` キーで編集モードに入る
3. 上記の設定内容に書き換える（`example.com` を実際のドメイン名に変更）
4. `Esc` キーで編集モードを終了
5. `:wq` と入力してEnter（保存して終了）

### 4-5. 設定の構文チェック

```bash
sudo nginx -t
```

**期待される結果:**
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### 4-6. Nginxを再読み込み

```bash
sudo systemctl reload nginx
```

---

## 🔧 ステップ5: Rails設定の更新

SSL証明書を設定したので、Railsの `force_ssl` を再度有効化します。

### 5-1. ローカルで設定ファイルを編集

GitHub Desktopを開き、以下のファイルを編集します：

**ファイル:** `config/environments/production.rb`

以下の行を変更：

```ruby
# 修正前
config.force_ssl = false

# 修正後
config.force_ssl = true
```

### 5-2. 変更をコミット・プッシュ

1. GitHub Desktopで変更を確認
2. コミットメッセージ: `SSL証明書設定に伴いforce_sslを有効化`
3. コミット・プッシュ

### 5-3. デプロイ

```bash
cd ~/projects/furima-46419
bundle exec cap production deploy
```

---

## ✅ ステップ6: 動作確認

### 6-1. HTTPでアクセス（自動的にHTTPSにリダイレクトされるか確認）

ブラウザで以下のURLにアクセス：
```
http://example.com
```

**期待される動作:**
- 自動的に `https://example.com` にリダイレクトされる

### 6-2. HTTPSで直接アクセス

```
https://example.com
```

**確認ポイント:**
- ✅ ページが正常に表示される
- ✅ ブラウザのアドレスバーに鍵アイコン（🔒）が表示される
- ✅ 「安全」または「Secure」と表示される
- ✅ エラーが表示されない

### 6-3. SSL証明書の情報を確認

ブラウザのアドレスバーの鍵アイコンをクリックして、証明書情報を確認できます。

---

## 🔄 ステップ7: 証明書の自動更新設定

Let's Encryptの証明書は90日間有効です。自動更新を設定しましょう。

### 7-1. 更新テスト

まず、更新が正常に動作するかテストします：

```bash
sudo certbot renew --dry-run
```

**期待される結果:**
```
The following certificates are not due for renewal yet:
...
```

### 7-2. 自動更新の設定

Certbotは自動的に更新スクリプトを設定してくれますが、確認します：

```bash
# 更新スクリプトの確認
sudo systemctl list-timers | grep certbot
```

または、cronジョブが設定されているか確認：

```bash
sudo crontab -l
```

### 7-3. 手動更新（必要に応じて）

証明書の有効期限が近づいたら、手動で更新できます：

```bash
sudo certbot renew
sudo systemctl reload nginx
```

---

## ❓ よくある質問（FAQ）

### Q1: ドメイン名がない場合、SSL証明書は設定できない？

**A:** Let's Encryptはドメイン名が必要です。IPアドレスのみでは証明書を発行できません。

### Q2: 証明書はいつ期限切れになる？

**A:** Let's Encryptの証明書は90日間有効です。自動更新が設定されていれば、自動的に更新されます。

### Q3: 証明書の更新に失敗したら？

**A:** 手動で更新を試みてください：
```bash
sudo certbot renew
```

### Q4: 複数のドメイン名を使いたい

**A:** 証明書取得時に複数のドメインを指定できます：
```bash
sudo certbot certonly --standalone -d example.com -d www.example.com
```

### Q5: HTTPとHTTPSの両方を許可したい

**A:** Nginx設定でHTTPのserverブロックを削除し、HTTPSのみにします。HTTPからHTTPSへのリダイレクト設定を追加することを推奨します。

---

## 🎉 完了

SSL証明書の設定が完了しました！

これで、安全なHTTPS通信でアプリケーションにアクセスできるようになりました。

---

## 📚 参考情報

- [Let's Encrypt公式サイト](https://letsencrypt.org/)
- [Certbot公式ドキュメント](https://certbot.eff.org/)
- [Nginx SSL設定](https://nginx.org/en/docs/http/configuring_https_servers.html)

