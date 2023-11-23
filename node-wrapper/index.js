const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require('@ethersproject/wallet');

const randomWallet = (name) => {
	const wallet = Wallet.createRandom();
  return wallet.privateKey;
}

const deterministicWallet = (token) => {
	const wallet = VocdoniSDKClient.generateWalletFromData(token);
	return wallet.privateKey;
};
