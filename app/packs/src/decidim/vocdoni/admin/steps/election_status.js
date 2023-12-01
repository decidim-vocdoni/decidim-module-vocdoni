const CREDIT_SPAN_SELECTOR = ".js-vocdoni-credits-balance";
const CREATING_SPAN_SELECTOR = ".js-vocdoni-election-creating";
const CREATING_ERROR_SPAN_SELECTOR = ".js-vocdoni-election-creating-error";
const CREATED_SPAN_SELECTOR = ".js-vocdoni-election-created";
const DANGER_ZONE_SELECTOR = ".js-danger-zone";
const GENERAL_SUBMIT_SELECTOR = ".form-general-submit";
const NO_TOKENS_MESSAGE_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens-section";
const EXPLORER_URL_SELECTOR = ".js-vocdoni-explorer-url";
const FORM_ID = "new_election_status_";
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
  }

  creditsSpan.innerHTML = availableCredits;
};

const checkCreatingElection = async (creatingSpan, vocdoniElectionId) => {
  const creatingErrorSpan = document.querySelector(CREATING_ERROR_SPAN_SELECTOR);
  const createdSpan = document.querySelector(CREATED_SPAN_SELECTOR);
  const submit = document.querySelector(GENERAL_SUBMIT_SELECTOR);
  const explorerLink = document.querySelector(EXPLORER_URL_SELECTOR);
  const dangerZone = document.querySelector(DANGER_ZONE_SELECTOR);
  if (!creatingSpan) {
    return;
  }

  if (vocdoniElectionId) {
    creatingSpan.classList.add("hide");
    createdSpan.classList.remove("hide");
    if (explorerLink) {
      explorerLink.href = `${explorerLink.href.substr(0, explorerLink.href.indexOf("#") + 1)}/${vocdoniElectionId}`;
    }
    if (dangerZone) {
      dangerZone.classList.remove("hide");
    }
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

const maskSubmitInAjax = () => {
  const form = document.getElementById(FORM_ID);
  const callout = document.querySelector(".callout-wrapper");
  const progress = document.querySelector(".progress-indicator");
  if (!form) {
    return;
  }
  // We need to handle the event in JQuery because the confirmation dialog ends up
  // submiting the form using JQuery too (see decidim-core/app/packs/src/decidim/confirm.js)
  $(form).on("submit", async (evt) => {
    const dangerZone = document.querySelector(DANGER_ZONE_SELECTOR);
    if (!dangerZone) {
      return;
    }
    const token = document.querySelector('meta[name="csrf-token"]');
    const target = evt.currentTarget || evt.target || form;
    evt.preventDefault();
    dangerZone.classList.add("spinner-container");
    const data = new FormData(target);
    if(token) {
      data.set("authenticity_token", token.content);
    }
    const response = await fetch(form.action, {
      method: form.method,
      body: data,
      headers: {
        "Accept": "text/html"
      }
    });
    const body = await response.text();
    if (response.ok) {
      let el = document.createElement("html");
      el.innerHTML = body;
      let newForm = el.querySelector(`#${FORM_ID}`);
      let newCallout = el.querySelector(".callout-wrapper");
      let newProgress = el.querySelector(".progress-indicator");
      if (newForm) {
        // redrawing the form
        form.innerHTML = newForm.innerHTML;
        // adding callouts
        if (callout && newCallout) {
          callout.innerHTML = newCallout.innerHTML;
        }
        // adding progress indicator
        if (progress && newProgress) {
          progress.innerHTML = newProgress.innerHTML;
        }
      } else {
        // if no form, just reload the page
        window.location.reload();
      }
    } else {
      console.error("Error submitting form", body);
    }
    dangerZone.classList.remove("spinner-container");
  });

  const buttons = document.querySelectorAll(".js-button-submit")
  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      const dangerZone = document.querySelector(DANGER_ZONE_SELECTOR);
      if (dangerZone) {
        dangerZone.classList.add("spinner-container");
      }
    });
  });

  $(document).on("closed.zf.reveal", "[data-reveal]", () => {
    const dangerZone = document.querySelector(DANGER_ZONE_SELECTOR);
    if (dangerZone) {
      dangerZone.classList.remove("spinner-container");
    }
  });
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

  maskSubmitInAjax();
});
