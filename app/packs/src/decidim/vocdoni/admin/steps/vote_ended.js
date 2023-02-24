import { VocdoniSDKClient } from "@vocdoni/sdk";

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

  const vocdoniWalletPrivateKey = electionResultsForm.dataset.vocdoniWalletPrivateKey;
  const electionUniqueId = electionResultsForm.dataset.electionUniqueId;
  const vocdoniEnv = electionResultsForm.dataset.vocdoniEnv;

  const client = new VocdoniSDKClient({
    env: vocdoniEnv,
    wallet: vocdoniWalletPrivateKey
  })
  client.setElectionId(electionUniqueId);

  fetchVotesStats(client);
}

document.addEventListener("DOMContentLoaded", () => {
  voteEndedStep();
});
