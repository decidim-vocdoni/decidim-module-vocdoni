const CREDIT_SPAN_SELECTOR = ".js-vocdoni-credits-balance";
const NO_TOKENS_MESSAGE_SELECTOR = ".js-vocdoni-credits-collect-faucet-tokens-section";
const ACTIONS_BUTTONS_SELECTOR = ".js-vocdoni-interruptible, #new_setup_ button[type=submit]";

export const getAvailableCredits = async () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  const infoPath = vocdoniClientMetadata.dataset.infoPath;
  const response = await fetch(infoPath);
  const result = await response.json();
  return result.clientInfo.balance;
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

document.addEventListener("DOMContentLoaded", () => {
  showAvailableCredits();
});
