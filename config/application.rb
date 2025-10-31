require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Furima46419
  class Application < Rails::Application
    # **【重要】NoMethodError: private method `warn' called for nil:NilClass 対策**
    # Capistranoデプロイ時の assets:precompile において、SprocketsがRails.loggerの初期化より
    # 早くロードされ、nilに対してメソッドを呼び出してしまう問題を回避します。
    config.before_initialize do
      # ロガーが未定義の場合、標準出力に書き出すダミーのロガーを強制的に設定します。
      unless Rails.logger
        require 'logger'
        Rails.logger = Logger.new(STDOUT) 
        Rails.logger.level = Logger::WARN # ログレベルを上げて、不要な出力を抑制します
      end
    end
    
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