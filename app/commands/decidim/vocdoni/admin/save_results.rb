# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when saving the results from the admin panel
      class SaveResults < Decidim::Command
        # Public: Initializes the command.
        #
        # form - A ResultsForm object with the information needed to save the results
        def initialize(form)
          @form = form
        end

        # Public: Save the Results.
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) if form.results.empty?

          transaction do
            save_results
            change_election_status
            log_action
          end

          broadcast(:ok, election)
        rescue StandardError => e
          broadcast(:invalid, e.message)
        end

        private

        attr_reader :form

        delegate :election, to: :form

        def save_results
          form.results.each do |result|
            answer = Decidim::Vocdoni::Answer.find(result.fetch(:id))
            answer.votes = result.fetch(:votes)
            answer.save!
          end
        end

        def change_election_status
          election.status = :results_published
          election.save!
        end

        def log_action
          Decidim.traceability.perform_action!(
            :save_results,
            election,
            form.current_user,
            extra: {
              results: form.results,
              status: election.status
            }
          )
        end
      end
    end
  end
end
