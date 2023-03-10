/* eslint-disable no-console */
import { ElectionStatus, VocdoniSDKClient } from "@vocdoni/sdk";

import VoteQuestionsComponent from "./vote_questions.component";
import VoteComponent from "./setup-vote";
import PreviewVoteComponent from "./setup-preview";
import { walletFromLoginForm, checkIfWalletIsInCensus } from "./census-utils";

/*
 * Mount the VoteComponent object and bind the events to the UI
 *
 * @param {object} voteComponent The VoteComponent object
 *            Can be used for a Preview or a Real Vote
 * @param {object} $voteWrapper The jQuery Element with the wrapper for the vote
 * @param {object} questionsComponent The VoteQuestionsComponent object
 */
const mountVoteComponent = async (voteComponent, $voteWrapper, questionsComponent) => {
  await voteComponent.bindEvents({
    onBindSubmitButton(onEventTriggered) {
      $(".button.confirm").on("click", onEventTriggered);
    },
    onStart() {},
    onBallotSubmission(validVoteFn) {

      /*
       * @param {object} formData The jQuery object with the selected answers
       *
       * @return {array} An array with the selected answers
       */
      const getFormData = (formData) => {
        /* eslint-disable no-invalid-this */
        return formData.map(function() {
          const answerValue = this.value;
          return Number(answerValue);
        }).get();
        /* eslint-enable no-invalid-this */
      };
      const formData = getFormData($voteWrapper.find(".answer_input:checked"));

      validVoteFn(formData);
      questionsComponent.voteCasted = true;
    },
    onFinish(voteId) {
      console.log("Vote finished");
      console.log("VOTE ID => ", voteId);
      $voteWrapper.find("#submitting").addClass("hide");
      $voteWrapper.find("#vote_cast").removeClass("hide");
      $voteWrapper.find("#vote-receipt").val(voteId);
      $voteWrapper.find(".verify_ballot").attr("href", `https://dev.explorer.vote/verify/#/${voteId}`);
    },
    onBindVerifyBallotButton(onEventTriggered) {
      $(".verify_ballot").on("click", onEventTriggered);
    },
    onVerifyComplete() {
      console.log("Verify completed");
    },
    onClose() {
      console.log("Voting finished");
    },
    onInvalid(message = "Invalid vote") {
      console.log("Invalid vote");
      $voteWrapper.find("#submitting").addClass("hide");
      $voteWrapper.find("#vote_failed").removeClass("hide");

      switch (message) {
      case "No votes left":
        $voteWrapper.find("#vote_failed").find("#error-no_votes_left").removeClass("hide");
        break;
      default:
        $voteWrapper.find("#vote_failed").find("#error-unknown").removeClass("hide");
      }
    }
  });
}


/*
 * Check if the election is open
 *
 * @param {string} env - The environment of the Vocdoni API
 * @param {object} wallet - The Wallet object generated from the login form
 * @param {string} electionUniqueId - The unique ID of the election in the Vocdoni API
 *
 * @return {boolean} A boolean with true if the election is open or false if not
 *   (if the election is not open, the next step is not shown)
 *   (if the election is open, the next step is shown)
 */
const checkIfElectionIsOpen = async (env, wallet, electionUniqueId) => {
  const client = new VocdoniSDKClient({ env, wallet })
  client.setElectionId(electionUniqueId);
  const election = await client.fetchElection();
  const isElectionOpen = election.status === ElectionStatus.READY;

  console.log("ELECTION => ", election);
  console.log("STATUS => ", ElectionStatus[election.status]);

  return isElectionOpen;
}

$(() => {
  // UI Elements
  const $voteWrapper = $(".vote-wrapper");

  // Use the questions component
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();
  $(document).on("on.zf.toggler", () => {
    // On some ocassions, when adding the Identification step in the same document,
    // the $currentStep isn't set correctly
    //
    // Adding a slight delay works as a workaround
    setTimeout(() => {
      // continue and back btn
      questionsComponent.init();
    }, 100);
  });

  const $loginForm = $voteWrapper.find("#new_login_");
  $loginForm.on("submit", async (event) => {
    event.preventDefault();

    const showLoginErrorMessage = () => {
      console.log("KO -> Wallet is not in census");
      $(".js-login_error").removeClass("hide");
    }

    const showElectionClosedErrorMessage = () => {
      console.log("Election is not open");
      $(".vote-wrapper").find(".js-election_not_open").removeClass("hide");
    }

    const electionUniqueId = $voteWrapper.data("electionUniqueId");
    let voteComponent = null;

    if ($voteWrapper.data("preview") === true) {
      console.log("Preview mode");
      voteComponent = new PreviewVoteComponent({electionUniqueId});
    } else {
      const wallet = walletFromLoginForm($loginForm);
      const env = $voteWrapper.data("vocdoniEnv");

      if (wallet === {}) {
        showLoginErrorMessage();
        return;
      }

      const isInCensus = await checkIfWalletIsInCensus(env, wallet, electionUniqueId);
      console.log("IS IN CENSUS => ", isInCensus);

      if (!isInCensus) {
        showLoginErrorMessage();
        return;
      }

      console.log("OK!! Wallet is in census");

      const isElectionOpen = await checkIfElectionIsOpen(env, wallet, electionUniqueId);
      console.log("IS ELECTION OPEN => ", isElectionOpen);

      if (!isElectionOpen) {
        showElectionClosedErrorMessage();
        return;
      }

      voteComponent = new VoteComponent({env, electionUniqueId, wallet});
    }

    $("#login").foundation("toggle");
    $("#step-0").foundation("toggle");
    mountVoteComponent(voteComponent, $voteWrapper, questionsComponent);
  });
});
/* eslint-enable no-console */
