import { initVocdoniClient } from "src/decidim/vocdoni/admin/utils/init_vocdoni_client";

const ELECTION_RESULTS_FORM_SELECTOR = "form#new_results_";
const ERROR_MESSAGE_SELECTOR = ".js-votes-results-error";
const FORM_NEW_RESULTS_BUTTON_SELECTOR = "form#new_results_ button";

// Vote Ended step
//
// Fetch the votes from the API and saves them to the form
const voteEndedStep = () => {
  const electionResultsForm = document.querySelector(ELECTION_RESULTS_FORM_SELECTOR);
  if (!electionResultsForm) {
    return;
  }

  /*
   * Fetch the votes results from the Vocdoni API
   *
   * @param {object} client - The Vocdoni SDK client instantiated with the election ID and the wallet
   * @returns void
   */
  const fetchVotesResults = async (client) => {
    const electionMetadata = await client.fetchElection();
    console.log("ELECTION METADATA => ", electionMetadata);
    const results = electionMetadata.results;

    if (!results) {
      console.log("No results yet. Wait a couple of minutes.");
      document.querySelector(ERROR_MESSAGE_SELECTOR).classList.remove("hide");
      return;
    }

    console.group("Final Results");
    for (let idx = 0; idx < results.length; idx += 1) {
      const questionAnswersInputs = document.querySelectorAll(`*[data-question-idx="${idx}"]`);
      for (const answerInput of questionAnswersInputs) {
        const answerValue = answerInput.dataset.answerValue;
        const answerVotes = results[idx][answerValue];

        if (typeof answerVotes !== "undefined") {
          answerInput.value = answerVotes;
          console.log(`FINAL RESULT FOR QUESTION ${idx} - ANSWER ${answerValue} - VOTES ${answerVotes}`);
        }
      }
    }
    console.groupEnd();

    document.querySelector(FORM_NEW_RESULTS_BUTTON_SELECTOR).disabled = false;
  }

  const client = initVocdoniClient();
  fetchVotesResults(client);
}

document.addEventListener("DOMContentLoaded", () => {
  voteEndedStep();
});
