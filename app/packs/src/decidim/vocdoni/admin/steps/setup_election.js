import { EnvOptions } from "@vocdoni/sdk";
import SetupElection from "src/decidim/vocdoni/admin/setup_election";

const setupElectionStep = async () => {
  // Setup election step

  const createElectionForm = document.querySelector("form.create_election");
  if (!createElectionForm) {
    return;
  }

  const onSuccess = (electionId) => {
    createElectionForm.querySelector("#setup_vocdoni_election_id").value = electionId;
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

    const election = new SetupElection({
      walletPrivateKey: createElectionForm.querySelector("#setup_wallet_private_key").value,
      graphqlApiUrl: `${window.location.origin}/api`,
      componentId: window.location.pathname.split("/")[5],
      electionId: window.location.pathname.split("/")[8],
      environment: EnvOptions.DEV
    }, onSuccess, onFailure);
    election.run();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  setupElectionStep();
});
