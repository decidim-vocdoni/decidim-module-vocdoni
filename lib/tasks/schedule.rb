# frozen_string_literal: true

app_path = "development_app"

every 1.minute do
  command "cd #{app_path} && bundle exec rake decidim_vocdoni:send_batch_updates"
end
