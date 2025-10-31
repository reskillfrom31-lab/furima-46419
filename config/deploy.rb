# capistranoのバージョンを記載。固定のバージョンを利用し続け、バージョン変更によるトラブルを防止する
lock '3.19.2'

# Capistranoのログの表示に利用する
set :application, 'furima-46419'

# どのリポジトリからアプリをpullするかを指定する
set :repo_url,  'git@github.com:reskillfrom31-lab/furima-46419.git'
set :branch, 'main'

append :linked_files, "config/database.yml", "config/master.key", "config/config.ru"

# バージョンが変わっても共通で参照するディレクトリを指定
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

set :rbenv_type, :user
set :rbenv_ruby, '3.2.0' #カリキュラム通りに進めた場合、’3.2.0’ です

# どの公開鍵を利用してデプロイするか
set :ssh_options, auth_methods: ['publickey'],
                                  keys: ['~/.ssh/my-key-pair.pem'] 

# プロセス番号を記載したファイルの場所
set :unicorn_pid, -> { "#{shared_path}/tmp/pids/unicorn.pid" }

# Unicornの設定ファイルの場所
set :unicorn_config_path, -> { "#{current_path}/config/unicorn.rb" }
set :keep_releases, 5

# デプロイ処理が終わった後、Unicornを再起動するための記述
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:restart'
  end
end

# アセット関連のタスクを実行するロールを指定（デフォルト設定を明示的に指定）
set :assets_roles, [:web, :app]

# プリコンパイル時に RAILS_ENV を確実に production に設定
set :rails_env, :production

namespace :deploy do
  namespace :assets do
    desc 'Force environment loading before assets:precompile to fix NoMethodError'
    before :precompile, :force_environment_check do
      on roles(:app) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            # assets:environment を実行し、Rails環境（特にRails.logger）をロードします。
            execute :bundle, :exec, :rake, 'assets:environment'
          end
        end
      end
    end
  end
end