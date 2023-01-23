# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/vocdoni/version"

Gem::Specification.new do |s|
  s.version = Decidim::Vocdoni.version
  s.authors = ["Andrés Pereira de Lucena"]
  s.email = ["andreslucena@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim-vocdoni/decidim-module-vocdoni"
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-vocdoni"
  s.summary = "A decidim vocdoni module"
  s.description = "An elections component for decidim's participatory spaces based on the Vocdoni SDK."

  s.files = Dir["{app,config,lib,db}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Vocdoni.version
end
