# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:vocdoni) do |component|
  component.engine = Decidim::Vocdoni::Engine
  component.admin_engine = Decidim::Vocdoni::AdminEngine
  component.icon = "media/images/decidim_vocdoni.svg"
  component.permissions_class_name = "Decidim::Vocdoni::Permissions"
  component.query_type = "Decidim::Vocdoni::VocdoniElectionsType"

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

  component.register_stat :elections_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    elections = Decidim::Vocdoni::FilteredElections.for(components, start_at, end_at)
    elections.published.count
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
        end_time: 3.weeks.from_now + 4.hours,
        published_at: Faker::Boolean.boolean(true_ratio: 0.5) ? 1.week.ago : nil
      }

      election = Decidim.traceability.create!(
        Decidim::Vocdoni::Election,
        admin_user,
        params,
        visibility: "all"
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: election,
        content_type: "image/jpeg",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(__dir__, "seeds", "city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ) # Keep after attached_to
      )

      rand(1...4).times do
        question = Decidim.traceability.create!(
          Decidim::Vocdoni::Question,
          admin_user,
          {
            election: election,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            weight: Faker::Number.number(digits: 1)
          },
          visibility: "all"
        )

        rand(1...5).times do
          answer = Decidim.traceability.create!(
            Decidim::Vocdoni::Answer,
            admin_user,
            {
              question: question,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              weight: Faker::Number.number(digits: 1)
            },
            visibility: "all"
          )
        end
      end
    end
  end
end
