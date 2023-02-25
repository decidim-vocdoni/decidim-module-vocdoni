import { initVocdoniClient } from "../utils/init_vocdoni_client";

// Votes step
//
// Fetch the votes from the API and saves them to the form
const voteEndedStep = async () => {
  const electionResultsForm = document.querySelector(".js-votes-results");
  if (!electionResultsForm) {
    return;
  }

  /*
   * Fetch the votes stats from the Vocdoni API
   *
   * @param {object} client - The Vocdoni SDK client instantiated with the election ID and the wallet
   * @returns void
   */
  const fetchVotesStats = async (client) => {
    const electionMetadata = await client.fetchElection();
    console.log("ELECTION METADATA => ", electionMetadata);
    const results = electionMetadata.results;

    if (!results) {
      console.log("No results yet. Wait a couple of minutes.");
      document.querySelector(".js-votes-results-error-fetch").classList.remove("hide");
      return;
    }

    for (let idx = 0; idx < results.length; idx += 1) {
      const questionAnswersInputs = document.querySelectorAll(`*[data-question-idx="${idx}"]`);
      for (const answerInput of questionAnswersInputs) {
        const answerId = answerInput.dataset.answerId;
        const answerVotes = results[idx][answerId];
        answerInput.value = answerVotes;
        console.log(`FINAL FOR QUESTION ${idx} - ANSWER ${answerId} - VOTES ${answerVotes}`);
      }
    }
  }

  const client = initVocdoniClient();
  fetchVotesStats(client);
}

document.addEventListener("DOMContentLoaded", () => {
  voteEndedStep();
});
