# config/unicorn.rb

#サーバ上でのアプリケーションコードが設置されているディレクトリを変数に入れておく
# currentディレクトリ (例: /var/www/furima-46419/current) を参照するように修正
app_path = File.expand_path('..', __FILE__) # 「../」を一つに修正

#アプリケーションサーバの性能を決定する
worker_processes 1

#アプリケーションの設置されているディレクトリを指定
working_directory app_path

# Rackアプリの起動ファイルを明示的に指定
# Capistranoでは current/config.ru がアプリのルートに置かれる
# rackup "#{app_path}/config.ru"

#Unicornの起動に必要なファイルの設置場所を指定
# Capistranoは current/tmp/pids を shared/tmp/pids にリンクするため、
# ここでは「/tmp/pids/unicorn.pid」とする
pid "#{app_path}/tmp/pids/unicorn.pid"

#ポート番号を指定
listen File.expand_path('tmp/sockets/unicorn.sock', app_path), :backlog => 64, :mode => 0666

#エラーのログを記録するファイルを指定
stderr_path File.expand_path('log/unicorn.stderr.log', app_path)

#通常のログを記録するファイルを指定
stdout_path File.expand_path('log/unicorn.stdout.log', app_path)

#Railsアプリケーションの応答を待つ上限時間を設定
timeout 60

#以下は応用的な設定なので説明は割愛

preload_app true
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

check_client_connection false

run_once = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  if run_once
    run_once = false # prevent from firing again
  end

  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exist?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH => e
      logger.error e
    end
  end
end

after_fork do |_server, _worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end