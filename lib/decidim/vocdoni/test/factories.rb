# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :vocdoni_wallet, class: "Decidim::Vocdoni::Wallet" do
    organization
    private_key { "0x0000000000000000000000000000000000000000000000000000000000000001" }
  end

  factory :vocdoni_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :vocdoni).i18n_name }
    manifest_name { :vocdoni }
    participatory_space { association :participatory_process, :with_steps }
  end

  factory :vocdoni_election, class: "Decidim::Vocdoni::Election" do
    transient do
      organization { association :organization }
    end

    upcoming
    title { Decidim::Faker::Localized.sentence(word_count: 3) }
    description { Decidim::Faker::Localized.paragraph(sentence_count: 3) }
    stream_uri { Faker::Internet.url }
    end_time { 2.weeks.from_now }
    published_at { nil }
    blocked_at { nil }
    status { nil }
    election_type do
      {
        "dynamic_census" => false,
        "interruptible" => true,
        "secret_until_the_end" => true,
        "anonymous" => false
      }
    end
    component { association :vocdoni_component, organization: }

    trait :configured do
      status { "created" }
      vocdoni_election_id { Faker::Blockchain::Ethereum.address }
    end

    trait :with_internal_census do
      internal_census { true }
    end

    trait :upcoming do
      start_time { 1.day.from_now }
    end

    trait :started do
      status { "vote" }
      start_time { 2.days.ago }
    end

    trait :auto_start do
      start_time { 15.minutes.from_now }
    end

    trait :manual_start do
      start_time { nil }
    end

    trait :ongoing do
      blocked_at { Time.current }
      started
    end

    trait :vote do
      published
      ongoing
      status { "vote" }
    end

    trait :results_published do
      status { "results_published" }

      after(:build) do |election, _evaluator|
        election.questions << build(:vocdoni_question, :with_votes, election:, weight: 1)
        election.questions << build(:vocdoni_question, :with_votes, election:, weight: 1)
        election.questions << build(:vocdoni_question, :with_votes, election:, weight: 1)
      end
    end

    trait :finished do
      status { "vote_ended" }
      started
      complete
      end_time { 1.day.ago }
      blocked_at { Time.current }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :paused do
      published

      status { "paused" }
    end

    trait :canceled do
      published

      status { "canceled" }
    end

    trait :simple do
      after(:build) do |election, _evaluator|
        election.questions << build(:vocdoni_question, :simple, election:, weight: 1)
      end
    end

    trait :complete do
      after(:build) do |election, _evaluator|
        election.questions << build(:vocdoni_question, :simple, election:, weight: 1)
        election.questions << build(:vocdoni_question, :simple, election:, weight: 1)
        election.questions << build(:vocdoni_question, :simple, election:, weight: 1)
      end
    end

    trait :with_census do
      after(:build) do |election, _evaluator|
        election.voters << build(:vocdoni_voter, :with_wallet, election:)
        election.voters << build(:vocdoni_voter, :with_wallet, election:)
        election.voters << build(:vocdoni_voter, :with_wallet, election:)
        election.voters << build(:vocdoni_voter, :with_wallet, election:)
        election.voters << build(:vocdoni_voter, :with_wallet, election:)
      end
    end

    # everything in place except the vocdoni_election_id
    trait :ready_for_setup do
      upcoming
      published
      complete
      with_census
      with_photos
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

  factory :vocdoni_question, class: "Decidim::Vocdoni::Question" do
    transient do
      more_information { false }
      answers { 3 }
    end

    election factory: [:vocdoni_election]
    title { generate_localized_title }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { generate_localized_title } }
    weight { Faker::Number.number(digits: 1) }

    trait :complete do
      after(:build) do |question, evaluator|
        overrides = { question: }
        question.answers = build_list(:vocdoni_election_answer, evaluator.answers, overrides)
      end
    end

    trait :with_votes do
      after(:build) do |question, evaluator|
        overrides = { question: }
        overrides[:description] = nil unless evaluator.more_information
        question.answers = build_list(:vocdoni_election_answer, evaluator.answers, :with_votes, overrides)
      end
    end

    trait :simple do
      complete
    end
  end

  factory :vocdoni_election_answer, class: "Decidim::Vocdoni::Answer" do
    question factory: [:vocdoni_question]
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

    trait :with_votes do
      votes { Faker::Number.number(digits: 2) }
    end
  end

  factory :vocdoni_voter, class: "Decidim::Vocdoni::Voter" do
    email { generate(:email) }
    token { Faker::String.random(length: 4) }
    election factory: [:vocdoni_election]

    trait :with_wallet do
      wallet_address { Faker::Blockchain::Ethereum.address }
    end
  end
end
