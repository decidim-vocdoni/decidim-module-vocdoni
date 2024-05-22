/* eslint-disable no-console */
import { ElectionStatus, VocdoniSDKClient } from "@vocdoni/sdk";

import VoteQuestionsComponent from "./vote_questions.component";
import VoteComponent from "./setup-vote";
import PreviewVoteComponent from "./setup-preview";
import { walletFromLoginForm } from "./census-utils";

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
      questionsComponent.unsavedChanges = false;
    },
    onFinish(voteId, env) {
      console.log("Vote finished");
      console.log("VOTE ID => ", voteId);
      $voteWrapper.find("#submitting").addClass("hidden");
      $voteWrapper.find("#vote_cast").removeClass("hidden");
      $voteWrapper.find("#vote-receipt").val(voteId);
      $voteWrapper.find(".verify_ballot").attr("href", `https://${env}.explorer.vote/verify/#/${voteId}`);
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
      $voteWrapper.find("#submitting").addClass("hidden");
      $voteWrapper.find("#vote_failed").removeClass("hidden");

      switch (message) {
      case "No votes left":
        $voteWrapper.find("#vote_failed").find("#error-no_votes_left").removeClass("hidden");
        break;
      default:
        $voteWrapper.find("#vote_failed").find("#error-unknown").removeClass("hidden");
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
  const isElectionOpen = election.status === ElectionStatus.ONGOING;

  console.log("ELECTION => ", election);
  console.log("STATUS => ", ElectionStatus[election.status]);

  return isElectionOpen;
}

// Display error messages
const showLoginErrorMessage = () => {
  console.log("KO -> Wallet is not in census");
  $(".js-login_error").removeClass("hidden");
};

const showElectionClosedErrorMessage = () => {
  console.log("Election is not open");
  $(".vote-wrapper").find(".js-election_not_open").removeClass("hidden");
};

// Document ready function
$(() => {
  const $voteWrapper = $(".vote-wrapper");
  const questionsComponent = new VoteQuestionsComponent($voteWrapper);
  questionsComponent.init();

  const env = $voteWrapper.data("vocdoni-env");
  const electionUniqueId = $voteWrapper.data("election-unique-id");
  const checkVerificationUrl = $voteWrapper.data("check-verification-url");
  const isPreview = $voteWrapper.data("preview") === true;

  console.group("Election data");
  console.log("ENV => ", env)
  console.log("ELECTION ID => ", electionUniqueId)
  console.log("CHECK VERIFICATION URL => ", checkVerificationUrl)
  console.log("IS PREVIEW => ", isPreview)
  console.groupEnd();

  // Reinitialize the questions component on certain occasions
  $(document).on("on.zf.toggler", () => {
    setTimeout(() => questionsComponent.init(), 100);
  });

  // Initiates the voting process
  const initVotingProcess = async (wallet) => {
    if (isPreview) {
      const voteComponent = new PreviewVoteComponent({ electionUniqueId });
      await mountVoteComponent(voteComponent, $voteWrapper, questionsComponent);

      $("#check_census").foundation("toggle");
      $("#step-0").foundation("toggle");
    } else {
      if (!(await checkIfElectionIsOpen(env, wallet, electionUniqueId))) {
        showElectionClosedErrorMessage();
        return;
      }
      const client = new VocdoniSDKClient({ env, wallet });
      client.setElectionId(electionUniqueId);

      const votesLeft = await client.votesLeftCount();
      const electionUrl = document.getElementById("vote-wrapper").dataset.url;
      console.log("VOTES LEFT => ", votesLeft);

      /**
       * Function to update the votes left for a given election.
       * @param {number} votesLeftParam - The remaining votes overwrite for the election.
       *  @returns {void} No return value.
       */
      const updateVotesLeft = function(votesLeftParam) {
        fetch(electionUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify({ votesLeft: votesLeftParam })
        }).then((response) => response.json()).then((data) => {
          document.getElementById("votes-left-message").innerHTML = data.message;
        }).catch((error) => console.error("Error:", error));
      }

      updateVotesLeft(votesLeft);

      const hasAlreadyVoted = await client.hasAlreadyVoted();
      if (hasAlreadyVoted) {
        console.log("ALREADY VOTED");
        $("#step-0").find(".js-already_voted").removeClass("hidden");
      }

      console.log("OK!! Wallet is in census");

      const voteComponent = new VoteComponent({ env, electionUniqueId, wallet });
      $("#check_census").foundation("toggle");
      $("#step-0").foundation("toggle");
      await mountVoteComponent(voteComponent, $voteWrapper, questionsComponent);
    }
  };
  // Handle user verifications
  if (checkVerificationUrl) {
    fetch(checkVerificationUrl).
      then((response) => response.json()).
      then((data) => {
        console.log("Verification data:", data);
        if (data.isVerified) {
          const wallet = VocdoniSDKClient.generateWalletFromData([data.email.toLowerCase(), data.token.toLowerCase()]);
          console.group("Wallet data");
          console.log("EMAIL => ", data.email);
          console.log("TOKEN => ", data.token);
          console.log("WALLET => ", wallet);
          console.groupEnd();
          initVotingProcess(wallet).then(() => console.log("Voting process initialized"));
        } else {
          console.log("User is not verified");
        }
      }).catch((error) => console.error("Error during verification:", error));
  }

  // Handle login form submission
  const $loginForm = $voteWrapper.find("#new_login_");
  const $loginInputs = $loginForm.find("input");

  if ($loginInputs.filter(":focus").length > 0) {
    questionsComponent.unsavedChanges = true;
  }

  $loginForm.on("submit", async (event) => {
    event.preventDefault();
    const wallet = walletFromLoginForm($loginForm);
    if (!wallet) {
      showLoginErrorMessage();
      return;
    }
    await initVotingProcess(wallet);
  });
});
/* eslint-enable no-console */
