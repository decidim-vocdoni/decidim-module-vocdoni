# frozen_string_literal: true

require "spec_helper"

module Decidim::Vocdoni::Admin
  describe CreateCensusData do
    subject { described_class.new(form, election) }

    let(:form) { CensusDataForm.new(file:) }
    let(:election) { create(:vocdoni_election) }
    let(:valid_census_file) { file_fixture("valid-census.csv") }

    context "when the file is in invalid format" do
      let(:file) { Decidim::Dev.test_file("import_participatory_space_private_users_iso8859-1.csv", "text/csv") }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the file is not provided" do
      let(:form) { CensusDataForm.new(file: nil) }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "when the file is provided and contains valid data" do
      let(:file) { Rack::Test::UploadedFile.new(valid_census_file, "text/csv") }
      let(:form) { CensusDataForm.new(file:) }
      let(:expected_number_of_voters) { 2 }

      it "successfully creates voters" do
        expect { subject.call }.to change(Decidim::Vocdoni::Voter, :count).by(expected_number_of_voters)
      end
    end

    context "when updates the census type of the election" do
      let(:file) { Rack::Test::UploadedFile.new(valid_census_file, "text/csv") }
      let(:form) { CensusDataForm.new(file:) }

      it "sets the internal_census to false" do
        subject.call
        expect(election.reload.internal_census).to be_falsey
      end
    end
  end
end
