import { initVocdoniClient } from "src/decidim/vocdoni/admin/utils/init_vocdoni_client";

const CREDIT_SPAN_SELECTOR = ".js-vocdoni-credits-balance";
const NO_TOKENS_MESSAGE_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens-section";
const COLLECT_TOKENS_BUTTON_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens";
const CONTAINER_SELECTOR = ".process-content";

const showAvailableCredits = async () => {
  const creditsSpan = document.querySelector(CREDIT_SPAN_SELECTOR);
  if (!creditsSpan) {
    return;
  }

  const client = initVocdoniClient();
  const clientInfo = await client.createAccount();

  if (clientInfo.balance === 0) {
    document.querySelector(NO_TOKENS_MESSAGE_SELECTOR).classList.remove("hide");
    document.querySelectorAll(".js-vocdoni-interruptible").forEach((element) => {
      element.disabled = true;
    });
  }

  creditsSpan.innerHTML = clientInfo.balance;
};

const collectFaucetTokensListener = async () => {
  const collectFaucetTokensButton = document.querySelector(COLLECT_TOKENS_BUTTON_SELECTOR);
  if (!collectFaucetTokensButton) {
    return;
  }

  collectFaucetTokensButton.addEventListener("click", async () => {
    document.querySelector(CONTAINER_SELECTOR).classList.add("spinner-container");
    const client = initVocdoniClient();
    await client.collectFaucetTokens();
    // document.reload();
    showAvailableCredits();
    document.querySelector(COLLECT_TOKENS_BUTTON_SELECTOR).classList.add("hide");
    document.querySelector(NO_TOKENS_MESSAGE_SELECTOR).classList.add("hide");
    document.querySelector(CONTAINER_SELECTOR).classList.remove("spinner-container");
  });
}

document.addEventListener("DOMContentLoaded", () => {
  showAvailableCredits();
  collectFaucetTokensListener();
});
