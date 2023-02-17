/**
 * Saves the Wallet's public key generated from participants' data provided by an admin in a deterministic way.
 * This means that if we provide an email and a date of birth, we'll always return the same wallet.
 *
 * @returns {void}
 */

import { VocdoniSDKClient } from "@vocdoni/sdk";

const initializeGenerateCredentialsForm = () => {
  const newCensusCredentialsForm = document.querySelector("form.new_census_credentials");
  if (!newCensusCredentialsForm) {
    return;
  }

  const generateWalletOnForm = (credential) => {
    const email = credential.querySelector(".credential_email").value;
    const bornAt = credential.querySelector(".credential_born_at").value;
    const walletAddressField = credential.querySelector(".credential_wallet_address");
    const wallet = VocdoniSDKClient.generateWalletFromData(email, bornAt);

    walletAddressField.value = wallet.address;
  }

  const generateWalletsOnForm = (form, onSuccess) => {
    const credentials = form.querySelectorAll("ul.credentials li");
    for (const credential of credentials) {
      generateWalletOnForm(credential);
    }

    onSuccess();
  }

  $("form.new_census_credentials").on("submit", (event) => {
    event.preventDefault();

    generateWalletsOnForm(newCensusCredentialsForm, () => {
      newCensusCredentialsForm.submit();
    });
  });
};

document.addEventListener("DOMContentLoaded", () => {
  initializeGenerateCredentialsForm();
});
