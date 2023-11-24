/**
 * All methods in this file will be translated to ruby methods by the NodeRunner
 * All return data must be compatible with a valid JSON object
 * */
const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require('@ethersproject/wallet');
const { vocdoniClient, clientInfo } = require(`${process.env.VOCDONI_WRAPPER_PATH}/client.js`);

const randomWallet = (name) => {
	const wallet = Wallet.createRandom();
  return wallet.privateKey;
};

const deterministicWallet = (token) => {
	const wallet = VocdoniSDKClient.generateWalletFromData(`${token}-${process.env.VOCDONI_SALT}`);
	return wallet.privateKey;
};

const env = () => {
	return {
		"VOCDONI_WALLET_PRIVATE_KEY": process.env.VOCDONI_WALLET_PRIVATE_KEY,
		"VOCDONI_SALT": process.env.VOCDONI_SALT,
		"VOCDONI_API_ENV": process.env.VOCDONI_API_ENV,
		"VOCDONI_ELECTION_ID": process.env.VOCDONI_ELECTION_ID,
		"VOCDONI_WRAPPER_PATH": process.env.VOCDONI_WRAPPER_PATH
	}
};

const info = async () => {
	const info = await clientInfo();
	return {
		clientInfo: {
			address: info.address,
			nonce: info.nonce,
			infoUrl: info.infoUrl,
			balance: info.balance,
			electionIndex: info.electionIndex,
			metadata: info.metadata,
			sik: info.sik
		}
	}
};

const collectFaucetTokens = async () => {
	const client = vocdoniClient();
	return await client.collectFaucetTokens();
};
