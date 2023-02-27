import CreateVocdoniElection from "../utils/create_vocdoni_election";
import { initVocdoniClient } from "../utils/init_vocdoni_client";

const setupElectionStep = async () => {
  // Setup election step
  const createElectionForm = document.querySelector("form.create_election");
  if (!createElectionForm) {
    return;
  }

  const onSuccess = (vocdoniElectionId) => {
    createElectionForm.querySelector("#setup_vocdoni_election_id").value = vocdoniElectionId;
    createElectionForm.submit();
  }

  const onFailure = () => {
    createElectionForm.querySelector(".js-election-create-error-message").classList.remove("hide");
  }

  const showLoadingSpinner = (setupElectionButton) => {
    setupElectionButton.disabled = true;
    setupElectionButton.querySelector(".loading").classList.remove("hide");
    setupElectionButton.querySelector(".text").classList.add("hide");
  }

  // If we do it with Vanilla JavaScript, the event is still submitted. This is a problem with Rails UJS, and we
  // need to use JQuery as a workaround
  // createElectionForm.addEventListener("submit", (event) => {
  $("form.create_election").on("submit", (event) => {
    event.preventDefault();

    const setupElectionButton = createElectionForm.querySelector(".form-general-submit button");
    showLoadingSpinner(setupElectionButton);

    const election = new CreateVocdoniElection({
      graphqlApiUrl: `${window.location.origin}/api`,
      defaultLocale: document.querySelector(".js-vocdoni-client").dataset.defaultLocale,
      componentId: window.location.pathname.split("/")[5],
      electionId: window.location.pathname.split("/")[8]
    }, onSuccess, onFailure);
    election.run();
  });
}

const showAvailableCredits = async () => {
  const creditsSpan = document.querySelector(".js-vocdoni-balance-credits");
  if (!creditsSpan) {
    return;
  }

  const client = initVocdoniClient();
  const clientInfo = await client.createAccount();

  creditsSpan.innerHTML = clientInfo.balance;
};

document.addEventListener("DOMContentLoaded", () => {
  setupElectionStep();
  showAvailableCredits();
});
