# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows the create or update questions for an election.
      class QuestionsController < Admin::ApplicationController
        helper_method :election, :questions, :question

        def new
          enforce_permission_to(:create, :question, election:)
          @form = form(QuestionForm).instance
        end

        def edit
          enforce_permission_to(:update, :question, election:, question:)
          @form = form(QuestionForm).from_model(question)
        end

        def create
          enforce_permission_to(:create, :question, election:)
          @form = form(QuestionForm).from_params(params, election:)

          CreateQuestion.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.create.success", scope: "decidim.vocdoni.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.create.invalid", scope: "decidim.vocdoni.admin")
              render action: "new"
            end

            on(:election_ongoing) do
              flash.now[:alert] = I18n.t("questions.create.election_ongoing", scope: "decidim.vocdoni.admin")
              render action: "new"
            end
          end
        end

        def update
          enforce_permission_to(:update, :question, election:, question:)
          @form = form(QuestionForm).from_params(params, election:)

          UpdateQuestion.call(@form, question) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.update.success", scope: "decidim.vocdoni.admin")
              redirect_to election_questions_path(election)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.update.invalid", scope: "decidim.vocdoni.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:update, :question, election:, question:)

          DestroyQuestion.call(question, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("questions.destroy.success", scope: "decidim.vocdoni.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("questions.destroy.invalid", scope: "decidim.vocdoni.admin")
            end
          end

          redirect_to election_questions_path(election)
        end

        private

        def election
          @election ||= Decidim::Vocdoni::Election.where(component: current_component).find_by(id: params[:election_id])
        end

        def questions
          @questions ||= election.questions
        end

        def question
          questions.find(params[:id])
        end
      end
    end
  end
end
