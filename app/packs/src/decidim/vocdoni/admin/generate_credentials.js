/**
 * Saves the Wallet's public key generated from participants' data provided by an admin in a deterministic way.
 * This means that if we provide an email and a date of birth, we'll always return the same wallet.
 *
 * @returns {void}
 */

import { Wallet } from "@ethersproject/wallet";

const initializeGenerateCredentialsForm = () => {
  const newCensusCredentialsForm = document.querySelector("form.new_census_credentials");
  if (!newCensusCredentialsForm) {
    return;
  }

  // TODO: actually generate a deterministic Wallet and not a random one xD
  const generateDeterministicWallet = (email, bornAt) => {
    const wallet = Wallet.createRandom();
    return wallet.publicKey;
  }

  const generateWalletsOnForm = (form, onSuccess) => {
    for (const credential of form.querySelectorAll("ul.credentials li")) {
      const email = credential.querySelector(".credential_email").value;
      const bornAt = credential.querySelector(".credential_born_at").value;
      const walletPublicKeyField = credential.querySelector(".credential_wallet_public_key");
      const walletPublicKey = generateDeterministicWallet(email, bornAt);

      walletPublicKeyField.value = walletPublicKey;
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
