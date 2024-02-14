# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::CsvCensus::Data do
  subject { voter }

  let(:voter) { create(:vocdoni_voter) }
  let(:valid_email) { "test@example.com" }
  let(:invalid_email) { "invalid_email" }
  let(:valid_token) { "123456" }
  let(:invalid_token) { "" }
  let(:valid_csv_path) { File.expand_path(File.join("..", "..", "..", "..", "assets", "valid-census.csv"), __dir__) }
  let(:invalid_csv_path) { Decidim::Dev.test_file("import_participatory_space_private_users_iso8859-1.csv", "text/csv") }
  let(:file_with_invalid_data) { File.expand_path(File.join("..", "..", "..", "..", "assets", "invalid-census.csv"), __dir__) }

  it { is_expected.to be_valid }

  context "without a valid email" do
    let(:voter) { build(:vocdoni_voter, email: "invalid_email") }

    it { is_expected.not_to be_valid }
  end

  context "with a valid CSV file" do
    subject { described_class.new(valid_csv_path) }

    it "reads values correctly" do
      expect(subject.values).to match_array([
                                              %w(john@example.org 123456),
                                              %w(alice@example.org 987654)
                                            ])
    end

    it "has no errors" do
      expect(subject.errors).to be_empty
    end
  end

  context "with an invalid CSV file" do
    subject { described_class.new(file_with_invalid_data) }

    it "identifies errors" do
      expect(subject.errors).not_to be_empty
    end

    it "does not include invalid data in values" do
      expect(subject.values).not_to include([invalid_email, valid_token])
    end
  end

  describe "#mail_valid?" do
    it "returns true for a valid email" do
      data_instance = Decidim::Vocdoni::CsvCensus::Data.new(valid_csv_path)
      expect(data_instance.send(:mail_valid?, valid_email)).to be true
    end
  end

  describe "#token_valid?" do
    subject { described_class.new(valid_csv_path) }

    it "returns true for a valid token" do
      expect(subject.send(:token_valid?, valid_token)).to be true
    end

    it "returns false for an invalid token" do
      expect(subject.send(:token_valid?, invalid_token)).to be false
    end
  end
end
