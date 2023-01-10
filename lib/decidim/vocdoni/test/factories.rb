# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :vocdoni_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :vocdoni).i18n_name }
    manifest_name { :vocdoni }
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :election, class: "Decidim::Vocdoni::Election" do
    transient do
      organization { build(:organization) }
    end

    upcoming
    title { Decidim::Faker::Localized.sentence(word_count: 3) }
    description { Decidim::Faker::Localized.paragraph(sentence_count: 3) }
    stream_uri { Faker::Internet.url }
    end_time { 2.weeks.from_now }
    published_at { nil }
    blocked_at { nil }
    status { nil }
    component { create(:vocdoni_component, organization: organization) }

    trait :upcoming do
      start_time { 1.day.from_now }
    end

    trait :started do
      start_time { 2.days.ago }
    end

    trait :ongoing do
      started
    end

    trait :finished do
      started
      end_time { 1.day.ago }
      blocked_at { Time.current }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :complete do
      after(:build) do |election, _evaluator|
        election.questions << build(:question, :yes_no, election: election, weight: 1)
        election.questions << build(:question, :candidates, election: election, weight: 3)
        election.questions << build(:question, :projects, election: election, weight: 2)
      end
    end

    trait :ready_for_setup do
      upcoming
      published
      complete
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |election, evaluator|
        evaluator.photos_number.times do
          election.attachments << create(
            :attachment,
            :with_image,
            attached_to: election
          )
        end
      end
    end
  end

  factory :question, class: "Decidim::Vocdoni::Question" do
    transient do
      answers { 3 }
    end

    election
    title { generate_localized_title }
    weight { Faker::Number.number(digits: 1) }

    trait :complete do
      after(:build) do |question, evaluator|
        overrides = { question: question }
        question.answers = build_list(:election_answer, evaluator.answers, overrides)
      end
    end

    trait :yes_no do
      complete
    end

    trait :candidates do
      complete
      answers { 10 }
    end

    trait :projects do
      complete
      answers { 6 }
    end
  end

  factory :election_answer, class: "Decidim::Vocdoni::Answer" do
    question
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    weight { Faker::Number.number(digits: 1) }

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |election, evaluator|
        evaluator.photos_number.times do
          election.attachments << create(
            :attachment,
            :with_image,
            attached_to: election
          )
        end
      end
    end
  end
end
