require "active_support/core_ext/integer/time"

Rails.application.configure do
  
  Bullet.enable = true
  Bullet.alert = true # Hiển thị cảnh báo qua hộp thoại JavaScript trong trình duyệt
  Bullet.bullet_logger = true # Ghi cảnh báo vào file log/bullet.log
  Bullet.console = true # Ghi cảnh báo vào console của trình duyệt (F12 Developer Tools)
  # Bullet.growl = false # Cảnh báo qua Growl (nếu đã cài đặt)
  Bullet.rails_logger = true # Ghi cảnh báo vào log của Rails (log/development.log)
  Bullet.raise = false # Gây ra exception nếu phát hiện N+1 (hữu ích cho CI/CD hoặc test)
  Bullet.n_plus_one_query_enable = true # Kích hoạt phát hiện N+1 Query
  Bullet.unused_eager_loading_enable = true # Phát hiện eager loading không cần thiết
  Bullet.counter_cache_enable = true # Phát hiện trường hợp nên dùng counter cache
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  host = Settings.dig(:user_mailer, :host)
  config.action_mailer.default_url_options = { host: host, protocol: Settings.user_mailer.protocol }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
    address:              Settings.user_mailer.address,
    port:                 Settings.user_mailer.port,
    user_name:            ENV["GMAIL_USERNAME"],
    password:             ENV["GMAIL_PASSWORD"],
    authentication:       Settings.user_mailer.authentication_method,
    enable_starttls_auto: true
  }

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true
end
