/**
 * Initializes the create wallet form with a private key created with ethers.js
 *
 * @returns {void}
 */

import { Wallet } from "@ethersproject/wallet";

const initializeCreateWalletForm = () => {
  const newWalletForm = document.querySelector("form.new_wallet");
  if (!newWalletForm) {
    return;
  }

  const walletPrivateKeyField = newWalletForm.querySelector("#wallet_private_key");
  if (!walletPrivateKeyField) {
    return;
  }

  const createRandomWallet = () => {
    const wallet = Wallet.createRandom();
    return wallet.privateKey;
  }

  walletPrivateKeyField.value = createRandomWallet();
};

document.addEventListener("DOMContentLoaded", () => {
  initializeCreateWalletForm();
});
