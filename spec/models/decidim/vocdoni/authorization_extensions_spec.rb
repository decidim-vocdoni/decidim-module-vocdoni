# frozen_string_literal: true

require "spec_helper"

describe Decidim::Vocdoni::AuthorizationExtensions, type: :model do
  let(:authorization) { create(:authorization) }
  let!(:election) { create(:vocdoni_election, :with_internal_census, verification_types: [authorization.name]) }

  describe "after_update" do
    context "when granted_at is changed" do
      let(:vocdoni_authorizations_data) { Decidim::Vocdoni::AuthorizationsData.find_by(authorization: authorization, decidim_vocdoni_election_id: election.id) }

      before do
        authorization.update!(granted_at: Time.current)
      end

      describe "#add_to_vocdoni_queue" do
        context "when granted_at is changed" do
          before do
            authorization.update!(granted_at: Time.current)
          end

          it "creates Vocdoni authorizations data" do
            expect(Decidim::Vocdoni::AuthorizationsData.exists?(authorization: authorization, decidim_vocdoni_election_id: election.id)).to be true
          end

          it "sets processed attribute to false" do
            vocdoni_authorizations_data = Decidim::Vocdoni::AuthorizationsData.find_by(authorization: authorization, decidim_vocdoni_election_id: election.id)
            expect(vocdoni_authorizations_data.processed).to be false
          end
        end

        context "when granted_at is not changed" do
          it "does not create Vocdoni authorizations data" do
            expect {
              authorization.save
            }.not_to change(Decidim::Vocdoni::AuthorizationsData, :count)
          end
        end
      end
    end
  end

  describe "after_destroy" do
    let!(:vocdoni_authorizations_data) { create(:vocdoni_authorizations_data, authorization: authorization, decidim_vocdoni_election_id: election.id) }

    describe "#clear_related_voters_from_census" do
      context "when authorization is destroyed" do
        it "clears related voters from census" do
          authorization.destroy!
          expect(Decidim::Vocdoni::Voter.exists?(email: authorization.user.email, election: election)).to be false
        end
      end
    end
  end
end
