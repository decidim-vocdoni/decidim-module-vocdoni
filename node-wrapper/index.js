/* eslint-disable no-unused-vars */

/**
 * All methods in this file will be translated to ruby methods by the NodeRunner
 * All returned data must be compatible with a valid JSON object
 * */
const { VocdoniSDKClient } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");
const { vocdoniClient, clientInfo } = require(`${process.env.VOCDONI_WRAPPER_PATH}/client.js`);
const { vocdoniElection, updateElectionCensus } = require(`${process.env.VOCDONI_WRAPPER_PATH}/election.js`);

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
  const wallet = VocdoniSDKClient.generateWalletFromData(token);
  return {
    address: wallet.address,
    privateKey: wallet.privateKey,
    publicKey: wallet.publicKey
  };
};

/**
 * Information about the environment
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
 * Information about the client
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
 * Gives the election metadata for vote monitoring
 */
const electionMetadata = async () => {
  const client = vocdoniClient();
  const metadata = await client.fetchElection();
  return {
    title: metadata.title,
    description: metadata.description,
    header: metadata.header,
    streamUri: metadata.streamUri,
    startDate: metadata.startDate,
    endDate: metadata.endDate,
    electionType: metadata.electionType,
    voteType: metadata.voteType,
    questions: metadata.questions,
    maxCensusSize: metadata.maxCensusSize,
    id: metadata.id,
    organizationId: metadata.organizationId,
    status: metadata.status,
    voteCount: metadata.voteCount,
    finalResults: metadata.finalResults,
    results: metadata.results,
    manuallyEnded: metadata.manuallyEnded,
    fromArchive: metadata.fromArchive,
    chainId: metadata.chainId,
    creationTime: metadata.creationTime,
    metadataURL: metadata.metadataURL,
    isValid: metadata.isValid,
    raw: metadata.raw
  }
};

/**
 * Creates the election an returns the ID for the Vocdoni Blockchain
 */
const createElection = async (electionData, questionsData, censusData) => {
  const client = vocdoniClient();
  const _election = await vocdoniElection(electionData, questionsData, censusData);
  const electionId = await client.createElection(_election);
  return {
    electionId: electionId, 
    censusId: electionData.census.id,
    censusIdentifier: client.censusService.auth.identifier,
    censusAddress: client.censusService.auth.wallet.address,
    censusPrivateKey: client.censusService.auth.wallet.privateKey,
    censusPublicKey: client.censusService.auth.wallet.publicKey
  }
};

const updateCensus = async (censusAttributes, censusData) => {
  const client = vocdoniClient();
  const _info = await updateElectionCensus(client, censusAttributes, censusData);
  return JSON.stringify(_info);
};

/**
 * Continues the election (if paused)
 */
const continueElection = async () => {
  const client = vocdoniClient();
  return await client.continueElection();
};

/**
 * Pauses the election (if running)
 */
const pauseElection = async () => {
  const client = vocdoniClient();
  return await client.pauseElection();
};

/**
 * Cancels the election (thus invalidating it)
 */
const cancelElection = async () => {
  const client = vocdoniClient();
  return await client.cancelElection();
};

/**
 * Ends the election (and publishes results in the Vocdoni Blockchain)
 */
const endElection = async () => {
  const client = vocdoniClient();
  return await client.endElection();
};

/**
 * This only works on stg/dev environments
 * Collects more credits for free
 */
const collectFaucetTokens = async () => {
  const client = vocdoniClient();
  return await client.collectFaucetTokens();
};
