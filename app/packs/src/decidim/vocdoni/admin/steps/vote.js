// Interval time in milliseconds for refreshing the statistics
const WAIT_TIME_MS = 30000;

// Fetch the votes from the API
export const getElectionResults = async () => {
  const vocdoniClientElement = document.querySelector(".js-vocdoni-client");
  if (vocdoniClientElement) {
    const resultsPath = vocdoniClientElement.dataset.resultsPath;
    if (resultsPath) {
      const response = await fetch(resultsPath);
      return response.json();
    }
  }
  return null;
};

// Update the DOM with the answer for a specific question index
const updateDomWithAnswer = (questionIdx, answer, value) => {
  const dom = document.querySelector(`td[data-question-idx="${questionIdx}"][data-answer-value="${value}"]`);
  if (dom) {
    dom.innerHTML = answer;
  }
};

// Fetch and display vote statistics for a given question index
const fetchAndDisplayVotes = async (questionIdx) => {
  const { election } = await getElectionResults();
  election[questionIdx]?.forEach(updateDomWithAnswer.bind(null, questionIdx));
};

// Process each accordion element to fetch and display stats if it's open
const processAccordion = async (accordion) => {
  if (accordion.style.display !== "none") {
    const questionIdxCell = accordion.querySelector("td[data-question-idx]");
    if (questionIdxCell) {
      const questionIdx = questionIdxCell.dataset.questionIdx;
      await fetchAndDisplayVotes(questionIdx);
    }
  }
};

// Check and fetch statistics for each accordion content on DOMContentLoaded
const checkAndFetchStats = async () => {
  document.querySelectorAll(".accordion-content").forEach(processAccordion);
};

// Set up initial fetch for all open accordions on page load
document.addEventListener("DOMContentLoaded", () => {
  checkAndFetchStats().then(() => console.log("Initial stats fetched"));
  setInterval(checkAndFetchStats, WAIT_TIME_MS);
});

// Set up event listeners on accordion titles to fetch stats when they are opened
document.querySelectorAll(".accordion-title").forEach((title) => {
  title.addEventListener("click", async (event) => {
    const accordionItem = event.target.closest(".accordion-item");
    const accordionContent = accordionItem.querySelector(".accordion-content");
    const isExpanded = accordionContent.getAttribute("aria-expanded") === "true";
    if (!isExpanded) {
      const questionIdxCell = accordionContent.querySelector("td[data-question-idx]");
      if (questionIdxCell) {
        const questionIdx = questionIdxCell.dataset.questionIdx;
        await fetchAndDisplayVotes(questionIdx);
      }
    }
  });
});
