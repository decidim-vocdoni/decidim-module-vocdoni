# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/vocdoni/version"

DECIDIM_VERSION = Decidim::Vocdoni::DECIDIM_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-vocdoni", path: "."

gem "bootsnap", "~> 1.7"
gem "faker", "~> 3.2"
gem "puma", "~> 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  # se if we can skip this version lock in the future, related to this
  # https://github.com/decidim/decidim/pull/12629
  gem "bullet", "~> 7.0", "< 7.1.0"
  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "i18n-tasks", "~> 1.0"
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker", "~> 1.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "codecov", require: false
end
