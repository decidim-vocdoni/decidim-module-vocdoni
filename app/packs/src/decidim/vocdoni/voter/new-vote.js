/* eslint-disable no-console */
import { EnvOptions, VocdoniSDKClient } from "@vocdoni/sdk";

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
      const getFormData = (formData) => {
        return formData.serializeArray().reduce((acc, { name, value }) => {
          if (!acc[name]) {
            acc[name] = [];
          }
          acc[name] = [...acc[name], `${name}_${value}`];
          return acc;
        }, {});
      };
      const formData = getFormData($voteWrapper.find(".answer_input"));
      validVoteFn(formData);
      questionsComponent.voteCasted = true;
    },
    onFinish(voteId) {
      console.log("Vote finished");
      console.log("VOTE ID => ", voteId);
      $voteWrapper.find("#submitting").addClass("hide");
      $voteWrapper.find("#vote_sent").removeClass("hide");
      $voteWrapper.find(".vote-id").html(voteId);
      $voteWrapper.find(".verify_ballot").attr("href", `https://dev.explorer.vote/verify/#/${voteId}`);
    },
    onBindVerifyBallotButton(onEventTriggered) {
      $(".verify_ballot").on("click", onEventTriggered);
    },
    onVerifyBallot(auditedData, auditedDataFileName) {
      // TODO
      const vote = JSON.stringify(auditedData);
      const link = document.createElement("a");
      $voteWrapper.find(".button.cast_ballot").addClass("hide");
      $voteWrapper.find(".button.back").removeClass("hide");
      questionsComponent.voteCasted = true;

      link.setAttribute("href", `data:text/plain;charset=utf-8,${vote}`);
      link.setAttribute("download", auditedDataFileName);
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
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
      $voteWrapper.find("#vote_fail").removeClass("hide");
    }
  });
}

/*
 * Generate the VoteComponent object in case the Wallet is in the census
 * or show an error message if it is not.
 *
 * @param {object} userWallet The Wallet object generated from the login form
 * @param {string} electionUniqueId The unique ID of the election in the Vocdoni API
 *
 * @return {array} An array with two elements:
 *  - The VoteComponent object
 *  - A boolean indicating if we should show the next step or not
 */
const voteComponentGenerator = async (userWallet, electionUniqueId) => {
  const checkIfWalletIsInCensus = async (wallet, electionId) => {
    const client = new VocdoniSDKClient({
      env: EnvOptions.DEV,
      wallet: wallet
    })
    client.setElectionId(electionId);
    const isInCensus = await client.isInCensus();
    return isInCensus;
  }

  const isInCensus = await checkIfWalletIsInCensus(userWallet, electionUniqueId);
  let voteComponent = null;
  let nextStep = null;

  if (isInCensus) {
    console.log("OK!! Wallet is in census");
    voteComponent = new VoteComponent({electionUniqueId: electionUniqueId, wallet: userWallet});
    nextStep = true;
  } else {
    console.log("KO -> Wallet is not in census");
    nextStep = false;
    $(".js-login_error").removeClass("hide");
  }

  return [voteComponent, nextStep];
}

/*
 * Instantiate the Wallet object given a login form with the email and the date of birth
 * of the potenital voter
 *
 * @param {object} $loginForm The jQuery Element with the form for logging in
 *
 * @return userWallet the Wallet object generated or an empty object
 */
export const walletFromLoginForm = ($loginForm) => {
  if ($loginForm === null) {
    return {};
  }

  const email = $loginForm.find("#login_email").value;
  const bornAtDay = $loginForm.find("#login_day").value;
  const bornAtMonth = $loginForm.find("#login_month").value;
  const bornAtYear = $loginForm.find("#login_year").value;
  const bornAt = `${bornAtYear}-${bornAtMonth}-${bornAtDay}`;

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

    const electionUniqueId = $voteWrapper.data("electionUniqueId");
    let voteComponent = null;
    let nextStep = null;

    if ($voteWrapper.data("preview") === true) {
      console.log("Preview mode");
      voteComponent = new PreviewVoteComponent({electionUniqueId});
      nextStep = true;
    } else {
      const userWallet = walletFromLoginForm($loginForm);
      [voteComponent, nextStep] = await voteComponentGenerator(userWallet, electionUniqueId);
    }

    if (nextStep) {
      $("#login").foundation("toggle");
      $("#step-0").foundation("toggle");
      mountVoteComponent(voteComponent, $voteWrapper, questionsComponent);
    }
  });
});
