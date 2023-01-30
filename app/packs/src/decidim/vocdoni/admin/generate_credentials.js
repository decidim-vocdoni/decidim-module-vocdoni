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
  const generateDeterministicWallet = async (email, bornAt) => {
    const address = await Wallet.createRandom().getAddress();
    return new Promise((resolve) => {
      resolve(address);
    });
  }

  const generateWalletOnForm = async (credential) => {
    const email = credential.querySelector(".credential_email").value;
    const bornAt = credential.querySelector(".credential_born_at").value;
    const walletPublicKeyField = credential.querySelector(".credential_wallet_public_key");
    const walletPublicKey = await generateDeterministicWallet(email, bornAt);

    walletPublicKeyField.value = walletPublicKey;
  }

  const generateWalletsOnForm = async (form, onSuccess) => {
    const credentials = form.querySelectorAll("ul.credentials li");
    for (const credential of credentials) {
      await generateWalletOnForm(credential);
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
