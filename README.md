# Decidim::Vocdoni

[![[CI] Lint](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/lint.yml/badge.svg)](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/lint.yml)
[![[CI] Tests](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/test.yml/badge.svg)](https://github.com/decidim-vocdoni/decidim-module-vocdoni/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/126b8ece66b8292802f3/maintainability)](https://codeclimate.com/github/decidim-vocdoni/decidim-module-vocdoni/maintainability)
[![codecov](https://codecov.io/gh/decidim-vocdoni/decidim-module-vocdoni/branch/main/graph/badge.svg?token=LRT4MJBNVY)](https://codecov.io/gh/decidim-vocdoni/decidim-module-vocdoni)


:warning: This module is under development and is not ready to be used in production.

An elections component for decidim's participatory spaces based on the [Vocdoni](https://vocdoni.app).

Vocdoni is a secure digital voting solution using decentralized technologies.
The voting protocol which powers the platform is designed to be universally verifiable,
secure, and resistant to attack and censorship through the use of blockchain technology,
together with decentralized technologies and cryptographic mechanisms, such as zero-knowledge proofs.

This will allow administrators to set-up elections in the Vocdoni blockchain (aka Vochain),
using the [Vocdoni SDK](https://vocdoni.io/).

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
bundle
bin/rails decidim_vocdoni:install:migrations
bin/rails decidim_vocdoni:webpacker:install
bin/rails db:migrate
```

For some of the Elections status changes, you'll need to add a task to the schedule tasks
configuration of your hosting provider.

In a GNU/Linux server, can configure it with `crontab -e`, for instance if you've created
your Decidim application on /home/user/decidim_application and you want that the Elections
status are checked every 15 minutes, you can do it with this configuration:

```crontab
# Change Elections status on decidim-vocdoni
0/15 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bin/rails decidim_vocdoni:change_election_status > /dev/null
```

## Configuration

By default, the module is configured to read the configuration from ENV variables.

Currently, the following ENV variables are supported:

| ENV variable | Description | Default value |
| ------------ | ----------- | ------------- |
| VOCDONI_API_ENDPOINT_ENV | The environment of the Vocdoni API. Only two values are accepted: `dev`, `stg`. Read more on
[Vocdoni SDK Usage Environment](https://github.com/vocdoni/vocdoni-sdk#environment)
  | `stg` |
| VOCDONI_MINUTES_BEFORE_START | How many minutes should the setup be run before the election starts | `10` |


It is also possible to configure the module using the `decidim-vocdoni` initializer:

```ruby
Decidim::Vocdoni.configure do |config|
  config.api_endpoint_env = "stg"
  config.setup_minimum_minutes_before_start = 20
end
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

### Developing

To start contributing to this project, first:

- Install the basic dependencies (such as Ruby and PostgreSQL)
- Clone this repository

Decidim's main repository also provides a Docker configuration file if you
prefer to use Docker instead of installing the dependencies locally on your
machine.

You can create the development app by running the following commands after
cloning this project:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake development_app
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

Then to test how the module works in Decidim, start the development server:

```bash
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bin/rails s
```

Note that `bin/rails` is a convenient wrapper around the command `cd development_app; bundle exec rails`.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add the environment variables to the root directory of the project in a file
named `.rbenv-vars`. If these are defined for the environment, you can omit
defining these in the commands shown above.

#### Webpacker notes

As latest versions of Decidim, this repository uses Webpacker for Rails. This means that compilation
of assets is required every time a Javascript or CSS file is modified. Usually, this happens
automatically, but in some cases (specially when actively changes that type of files) you want to
speed up the process.

To do that, start in a separate terminal than the one with `bin/rails s`, and BEFORE it, the following command:

```bash
bin/webpack-dev-server
```

#### Code Styling

Please follow the code styling defined by the different linters that ensure we
are all talking with the same language collaborating on the same project. This
project is set to follow the same rules that Decidim itself follows.

[Rubocop](https://rubocop.readthedocs.io/) linter is used for the Ruby language.

You can run the code styling checks by running the following commands from the
console:

```bash
bundle exec rubocop
```

To ease up following the style guide, you should install the plugin to your
favorite editor, such as:

- Atom - [linter-rubocop](https://atom.io/packages/linter-rubocop)
- Sublime Text - [Sublime RuboCop](https://github.com/pderichs/sublime_rubocop)
- Visual Studio Code - [Rubocop for Visual Studio Code](https://github.com/misogi/vscode-ruby-rubocop)

#### Non-Ruby Code Styling

There are other linters for Javascript and CSS. These run using NPM packages. You can
run the following commands:

1. `npm run lint`: Runs the linter for Javascript files.
2. `npm run lint-fix`: Automatically fix issues for Javascript files (if possible).
3. `npm run stylelint`: Runs the linter for SCSS files.
4. `npm run stylelint-fix`: Automatically fix issues for SCSS files (if possible).

### Testing

To run the tests run the following in the gem development path:

```bash
bundle
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rake test_app
DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password> bundle exec rspec
```

Note that the database user has to have rights to create and drop a database in
order to create the dummy test app database.

In case you are using [rbenv](https://github.com/rbenv/rbenv) and have the
[rbenv-vars](https://github.com/rbenv/rbenv-vars) plugin installed for it, you
can add these environment variables to the root directory of the project in a
file named `.rbenv-vars`. In this case, you can omit defining these in the
commands shown above.

### Test code coverage

Code coverage report is generated automatically after running the test suite, in a folder
named `coverage` in the project root which contains the code coverage report. It's
available at the file ./coverage/index.html. If you're using GNU/Linux, you can open
it with `xdg-open ./coverage/index.html`.

### Localization

If you would like to see this module in your own language, you can help with its
translation at Crowdin:

https://crowdin.com/project/decidim-module-vocdoni

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.
See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).

As this module works with the Vocdoni SDK, see https://vocdoni.io/ for more information about their open source licenses.
