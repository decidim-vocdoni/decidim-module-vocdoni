# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Admin::CreateElection do
  subject { described_class.new(form) }

  let(:organization) { create(:organization, available_locales: [:en, :ca, :es], default_locale: :en) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:current_component) { create(:component, participatory_space: participatory_process, manifest_name: "vocdoni") }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      stream_uri: "https://example.org/stream",
      attachment: attachment_params,
      photos:,
      add_photos: uploaded_photos,
      current_user: user,
      current_component:,
      current_organization: organization
    )
  end
  let(:invalid) { false }
  let(:attachment_params) { nil }
  let(:photos) { [] }
  let(:uploaded_photos) { [] }

  let(:election) { Decidim::Vocdoni::Election.last }

  it "creates the election" do
    expect { subject.call }.to change(Decidim::Vocdoni::Election, :count).by(1)
  end

  it "stores the given data" do
    subject.call
    expect(translated(election.title)).to eq "title"
    expect(translated(election.description)).to eq "description"
    expect(election.stream_uri).to eq "https://example.org/stream"
  end

  it "sets the component" do
    subject.call
    expect(election.component).to eq current_component
  end

  it "traces the action", :versioning do
    expect(Decidim.traceability)
      .to receive(:create!)
      .with(
        Decidim::Vocdoni::Election,
        user,
        hash_including(:title, :description, :component),
        visibility: "all"
      )
      .and_call_original

    expect { subject.call }.to change(Decidim::ActionLog, :count)
    action_log = Decidim::ActionLog.last
    expect(action_log.version).to be_present
    expect(action_log.version.event).to eq "create"
  end

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "with attachment" do
    it_behaves_like "admin creates resource gallery" do
      let(:command) { described_class.new(form) }
      let(:resource_class) { Decidim::Vocdoni::Election }
      let(:attachment_params) do
        {
          title: "My attachment",
          file: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
        }
      end
    end
  end
end
