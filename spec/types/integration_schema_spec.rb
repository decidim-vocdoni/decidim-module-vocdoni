# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/component_context"

describe "Decidim::Api::QueryType" do
  include_context "with a graphql decidim component"
  let(:component_type) { "Vocdoni" }
  let!(:current_component) { create :vocdoni_component, participatory_space: participatory_process }
  let!(:election) { create(:vocdoni_election, :published, :finished, component: current_component) }

  let(:election_single_result) do
    {
      "attachments" => [],
      "status" => election.status,
      "blocked" => election.blocked?,
      "createdAt" => election.created_at.iso8601.to_s.gsub("Z", "+00:00"),
      "description" => { "translation" => election.description[locale] },
      "streamUri" => election.stream_uri,
      "endTime" => election.end_time.iso8601.to_s.gsub("Z", "+00:00"),
      "id" => election.id.to_s,
      "publishedAt" => election.published_at.iso8601.to_s.gsub("Z", "+00:00"),

      "questions" => election.questions.order(:id).map do |q|
        {
          "answers" => q.answers.order(:id).map do |a|
            {
              "attachments" => [],
              "description" => begin
                { "translation" => a.description[locale] }
              rescue StandardError
                nil
              end,
              "id" => a.id.to_s,
              "title" => { "translation" => a.title[locale] },
              "versions" => [],
              "versionsCount" => 0,
              "weight" => a.weight.to_i
            }
          end,
          "id" => q.id.to_s,
          "title" => { "translation" => q.title[locale] },
          "description" => { "translation" => q.description[locale] },
          "versions" => [],
          "versionsCount" => 0,
          "weight" => q.weight
        }
      end,

      "voters" => election.voters.order(:id).map do |v|
        {
          "wallet_address" => v.wallet_address
        }
      end,

      "startTime" => election.start_time.iso8601.to_s.gsub("Z", "+00:00"),
      "title" => { "translation" => election.title[locale] },
      "updatedAt" => election.updated_at.iso8601.to_s.gsub("Z", "+00:00"),
      "versions" => [],
      "versionsCount" => 0
    }
end

let(:elections_data) do
  {
    "__typename" => "VocdoniElections",
    "id" => current_component.id.to_s,
    "name" => { "translation" => "Elections (Vocdoni)" },
    "elections" => {
      "edges" => [
        {
          "node" => election_single_result
        }
      ]
    },
    "weight" => 0
  }
end

describe "valid connection query" do
  let(:component_fragment) do
    %(
        fragment fooComponent on VocdoniElections {
          elections{
            edges{
              node{
                attachments {
                  thumbnail
                }
                status
                streamUri
                blocked
                createdAt
                description {
                  translation(locale: "en")
                }
                endTime
                id
                publishedAt
                questions {
                  answers {
                    description {
                      translation(locale: "en")
                    }
                    id
                    title {
                      translation(locale: "en")
                    }
                    versions {
                      id
                    }
                    versionsCount
                    weight
                  }
                  id
                  title {
                    translation(locale: "en")
                  }
                  description {
                    translation(locale: "en")
                  }
                  versions {
                    id
                  }
                  versionsCount
                  weight
                }
                voters {
                  wallet_address
                }
                startTime
                title {
                  translation(locale: "en")
                }
                updatedAt
                versions {
                  id
                }
                versionsCount
              }
            }
          }
        }
    )
  end

  it "executes sucessfully" do
    expect { response }.not_to raise_error
  end

  it do
    expect(response["participatoryProcess"]["components"].first).to eq(elections_data)
  end
end

describe "valid query" do
  let(:component_fragment) do
    %(
      fragment fooComponent on VocdoniElections {
        election(id: #{election.id}){
          attachments {
            thumbnail
          }
          status
          streamUri
          blocked
          createdAt
          description {
            translation(locale: "en")
          }
          streamUri
          endTime
          id
          publishedAt
          questions {
            answers {
              description {
                translation(locale: "en")
              }
              id
              title {
                translation(locale: "en")
              }
              versions {
                id
              }
              versionsCount
              weight
            }
            id
            title {
              translation(locale: "en")
            }
            description {
              translation(locale: "en")
            }
            versions {
              id
            }
            versionsCount
            weight
          }
          voters {
            wallet_address
          }
          startTime
          title {
            translation(locale: "en")
          }
          updatedAt
          versions {
            id
          }
          versionsCount
        }
      }
    )
  end

  it "executes sucessfully" do
    expect { response }.not_to raise_error
  end

  it do
    expect(response["participatoryProcess"]["components"].first["election"]).to eq(election_single_result)
  end
end
end
