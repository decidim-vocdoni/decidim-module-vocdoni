const ELECTION_VOTES_SELECTOR = ".js-votes-count";
// Wait for 30s between stats refresh
const WAIT_TIME_MS = 30000;

export const getElectionResults = async () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  const resultsPath = vocdoniClientMetadata.dataset.resultsPath;
  const response = await fetch(resultsPath);
  const result = await response.json();
  return result;
};

// Fetch the votes from the API and show them in the UI
const fetchTheVotesStats = async () => {
  const electionVotesMetadataTable = document.querySelector(ELECTION_VOTES_SELECTOR);
  if (!electionVotesMetadataTable) {
    return;
  }

  // Fetch the votes stats from the Vocdoni API
  const fetchVotesStats = async () => {
    const { election } = await getElectionResults();
    console.log("ELECTION METADATA => ", election);
    console.group("Partial Results");
    election.forEach((question, idx) => {
      question.forEach((answer, value) => {
        const dom = document.querySelector(`td[data-question-idx="${idx}"][data-answer-value="${value}"]`);
        console.log(`Question ${idx} - ANSWER ${value} VOTES ${answer}`, dom);
        dom.innerHTML = answer;
      });
    });
    console.groupEnd();
  };

  fetchVotesStats();
  setInterval(fetchVotesStats, WAIT_TIME_MS);
};

document.addEventListener("DOMContentLoaded", () => {
  fetchTheVotesStats();
});
