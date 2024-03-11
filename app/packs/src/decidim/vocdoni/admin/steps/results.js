
const RESULTS_SPAN_SELECTOR = ".js-votes-results";

export const getElectionResults = async () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  const resultsPath = vocdoniClientMetadata.dataset.htmlResultsPath;
  const response = await fetch(resultsPath);
  const result = await response.text();
  return result;
};

const checkResultsElection = async (resultsSpan) => {
  const html = await getElectionResults();
  if (html.indexOf("spinner-container") === -1) {
    resultsSpan.innerHTML = html;
    // Activates accordion again
    $(resultsSpan).foundation();
    resultsSpan.classList.remove("spinner-container")
  }
  else {
    // Try again in a few seconds
    setTimeout(() => {
      checkResultsElection(resultsSpan);
    }, 3000);
  }
};

document.addEventListener("DOMContentLoaded", () => {
  const resultsSpan = document.querySelector(RESULTS_SPAN_SELECTOR);

  if (resultsSpan) {
    checkResultsElection(resultsSpan);
  }
});
