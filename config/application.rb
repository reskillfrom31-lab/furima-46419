require_relative "boot"

require "rails/all"

# **【重要】Capistrano/Sprockets assets:precompile NoMethodError/NameError 対策**
# SprocketsがRails.loggerの初期化より早くロードされ、nilに対してメソッドを呼び出す
# 問題を回避するため、`require "rails/all"`後、Bundlerによるgemロード前に
# ロガーを強制的に設定します。
if !Rails.logger
  require 'logger'
  # Rakeタスク実行時に logger が nil の場合に、標準出力を使うロガーを仮設定
  Rails.logger = Logger.new(STDOUT)
  # ログレベルを上げて、assets:precompile実行時の不要な大量出力を抑制します
  Rails.logger.level = Logger::WARN
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Furima46419
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1
    config.active_storage.variant_processor = :mini_magick

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end