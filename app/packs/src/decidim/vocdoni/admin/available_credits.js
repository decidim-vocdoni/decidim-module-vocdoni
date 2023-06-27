import { initVocdoniClient } from "src/decidim/vocdoni/admin/utils/init_vocdoni_client";

const CREDIT_SPAN_SELECTOR = ".js-vocdoni-credits-balance";
const NO_TOKENS_MESSAGE_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens-section";
const COLLECT_TOKENS_BUTTON_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens";
const CONTAINER_SELECTOR = ".process-content";
const ACTIONS_BUTTONS_SELECTOR = ".js-vocdoni-interruptible, #new_setup_ button[type=submit]";
const SPINNER_CLASS = "spinner-container";

export const getAvailableCredits = async () => {
  const client = initVocdoniClient();
  const clientInfo = await client.createAccount();
  return clientInfo.balance;
};

const showAvailableCredits = async () => {
  const creditsSpan = document.querySelector(CREDIT_SPAN_SELECTOR);
  if (!creditsSpan) {
    return;
  }

  const availableCredits = await getAvailableCredits();

  if (availableCredits === 0) {
    document.querySelector(NO_TOKENS_MESSAGE_SELECTOR).classList.remove("hide");
    document.querySelectorAll(ACTIONS_BUTTONS_SELECTOR).forEach((element) => {
      element.disabled = true;
    });
  }

  creditsSpan.innerHTML = availableCredits;
};

const collectFaucetTokensListener = async () => {
  const collectFaucetTokensButton = document.querySelector(COLLECT_TOKENS_BUTTON_SELECTOR);
  if (!collectFaucetTokensButton) {
    return;
  }

  collectFaucetTokensButton.addEventListener("click", async () => {
    document.querySelector(CONTAINER_SELECTOR).classList.add(SPINNER_CLASS);
    const client = initVocdoniClient();
    await client.collectFaucetTokens();
    showAvailableCredits();
    document.querySelector(COLLECT_TOKENS_BUTTON_SELECTOR).classList.add("hide");
    document.querySelector(NO_TOKENS_MESSAGE_SELECTOR).classList.add("hide");
    document.querySelector(CONTAINER_SELECTOR).classList.remove(SPINNER_CLASS);
    document.querySelectorAll(ACTIONS_BUTTONS_SELECTOR).forEach((element) => {
      element.disabled = false;
    });
  });
}

document.addEventListener("DOMContentLoaded", () => {
  showAvailableCredits();
  collectFaucetTokensListener();
});
