import { initVocdoniClient } from "src/decidim/vocdoni/admin/utils/init_vocdoni_client";
import { ElectionStatus } from "@vocdoni/sdk";

const ELECTION_VOTES_SELECTOR = ".js-votes-count";
const INTERUPTIBLE_CONTINUE_BUTTON_SELECTOR = ".js-vocdoni-interruptible[data-action='continue']";
const INTERUPTIBLE_PAUSE_BUTTON_SELECTOR = ".js-vocdoni-interruptible[data-action='pause']";
const INTERUPTIBLE_CANCEL_BUTTON_SELECTOR = ".js-vocdoni-interruptible[data-action='cancel']";
const INTERUPTIBLE_END_BUTTON_SELECTOR = ".js-vocdoni-interruptible[data-action='end']";
const CONTAINER_SELECTOR = ".process-content";
const INTERRUPTIBLE_FORM_SELECTOR = "#new_election_status_";
const STATUS_FIELD_SELECTOR = "#election_status_status";


// Fetch the votes from the API and show them in the UI
const fetchTheVotesStats = async (electionMetadata) => {
  const electionVotesMetadataTable = document.querySelector(ELECTION_VOTES_SELECTOR);
  if (!electionVotesMetadataTable) {
    return;
  }

  // Wait for 30s
  const WAIT_TIME_MS = 30000;

  /*
   * Fetch the votes stats from the Vocdoni API
   *
   * @param {object} electionMetadata - The election metadata with the results key
   * @returns void
   */
  const fetchVotesStats = async () => {
    const results = electionMetadata.results;

    for (let idx = 0; idx < results.length; idx += 1) {
      const $questionAnswersCells = $(`td[data-question-idx="${idx}"]`);
      for (const answerCell of $questionAnswersCells) {
        const answerValue = $(answerCell).data("answer-value");
        const answerVotes = results[idx][answerValue];
        answerCell.innerHTML = answerVotes;
        console.log(`FOR QUESTION ${idx} - ANSWER ${answerValue} - VOTES ${answerVotes}`);
      }
    }
  }

  fetchVotesStats();
  setInterval(fetchVotesStats, WAIT_TIME_MS);
}


/* Handle the election status
 * Shows the different buttons depending on the election status
 *
 * @param {object} electionMetadata - The election metadata
 *
 * @returns void
 */
const handleElectionStatus = (electionMetadata) => {
  const continueButton = document.querySelector(INTERUPTIBLE_CONTINUE_BUTTON_SELECTOR);
  const pauseButton = document.querySelector(INTERUPTIBLE_PAUSE_BUTTON_SELECTOR);
  const cancelButton = document.querySelector(INTERUPTIBLE_CANCEL_BUTTON_SELECTOR);
  const endButton = document.querySelector(INTERUPTIBLE_END_BUTTON_SELECTOR);

  if (!cancelButton || !endButton) {
    return;
  }

  switch (electionMetadata.status) {
  case ElectionStatus.PAUSED:
    continueButton.classList.remove("hide");
    cancelButton.classList.remove("hide");
    endButton.classList.remove("hide");
    break;
  case ElectionStatus.READY:
    pauseButton.classList.remove("hide");
    cancelButton.classList.remove("hide");
    endButton.classList.remove("hide");
    break;
  default:
    console.log("Unknown election status");
  }
}

// When interruptible is enabled, handle the different actions that the admin can do
const handleInterruptibleElectionActions = async () => {
  const interruptibleForm = document.querySelector(INTERRUPTIBLE_FORM_SELECTOR);
  if (!interruptibleForm) {
    return;
  }

  // If we do it with Vanilla JavaScript, the event is still submitted. This is a problem with Rails UJS, and we
  // need to use JQuery as a workaround
  // interruptibleForm.addEventListener("submit", (event) => {
  $(INTERRUPTIBLE_FORM_SELECTOR).on("submit", async (event) => {
    event.preventDefault();

    document.querySelector(CONTAINER_SELECTOR).classList.add("spinner-container");
    const action = document.activeElement.dataset.action;
    console.log("ACTION => ", action);
    const client = initVocdoniClient();
    const oldElectionMetadata = await client.fetchElection();
    const oldElectionStatus = oldElectionMetadata.status;
    const statusField = document.querySelector(STATUS_FIELD_SELECTOR);
    console.log(client);

    switch (action) {
    case "continue":
      await client.continueElection();
      statusField.value = "vote";
      break;
    case "pause":
      await client.pauseElection();
      statusField.value = "paused";
      break;
    case "cancel":
      await client.cancelElection();
      statusField.value = "canceled";
      break;
    case "end":
      await client.endElection();
      statusField.value = "vote_ended";
      break;
    default:
      console.log("Unknown action");
    }

    document.querySelector(CONTAINER_SELECTOR).classList.remove("spinner-container");
    const newElectionMetadata = await client.fetchElection();
    const newElectionStatus = newElectionMetadata.status;
    if (oldElectionStatus !== newElectionStatus) {
      console.log(`Election status changed from ${oldElectionStatus} to ${newElectionStatus}`);
      event.currentTarget.submit();
    }
  });
}

document.addEventListener("DOMContentLoaded", async () => {
  const client = initVocdoniClient();
  const electionMetadata = await client.fetchElection();
  console.log("ELECTION METADATA => ", electionMetadata);
  console.log("ELECTION STATUS => ", ElectionStatus[electionMetadata.status]);

  fetchTheVotesStats(electionMetadata);
  handleElectionStatus(electionMetadata);
  handleInterruptibleElectionActions();
});
