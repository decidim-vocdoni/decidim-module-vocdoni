import { VocdoniSDKClient } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";

// Initialize the Vocdoni SDK Client with the data from the DOM
//
// @returns {object} - The Vocdoni SDK client instantiated with the wallet
//                    and the election ID if it's present or an empty object
export const initVocdoniClient = () => {
  const vocdoniClientMetadata = document.querySelector(".js-vocdoni-client");
  if (!vocdoniClientMetadata) {
    return {};
  }

  // const walletPrivateKey = vocdoniClientMetadata.dataset.vocdoniWalletPrivateKey;
  const vocdoniElectionId = vocdoniClientMetadata.dataset.vocdoniElectionId;
  const env = vocdoniClientMetadata.dataset.vocdoniEnv;

  const wallet = new Wallet("0x51f93487a60fccdd5da6addce9db79b02530c45e5d3bc4f6315de70444ed8429");
  const client = new VocdoniSDKClient({ env, wallet });

  if (vocdoniElectionId) {
    client.setElectionId(vocdoniElectionId);
  }

  return client;
}
