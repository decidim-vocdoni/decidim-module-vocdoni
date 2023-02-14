# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.27.1"

gem "decidim", DECIDIM_VERSION
gem "decidim-vocdoni", path: "."

gem "bootsnap", "~> 1.7"
gem "faker", "~> 2.14"
gem "puma", "~> 5.6.2"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker", "~> 1.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", "~> 4.2"
  gem "i18n-tasks", "~> 0.9.37"
end

group :test do
  gem "codecov", "~> 0.6.0", require: false
end
