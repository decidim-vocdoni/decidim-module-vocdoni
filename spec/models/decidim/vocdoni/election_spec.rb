# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::Election do
  subject(:election) { build :vocdoni_election }

  it { is_expected.to be_valid }

  include_examples "has component"
  include_examples "resourceable"
  include_examples "publicable" do
    let(:factory_name) { :vocdoni_election }
  end

  describe "check the log result" do
    it "overwrites the log presenter" do
      expect(described_class.log_presenter_class_for(:foo))
        .to eq Decidim::Vocdoni::AdminLog::ElectionPresenter
    end
  end

  it { is_expected.not_to be_started }
  it { is_expected.not_to be_ongoing }
  it { is_expected.not_to be_finished }
  it { is_expected.to be_auto_start }
  it { is_expected.not_to be_manual_start }
  it { is_expected.to be_interruptible }
  it { is_expected.to be_secret_until_the_end }

  context "when manual start" do
    subject(:election) { build :vocdoni_election, :manual_start }

    it { is_expected.to be_manual_start }
    it { is_expected.not_to be_auto_start }
    it { is_expected.to be_interruptible }
    it { is_expected.to be_secret_until_the_end }
    it { is_expected.not_to be_started }
    it { is_expected.not_to be_ongoing }
    it { is_expected.not_to be_finished }
  end

  context "when it is ongoing" do
    subject(:election) { build :vocdoni_election, :ongoing }

    it { is_expected.to be_started }
    it { is_expected.to be_ongoing }
    it { is_expected.not_to be_finished }

    context "and it doesn't have a status" do
      subject(:election) { build :vocdoni_election, :finished, status: nil }

      it { is_expected.not_to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.not_to be_finished }
    end
  end

  context "when it is finished" do
    subject(:election) { build :vocdoni_election, :finished }

    it { is_expected.to be_started }
    it { is_expected.not_to be_ongoing }
    it { is_expected.to be_finished }

    context "and it has the old status" do
      subject(:election) { build :vocdoni_election, :finished, status: "vote" }

      it { is_expected.to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.to be_finished }
    end

    context "and it doesn't have a status" do
      subject(:election) { build :vocdoni_election, :finished, status: nil }

      it { is_expected.not_to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.not_to be_finished }
    end
  end

  describe "with different status" do
    context "when it is paused" do
      subject(:election) { build :vocdoni_election, :started, :paused }

      it { is_expected.not_to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.not_to be_finished }
    end

    context "when it is canceled" do
      subject(:election) { build :vocdoni_election, :started, :canceled }

      it { is_expected.to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.to be_finished }
    end

    context "when it is vote_ended" do
      subject(:election) { build :vocdoni_election, :started, status: "vote_ended" }

      it { is_expected.to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.to be_finished }
    end

    context "when it is results_published" do
      subject(:election) { build :vocdoni_election, :started, status: "results_published" }

      it { is_expected.to be_started }
      it { is_expected.not_to be_ongoing }
      it { is_expected.to be_finished }
    end
  end

  describe "start time checks" do
    subject(:election) { build(:vocdoni_election, start_time: start_time) }

    let(:start_time) { 40.minutes.from_now }

    it { is_expected.to be_minimum_minutes_before_start }

    context "when the election is about to start" do
      let(:start_time) { 5.minutes.from_now }

      it { is_expected.not_to be_minimum_minutes_before_start }
    end

    context "when the election is not near to start" do
      let(:start_time) { 10.days.from_now }

      it { is_expected.to be_minimum_minutes_before_start }
    end
  end

  describe "#answers_have_values?" do
    subject { election.answers_have_values? }

    let(:question) { create(:vocdoni_question, election: election) }
    let!(:answer1) { create(:vocdoni_election_answer, question: question, value: 0) }
    let!(:answer2) { create(:vocdoni_election_answer, question: question, value: 1) }

    it { is_expected.to be_truthy }

    context "when there answers have no values" do
      let!(:answer1) { create(:vocdoni_election_answer, question: question, value: nil) }

      it { is_expected.to be_falsey }
    end
  end

  describe "#explorer_vote_url" do
    subject(:election) { build :vocdoni_election, vocdoni_election_id: "12345" }

    before do
      allow(Decidim::Vocdoni).to receive(:explorer_vote_domain).and_return("example.org")
    end

    it "returns the URL" do
      expect(subject.explorer_vote_url).to eq "https://example.org/processes/show/#/12345"
    end
  end

  describe "#ready_for_questions_form?" do
    it "returns true when the election is present" do
      expect(subject.ready_for_questions_form?).to be true
    end
  end

  describe "#times_set?" do
    context "when start and end times are present" do
      it "returns true" do
        expect(subject.times_set?).to be true
      end
    end

    context "when start time or end time is not present" do
      subject(:election) { build(:vocdoni_election, start_time: nil, end_time: 1.day.from_now) }

      it "returns false" do
        expect(subject.times_set?).to be false
      end
    end
  end

  describe "#census_ready?" do
    context "when census status is ready" do
      let(:status) { instance_double(Decidim::Vocdoni::CsvCensus::Status, name: "ready") }

      before do
        allow(Decidim::Vocdoni::CsvCensus::Status).to receive(:new).with(election).and_return(status)
      end

      it "returns true" do
        expect(subject.census_ready?).to be true
      end
    end
  end

  describe "#ready_for_census_form?" do
    let(:question) { create(:vocdoni_question, election: election) }

    context "when minimum_answers? returns true" do
      let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }

      it "returns true" do
        expect(subject.ready_for_census_form?).to be true
      end
    end

    context "when minimum_answers? returns false" do
      let!(:answer) { create(:vocdoni_election_answer, question: question) }

      it "returns false" do
        expect(subject.ready_for_census_form?).to be false
      end
    end
  end

  describe "#ready_for_calendar_form?" do
    context "when census is ready" do
      subject(:election) { build(:vocdoni_election, :with_census) }

      let(:question) { create(:vocdoni_question, election: election) }
      let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }

      it "returns true" do
        expect(subject.ready_for_calendar_form?).to be true
      end
    end

    context "when census is not upload" do
      subject(:election) { build(:vocdoni_election) }

      it "returns false" do
        expect(subject.ready_for_calendar_form?).to be false
      end
    end
  end

  describe "#ready_for_publish_form?" do
    context "when ready for calendar form and times are set" do
      subject(:election) { build(:vocdoni_election, :with_census) }

      let(:question) { create(:vocdoni_question, election: election) }
      let!(:answers) { create_list(:vocdoni_election_answer, 2, question: question) }

      it "returns true" do
        expect(subject.ready_for_publish_form?).to be true
      end

      context "when times are not set" do
        subject(:election) { build(:vocdoni_election, :with_census, start_time: nil, end_time: nil) }

        it "returns false" do
          expect(subject.ready_for_publish_form?).to be false
        end
      end
    end
  end

  describe "#to_vocdoni" do
    let(:election) { create(:vocdoni_election, :with_photos, election_type: type, component: component, title: title, description: description) }
    let(:component) { create(:vocdoni_component, participatory_space: participatory_process) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:organization) { create(:organization, enable_machine_translations: true) }
    let(:title) do
      {
        en: "English title",
        es: "",
        machine_translations: {
          ca: "Catalan title"
        }
      }
    end
    let(:description) do
      {
        en: "English description",
        machine_translations: {
          ca: "Catalan description"
        }
      }
    end
    let(:type) do
      { "anonymous" => false, "auto_start" => false, "interruptible" => true, "dynamic_census" => false, "secret_until_the_end" => false }
    end

    let(:json) { election.to_vocdoni }

    it "returns the election as json" do
      # expect(json["id"]).to eq election.id
      expect(json["title"]).to eq({ "en" => "English title", "ca" => "Catalan title", "es" => "English title", "default" => "English title" })
      expect(json["description"]).to eq({ "en" => "English description", "ca" => "Catalan description", "es" => "English description", "default" => "English description" })
      expect(json["header"]).to eq election.photo.attached_uploader(:file).url(host: organization.host)
      expect(json["streamUri"]).to match(%r{^https?://})
      expect(json["startDate"]).to eq(election.start_time.iso8601)
      expect(json["endDate"]).to eq(election.end_time.iso8601)
      expect(json["electionType"]).to eq({
                                           "autoStart" => false,
                                           "interruptible" => true,
                                           "dynamicCensus" => true,
                                           "secretUntilTheEnd" => false,
                                           "anonymous" => false
                                         })
      expect(json["voteType"]).to eq({
                                       "maxVoteOverwrites" => 10
                                     })
      # expect(json["questions"].size).to eq election.questions.size
      # expect(json["questions"].first["answers"].size).to eq election.questions.first.answers.size
    end

    context "when no attachments" do
      let(:election) { create(:vocdoni_election, title: title, component: component) }

      it "returns the election as json" do
        expect(json["title"]).to eq({ "en" => "English title", "ca" => "Catalan title", "es" => "English title", "default" => "English title" })
        expect(json["header"]).to be_nil
      end
    end

    context "when diffrent election type" do
      let(:type) do
        { "anonymous" => true, "auto_start" => true, "interruptible" => false, "dynamic_census" => true, "secret_until_the_end" => true }
      end

      it "returns the election as json" do
        expect(json["startDate"]).to eq(election.start_time.iso8601)
        expect(json["electionType"]).to eq({
                                             "autoStart" => true,
                                             "dynamicCensus" => true,
                                             "interruptible" => false,
                                             "secretUntilTheEnd" => true,
                                             "anonymous" => true
                                           })
      end
    end

    context "when diffrent configuration" do
      before do
        allow(Decidim::Vocdoni).to receive(:votes_overwrite_max).and_return(5)
      end

      it "returns the election as json" do
        expect(json["voteType"]).to eq({
                                         "maxVoteOverwrites" => 5
                                       })
      end
    end
  end
end
