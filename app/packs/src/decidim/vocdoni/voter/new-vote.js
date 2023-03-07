/* eslint-disable no-console */
import { VocdoniSDKClient } from "@vocdoni/sdk";

import VoteQuestionsComponent from "./vote_questions.component";
import VoteComponent from "./setup-vote";
import PreviewVoteComponent from "./setup-preview";

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
    onInvalid() {
      console.log("Invalid vote");
      $voteWrapper.find("#submitting").addClass("hide");
      $voteWrapper.find("#vote_failed").removeClass("hide");
    }
  });
}

/*
 * Generate the VoteComponent object in case the Wallet is in the census
 * or show an error message if it is not.
 *
 * @param {string} vocdoniEnv The environment of the Vocdoni API
 * @param {object} userWallet The Wallet object generated from the login form
 * @param {string} electionUniqueId The unique ID of the election in the Vocdoni API
 *
 * @return {array} An array with two elements:
 *  - The VoteComponent object or null if the wallet is not in the census
 *  - A boolean with true if we should show the next step or false if not
 */
const voteComponentGenerator = async (vocdoniEnv, userWallet, electionUniqueId) => {
  const checkIfWalletIsInCensus = async (wallet, electionId) => {
    const client = new VocdoniSDKClient({
      env: vocdoniEnv,
      wallet: wallet
    })
    client.setElectionId(electionId);
    const isInCensus = await client.isInCensus();
    return isInCensus;
  }

  let voteComponent = null;
  let nextStep = false;

  if (userWallet === {}) {
    return [voteComponent, nextStep];
  }

  const isInCensus = await checkIfWalletIsInCensus(userWallet, electionUniqueId);
  console.log("IS IN CENSUS => ", isInCensus);
  if (isInCensus) {
    console.log("OK!! Wallet is in census");
    voteComponent = new VoteComponent({vocdoniEnv: vocdoniEnv, electionUniqueId: electionUniqueId, wallet: userWallet});
    nextStep = true;
  }

  return [voteComponent, nextStep];
}

/*
 * Instantiate the Wallet object given a login form with the email and the date of birth
 * of the potenital voter
 *
 * @param {object} $loginForm The jQuery Element with the form for logging in
 *
 * @returns {object} the Wallet object generated or an empty object
 */
const walletFromLoginForm = ($loginForm) => {
  if ($loginForm === null) {
    return {};
  }

  const email = $loginForm.find("#login_email").val();
  let bornAtDay = $loginForm.find("#login_day").val();
  let bornAtMonth = $loginForm.find("#login_month").val();
  const bornAtYear = $loginForm.find("#login_year").val();

  if (!email.includes("@")) {
    return {};
  }

  if (bornAtYear.length !== 4) {
    return {};
  }

  if (bornAtDay.length === 1) {
    bornAtDay = `0${bornAtDay}`;
  }

  if (bornAtMonth.length === 1) {
    bornAtMonth = `0${bornAtMonth}`;
  }

  const bornAt = `${bornAtYear}-${bornAtMonth}-${bornAtDay}`;

  console.group("Wallet data");
  console.log("EMAIL => ", email);
  console.log("BORN AT => ", bornAt);
  console.groupEnd();

  for (const value of [email, bornAtDay, bornAtMonth, bornAtYear]) {
    if (value === "") {
      return {};
    }
  }

  const userWallet = VocdoniSDKClient.generateWalletFromData([email, bornAt]);

  return userWallet;
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

    const showErrorMessage = () => {
      console.log("KO -> Wallet is not in census");
      $(".js-login_error").removeClass("hide");
    }

    const electionUniqueId = $voteWrapper.data("electionUniqueId");
    let voteComponent = null;
    let nextStep = null;

    if ($voteWrapper.data("preview") === true) {
      console.log("Preview mode");
      voteComponent = new PreviewVoteComponent({electionUniqueId});
      nextStep = true;
    } else {
      const userWallet = walletFromLoginForm($loginForm);
      const vocdoniEnv = $voteWrapper.data("vocdoniEnv");
      [voteComponent, nextStep] = await voteComponentGenerator(vocdoniEnv, userWallet, electionUniqueId);
    }

    if (!nextStep) {
      showErrorMessage();
    }

    if (nextStep) {
      $("#login").foundation("toggle");
      $("#step-0").foundation("toggle");
      mountVoteComponent(voteComponent, $voteWrapper, questionsComponent);
    }
  });
});
/* eslint-enable no-console */
