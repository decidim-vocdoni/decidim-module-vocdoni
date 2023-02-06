# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Vocdoni::AdminLog::WalletPresenter, type: :helper do
    subject { described_class.new(action_log, helper) }

    let(:action_log) { create(:action_log, action: action) }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    describe "#present" do
      context "when the wallet is created" do
        let(:action) { :create }

        it "shows the wallet has been created" do
          expect(subject.present).to include(" created the Organization wallet ")
        end
      end
    end
  end
end
