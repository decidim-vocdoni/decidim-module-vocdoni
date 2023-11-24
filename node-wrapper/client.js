const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require('@ethersproject/wallet');

const vocdoniClient = () => {
	const wallet = new Wallet(process.env.VOCDONI_WALLET_PRIVATE_KEY);
  const env = process.env.VOCDONI_API_ENV;
  const client =  new VocdoniSDKClient({ env, wallet });

  if (process.env.VOCDONI_ELECTION_ID) {
    client.setElectionId(process.env.VOCDONI_ELECTION_ID);
  }

  return client;
};

const clientInfo = () => {
  const client = vocdoniClient();
  return client.createAccount();
};

module.exports.vocdoniClient = vocdoniClient;
module.exports.clientInfo = clientInfo;