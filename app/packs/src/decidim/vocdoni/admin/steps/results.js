
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
  document.querySelectorAll(".vocdoni__accordion-trigger").forEach(trigger => {
    const isOpen = trigger.getAttribute("data-open") === "true";
    trigger.querySelector(".arrow-down").style.display = isOpen ? "none" : "inline";
    trigger.querySelector(".arrow-up").style.display = isOpen ? "inline" : "none";
  });

  document.querySelectorAll(".vocdoni__accordion-trigger").forEach(trigger => {
    trigger.addEventListener("click", function() {
      const panelId = trigger.getAttribute("data-controls");
      const panel = document.getElementById(panelId);
      const isOpen = trigger.getAttribute("data-open") === "true";

      trigger.setAttribute("data-open", !isOpen);
      panel.setAttribute("aria-hidden", isOpen);

      trigger.querySelector(".arrow-down").style.display = isOpen ? "inline" : "none";
      trigger.querySelector(".arrow-up").style.display = isOpen ? "none" : "inline";

      trigger.classList.toggle("is-open", !isOpen);
      panel.classList.toggle("is-hidden", isOpen);
    });
  });

  const resultsSpan = document.querySelector(RESULTS_SPAN_SELECTOR);

  if (resultsSpan) {
    checkResultsElection(resultsSpan);
  }
});
