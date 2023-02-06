# Decidim::Vocdoni

:warning: This module is under development and is not ready to be used in production.

An elections component for decidim's participatory spaces based on the [Vocdoni][vocdoni-app-url].

Vocdoni is a secure digital voting solution using decentralized technologies.
The voting protocol which powers the platform is designed to be universally verifiable,
secure, and resistant to attack and censorship through the use of blockchain technology,
together with decentralized technologies and cryptographic mechanisms, such as zero-knowledge proofs.

This will allow administrators to set-up elections in the Vocdoni blockchain (aka Vochain),
using the [Vocdoni SDK][vocdoni-sdk-url].

## Usage

Vocdoni will be available as a Component for a Participatory Space.

## Installation

This module is only compatible with Decidim v0.27.

Add this line to your application's Gemfile:

```ruby
gem "decidim-vocdoni", github: "decidim-vocdoni/decidim-module-vocdoni"
```

And then execute:

```bash
bundle install
bin/rails decidim_vocdoni:install:migrations db:migrate
```

For some of the Elections status changes, you'll need to add a task to the schedule tasks
configuration of your hosting provider.

In a GNU/Linux server, can configure it with `crontab -e`, for instance if you've created
your Decidim application on /home/user/decidim_application and you want that the Elections
status are checked every 15 minutes, you can do it with this configuration:

```crontab
# Change Elections status on decidim-vocdoni
0/15 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bin/rails decidim_vocdoni:change_election_status
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

[vocdoni-app-url]: https://vocdoni.app/
[vocdoni-sdk-url]: https://vocdoni.io/
