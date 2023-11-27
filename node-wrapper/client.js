const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");

/**
 * Initialize the Vocdoni SDK Client with data from ENV variables
 */
const vocdoniClient = () => {
  const wallet = new Wallet(process.env.VOCDONI_WALLET_PRIVATE_KEY);
  const env = process.env.VOCDONI_API_ENV;
  const client =  new VocdoniSDKClient({ env, wallet });

  if (process.env.VOCDONI_ELECTION_ID) {
    client.setElectionId(process.env.VOCDONI_ELECTION_ID);
  }

  return client;
};

/**
 * Creates or obtains (if already exists) the Vocdoni client account using data from ENV variables
 */
const clientInfo = () => {
  const client = vocdoniClient();
  return client.createAccount();
};

module.exports.vocdoniClient = vocdoniClient;
module.exports.clientInfo = clientInfo;
