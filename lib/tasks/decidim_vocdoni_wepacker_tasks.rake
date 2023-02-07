# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_vocdoni do
  namespace :webpacker do
    desc "Installs Vocodoni webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_vocdoni_npm
    end

    desc "Adds Vocodoni dependencies in package.json"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_vocdoni_npm
    end

    def install_vocdoni_npm
      vocdoni_npm_dependencies.each do |type, packages|
        puts "install NPM packages. You can also do this manually with this command:"
        puts "npm i --save-#{type} #{packages.join(" ")}"
        system! "npm i --save-#{type} #{packages.join(" ")}"
      end
    end

    def vocdoni_npm_dependencies
      @vocdoni_npm_dependencies ||= begin
        package_json = JSON.parse(File.read(vocdoni_path.join("package.json")))

        {
          prod: package_json["dependencies"].map { |package, version| "#{package}@#{version}" },
          dev: package_json["devDependencies"].map { |package, version| "#{package}@#{version}" }
        }.freeze
      end
    end

    def vocdoni_path
      @vocdoni_path ||= Pathname.new(vocdoni_gemspec.full_gem_path) if Gem.loaded_specs.has_key?(gem_name)
    end

    def vocdoni_gemspec
      @vocdoni_gemspec ||= Gem.loaded_specs[gem_name]
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def gem_name
      "decidim-vocdoni"
    end
  end
end
