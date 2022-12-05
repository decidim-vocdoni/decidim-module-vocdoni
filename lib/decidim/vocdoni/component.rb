# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:vocdoni) do |component|
  component.engine = Decidim::Vocdoni::Engine
  component.admin_engine = Decidim::Vocdoni::AdminEngine
  component.icon = "media/images/decidim_vocdoni.svg"
  component.permissions_class_name = "Decidim::Vocdoni::Permissions"

  # component.on(:before_destroy) do |instance|
  #   # Code executed before removing the component
  # end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.settings(:step) do |settings|
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:election) do |resource|
    resource.model_class_name = "Decidim::Vocdoni::Election"
    resource.card = "decidim/vocdoni/election"
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :vocdoni).i18n_name,
      manifest_name: :vocdoni,
      published_at: Time.current,
      participatory_space: participatory_space
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    3.times do
      params = {
        component: component,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        stream_uri: Faker::Internet.url,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours
      }

      Decidim.traceability.create!(
        Decidim::Vocdoni::Election,
        admin_user,
        params,
        visibility: "all"
      )
    end
  end
end
