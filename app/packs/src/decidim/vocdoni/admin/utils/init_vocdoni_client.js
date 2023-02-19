import { VocdoniSDKClient } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";

// Initialize the Vocdoni SDK Client with the data from the DOM
//
// @returns {object} - The Vocdoni SDK client instantiated with the the wallet
//                    and the election ID if it's present
export const initVocdoniClient = () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  if (!vocdoniClientMetadata) {
    return;
  }

  const walletPrivateKey = vocdoniClientMetadata.dataset.vocdoniWalletPrivateKey;
  const vocdoniElectionId = vocdoniClientMetadata.dataset.vocdoniElectionId;
  const env = vocdoniClientMetadata.dataset.vocdoniEnv;

  const wallet = new Wallet(walletPrivateKey);
  const client = new VocdoniSDKClient({ env, wallet });

  if (vocdoniElectionId) {
    client.setElectionId(vocdoniElectionId);
  }

  return client;
}
