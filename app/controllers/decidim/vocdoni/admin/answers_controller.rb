# frozen_string_literal: true

module Decidim
  module Vocdoni
    module Admin
      # This controller allows the create or update answers for a question.
      class AnswersController < Admin::ApplicationController
        helper Decidim::ApplicationHelper
        helper_method :election, :question, :answers, :answer

        def index; end

        def new
          enforce_permission_to(:update, :answer, election:, question:)
          @form = form(AnswerForm).instance
        end

        def edit
          enforce_permission_to(:update, :answer, election:, question:)
          @form = form(AnswerForm).from_model(answer)
        end

        def create
          enforce_permission_to(:update, :answer, election:, question:)
          @form = form(AnswerForm).from_params(params, election:, question:)

          CreateAnswer.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.create.success", scope: "decidim.vocdoni.admin")
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.create.invalid", scope: "decidim.vocdoni.admin")
              render action: "new"
            end
          end
        end

        def update
          enforce_permission_to(:update, :answer, election:, question:)
          @form = form(AnswerForm).from_params(params, election:, question:)

          UpdateAnswer.call(@form, answer) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.update.success", scope: "decidim.vocdoni.admin")
              redirect_to election_question_answers_path(election, question)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.update.invalid", scope: "decidim.vocdoni.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:update, :answer, election:, question:)

          DestroyAnswer.call(answer, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("answers.destroy.success", scope: "decidim.vocdoni.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("answers.destroy.invalid", scope: "decidim.vocdoni.admin")
            end
          end

          redirect_to election_question_answers_path(election, question)
        end

        private

        def election
          @election ||= Decidim::Vocdoni::Election.where(component: current_component).find_by(id: params[:election_id])
        end

        def question
          @question ||= election.questions.find_by(id: params[:question_id])
        end

        def answers
          @answers ||= question.answers
        end

        def answer
          answers.find(params[:id])
        end
      end
    end
  end
end
