/* eslint-disable no-warning-comments, no-plusplus, no-new */

import { EnvOptions, PlainCensus } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";
import SetupElection from "src/decidim/vocdoni/admin/setup_election";

const setupElectionStep = async () => {
  // Setup election step

  // TODO: this function needs to be changed once we have a real Census
  const initializeCensus = async (divDemoCensus) => {
    // How many addresses we'll create for the Demo
    const TEST_CENSUS = 5;

    const showDemoCensus = (div) => {
      div.classList.remove("hide");
      return div.querySelector("textarea");
    }

    const census = new PlainCensus();
    const textareaDemoCensus = showDemoCensus(divDemoCensus);
    textareaDemoCensus.rows = TEST_CENSUS;
    textareaDemoCensus.value = "";
    for (let idx = 1; idx < TEST_CENSUS + 1; idx++) {
      const wallet = Wallet.createRandom({locale: "en"});
      const mnemonic = wallet.mnemonic.phrase;
      console.log("VOTER ", idx, " =>", mnemonic);
      textareaDemoCensus.value += `${mnemonic}\n`;
      census.add(await wallet.getAddress());
    };

    return census;
  }

  const createElectionForm = document.querySelector("form.create_election");

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

  if (!createElectionForm) {
    return;
  }

  const divDemoCensus = createElectionForm.querySelector(".js-demo-census");
  const census = await initializeCensus(divDemoCensus);

  // If we do it with Vanilla JavaScript, the event is still submitted. This is a problem with Rails UJS, and we
  // need to use JQuery as a workaround
  // createElectionForm.addEventListener("submit", (event) => {
  $("form.create_election").on("submit", (event) => {
    event.preventDefault();

    const setupElectionButton = createElectionForm.querySelector(".form-general-submit button");
    showLoadingSpinner(setupElectionButton);

    new SetupElection({
      walletPrivateKey: createElectionForm.querySelector("#setup_wallet_private_key").value,
      census: census,
      graphqlApiUrl: `${window.location.origin}/api`,
      componentId: window.location.pathname.split("/")[5],
      electionId: window.location.pathname.split("/")[8],
      environment: EnvOptions.DEV
    }, onSuccess, onFailure);
  });
}

document.addEventListener("DOMContentLoaded", () => {
  setupElectionStep();
});
