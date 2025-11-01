# Capistranoのコアとなる setup と deploy を最初にロードします
require "capistrano/setup"
require "capistrano/deploy"

# SCM Deprecation Warning (非推奨警告) 対策
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# デプロイに必要な各種プラグインのロード
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
# require 'capistrano/rails/migrations'
require 'capistrano3/unicorn'

# lib/capistrano/tasks 以下のカスタムRakeタスクをインポート
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
