const CREDIT_SPAN_SELECTOR = ".js-vocdoni-credits-balance";
const CREATING_SPAN_SELECTOR = ".js-vocdoni-election-creating";
const CREATING_ERROR_SPAN_SELECTOR = ".js-vocdoni-election-creating-error";
const CREATED_SPAN_SELECTOR = ".js-vocdoni-election-created";
const GENERAL_SUBMIT_SELECTOR = ".form-general-submit";
const NO_TOKENS_MESSAGE_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens-section";
const ACTIONS_BUTTONS_SELECTOR = ".js-vocdoni-interruptible, #new_setup_ button[type=submit]";
const MAX_WAITING_TIME = 10000;
let CHECK_STATUS = true;

export const getElectionInfo = async () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  const infoPath = vocdoniClientMetadata.dataset.infoPath;
  const response = await fetch(infoPath);
  const result = await response.json();
  return result;
};

const showAvailableCredits = async (creditsSpan, clientInfo) => {
  if (!creditsSpan) {
    return;
  }

  const availableCredits = clientInfo.balance;

  if (availableCredits === 0) {
    document.querySelector(NO_TOKENS_MESSAGE_SELECTOR).classList.remove("hide");
    document.querySelectorAll(ACTIONS_BUTTONS_SELECTOR).forEach((element) => {
      element.disabled = true;
    });
  }

  creditsSpan.innerHTML = availableCredits;
};

const checkCreatingElection = async (creatingSpan, vocdoniElectionId) => {
  const creatingErrorSpan = document.querySelector(CREATING_ERROR_SPAN_SELECTOR);
  const createdSpan = document.querySelector(CREATED_SPAN_SELECTOR);
  const submit = document.querySelector(GENERAL_SUBMIT_SELECTOR);
  if (!creatingSpan) {
    return;
  }

  if (vocdoniElectionId) {
    creatingSpan.classList.add("hide");
    createdSpan.classList.remove("hide");
  } else if (CHECK_STATUS) {
    // try again in a few seconds
    setTimeout(async () => {
      const electionInfo = await getElectionInfo();
      checkCreatingElection(creatingSpan, electionInfo.vocdoniElectionId);
    }, 3000);
  } else {
    console.log("ok, enough of this");
    creatingSpan.classList.add("hide");
    creatingErrorSpan.classList.remove("hide");
    if (submit) {
      submit.classList.remove("hide");
    }
  }
};

document.addEventListener("DOMContentLoaded", async () => {
  const creatingSpan = document.querySelector(CREATING_SPAN_SELECTOR);
  const creditsSpan = document.querySelector(CREDIT_SPAN_SELECTOR);

  if (creditsSpan || creatingSpan) {
    const electionInfo = await getElectionInfo();
    showAvailableCredits(creditsSpan, electionInfo.clientInfo);
    checkCreatingElection(creatingSpan, electionInfo.vocdoniElectionId);
    if (creatingSpan) {
      setTimeout(() => {
        CHECK_STATUS = false;
      }, MAX_WAITING_TIME);
    }
  }
});
