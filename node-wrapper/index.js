/* eslint-disable no-unused-vars */

/**
 * All methods in this file will be translated to ruby methods by the NodeRunner
 * All returned data must be compatible with a valid JSON object
 * */
const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");
const { vocdoniClient, clientInfo } = require(`${process.env.VOCDONI_WRAPPER_PATH}/client.js`);
const { vocdoniElection } = require(`${process.env.VOCDONI_WRAPPER_PATH}/election.js`);

/**
 * Creates a random Wallet and returns the private key
 */ 
const randomWallet = (name) => {
  const wallet = Wallet.createRandom();
  return {
    address: wallet.address, 
    privateKey: wallet.privateKey, 
    publicKey: wallet.publicKey
  };
};

/**
 * Creates a deterministc wallet from a given token (that can be pretty much anything).
 * The wallet is secured by adding a salt provided in the env variable VOCDONI_SALT
 */
const deterministicWallet = (token) => {
  const wallet = VocdoniSDKClient.generateWalletFromData(`${token}-${process.env.VOCDONI_SALT}`);
  return {
    address: wallet.address, 
    privateKey: wallet.privateKey, 
    publicKey: wallet.publicKey
  };
};

/**
 * Info about the env (mostly for testing purposes)
 */ 
const env = () => {
  return {
    "VOCDONI_WALLET_PRIVATE_KEY": process.env.VOCDONI_WALLET_PRIVATE_KEY,
    "VOCDONI_SALT": process.env.VOCDONI_SALT,
    "VOCDONI_API_ENV": process.env.VOCDONI_API_ENV,
    "VOCDONI_ELECTION_ID": process.env.VOCDONI_ELECTION_ID,
    "VOCDONI_WRAPPER_PATH": process.env.VOCDONI_WRAPPER_PATH
  }
};

/**
 * Info about the client
 */
const info = async () => {
  const _info = await clientInfo();
  return {
    clientInfo: {
      address: _info.address,
      nonce: _info.nonce,
      infoUrl: _info.infoUrl,
      balance: _info.balance,
      electionIndex: _info.electionIndex,
      metadata: _info.metadata,
      sik: _info.sik
    }
  }
};

/**
 * Gives a readable representation of an election object with the data provided
 * */
const election = async (electionData, questionsData, censusData) => {
  const _election = await vocdoniElection(electionData, questionsData, censusData);
  return {
    election: {
      id: _election.id,
      title: _election.title,
      description: _election.description,
      startDate: _election.startDate,
      endDate: _election.endDate,
      electionType: _election.electionType,
      questions: _election.questions
    }
  }
}

/**
 * Creates the election an returns the ID for the Vocdoni Blockchain
 */
const createElection = async (electionData, questionsData, censusData) => {
  const client = vocdoniClient();
  const _election = await vocdoniElection(electionData, questionsData, censusData);
  return await client.createElection(_election);
}

/**
 * This only works on stg/dev environments
 * Collects more credits for free
 */ 
const collectFaucetTokens = async () => {
  const client = vocdoniClient();
  return await client.collectFaucetTokens();
};
