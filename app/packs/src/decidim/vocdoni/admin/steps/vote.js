import { VocdoniSDKClient } from "@vocdoni/sdk";

// Votes step
//
// Fetch the votes from the API and show them in the UI
const voteStep = async () => {
  const electionVotesMetadataTable = document.querySelector(".js-votes-count");
  if (!electionVotesMetadataTable) {
    return;
  }

  // Wait for 30s
  const WAIT_TIME_MS = 30000;

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
      const $questionAnswersCells = $(`td[data-question-idx="${idx}"]`);
      for (const answerCell of $questionAnswersCells) {
        const answerId = $(answerCell).data("answer-id");
        const answerVotes = results[idx][answerId];
        answerCell.innerHTML = answerVotes;
        console.log(`FOR QUESTION ${idx} - ANSWER ${answerId} - VOTES ${answerVotes}`);
      }
    }
  }

  const currentVocdoniWalletPrivateKey = electionVotesMetadataTable.dataset.vocdoniWalletPrivateKey;
  const electionUniqueId = electionVotesMetadataTable.dataset.electionUniqueId;
  const vocdoniEnv = electionVotesMetadataTable.dataset.vocdoniEnv;

  const client = new VocdoniSDKClient({
    env: vocdoniEnv,
    wallet: currentVocdoniWalletPrivateKey
  })
  client.setElectionId(electionUniqueId);

  fetchVotesStats(client);
  setInterval(fetchVotesStats, WAIT_TIME_MS, client);
}

document.addEventListener("DOMContentLoaded", () => {
  voteStep();
});
