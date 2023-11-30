# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This command gets called when saving the election status from the admin panel
      # To be used only when the election is interruptible
      class UpdateElectionStatus < Decidim::Command
        class StatusError < StandardError; end

        STATUSES = {
          "RESULTS" => "results_published",
          "ENDED" => "vote_ended",
          "CANCELED" => "canceled",
          "PAUSED" => "paused",
          "ONGOING" => "vote",
          "UPCOMING" => "created"
        }.freeze
        # Public: Initializes the command.
        #
        # form - An ElectionStatusForm object with the status to update
        def initialize(form)
          @form = form
        end

        # Public: Update Election Status
        #
        # Broadcasts :ok if setup, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          fix_status!
          transaction do
            update_status
            election.save!
            log_action
          end

          broadcast(:ok, election)
        rescue StatusError => e
          election.update(status: e.message)
          broadcast(:status, e.message)
        rescue StandardError => e
          Rails.logger.error e.message
          broadcast(:invalid, sdk.last_error)
        end

        private

        attr_reader :form

        delegate :election, to: :form
        def update_status
          case form.status
          when "created"
            create_or_start_election
          when "vote"
            continue_election
          when "paused"
            pause_election
          when "canceled"
            cancel_election
          when "end"
            end_election
          end
        end

        # this case is a safe guard for misconfigured database in case of misconfigured election
        # Note that the createElection in the Vocdoni SDK is idempotent, in case of already existing it just returns the election id
        def create_or_start_election
          if election.misconfigured?
            CreateVocdoniElectionJob.perform_later(election.id)
          elsif !election.started?
            election.start_time = Time.current
          end
          continue_election
        end

        def continue_election
          sdk.continueElection unless vocdoni_status == "ONGOING"
          election.status = "vote"
        end

        def pause_election
          sdk.pauseElection unless vocdoni_status == "PAUSED"
          election.status = "paused"
        end

        def cancel_election
          unless vocdoni_status.in?(%w(RESULTS ENDED CANCELED))
            sdk.cancelElection
            election.status = "canceled"
          end
        end

        def end_election
          unless vocdoni_status.in?(%w(RESULTS ENDED CANCELED))
            sdk.endElection
            election.status = "vote_ended"
          end
        end

        def fix_status!
          status = STATUSES[vocdoni_status]
          raise StatusError, status if election.status != status
        end

        def vocdoni_status
          @vocdoni_status ||= sdk.electionMetadata["status"]
        end

        def sdk
          @sdk ||= Decidim::Vocdoni::Sdk.new(election.organization, election)
        end

        def log_action
          Decidim.traceability.perform_action!(
            :change_election_status,
            election,
            form.current_user
          )
        end
      end
    end
  end
end
