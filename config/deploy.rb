# config/deploy.rb

# capistranoのバージョンを記載。固定のバージョンを利用し続け、バージョン変更によるトラブルを防止する
lock '3.19.2'

# Capistranoのログの表示に利用する
set :application, 'furima-46419'

# どのリポジトリからアプリをpullするかを指定する
set :repo_url, 'git@github.com:reskillfrom31-lab/furima-46419.git'
set :branch, 'main'

# シンボリックリンクを貼るファイル（共有ファイル）
append :linked_files, "config/database.yml", "config/master.key", "config/config.ru"

# シンボボリックリンクを貼るディレクトリ（共有ディレクトリ）
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# rbenvの設定
set :rbenv_type, :user
set :rbenv_ruby, '3.2.0' # Rubyのバージョン

# どの公開鍵を利用してデプロイするか
set :ssh_options, auth_methods: ['publickey'],
                  keys: ['~/.ssh/my-key-pair.pem'] 

# Unicornの設定
set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }
set :unicorn_config_path, -> { "#{current_path}/config/unicorn.rb" }
set :keep_releases, 5 # 保持するリリースの数

# デプロイ処理が終わった後、Unicornを再起動するための記述
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
	task :restart do
		invoke 'unicorn:restart'
	end
end

# アセット関連の設定 (Capistranoの自動実行を無効化するため、assets_rolesの設定は削除しました)
set :rails_env, :production # プリコンパイル時に RAILS_ENV を確実に production に設定

# ----------------------------------------------------------------------
# アセットプリコンパイル時の NoMethodError 対策 (Capistrano自動実行を回避)
# ----------------------------------------------------------------------
# Capistranoが自動で実行する assets:precompile の複雑な環境ロードを避け、
# デプロイフロー内の適切な位置で手動で assets:precompile を呼び出します。

# 新しいカスタムタスクを定義し、デプロイフローに手動で組み込む
namespace :deploy do
  desc 'Manual assets precompile to ensure environment is fully loaded'
  task :custom_precompile do
    on roles(:app) do
      within release_path do
        # Capistranoの `with` ブロックを復活させ、RAILS_ENVを強制的に設定します。
        with rails_env: fetch(:rails_env) do
          # 標準的な `bundle exec rake assets:precompile` で実行します。
          execute :bundle, :exec, :rake, 'assets:precompile'
        end
      end
    end
  end
end

# Gemのインストール（bundler:install）が完了した直後に、手動でプリコンパイルを実行します。
after 'bundler:install', 'deploy:custom_precompile'