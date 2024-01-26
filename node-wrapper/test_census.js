/* eslint-disable no-unused-vars */

/**
 * Manual testing of the Vocdoni SDK Census features
 * */
process.env.VOCDONI_WRAPPER_PATH = `${__dirname}/`;
const { Election, VocdoniSDKClient, PlainCensus } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");
const { createElection } = require(`${process.env.VOCDONI_WRAPPER_PATH}index.js`);
const { vocdoniClient, clientInfo } = require(`${process.env.VOCDONI_WRAPPER_PATH}client.js`);
const { vocdoniElection, updateElectionCensus } = require(`${process.env.VOCDONI_WRAPPER_PATH}election.js`);

if (!process.env["WALLET"]) {
  console.error("WALLET env variable not found\n\nTry running:\n\n\tbin/rails runner 'puts Decidim::Vocdoni::Wallet.last.private_key'\n");
  console.error("Usage:\n\n\tWALLET_PRIVATE_KEY=<private_key> node node-wrapper/test_census.js\n");
  process.exit();
}

const addRandomWallet = async (census) => {
  const wallet = Wallet.createRandom();
  census.add(await wallet.getAddress());
  return wallet;
};

const wallet = new Wallet(process.env.WALLET);
const env = "dev";
const client =  new VocdoniSDKClient({ env, wallet });

const census = new PlainCensus()
addRandomWallet(census);

const election = Election.from({
  title: 'Election test #' + Math.round(Math.random()*1000000),
  description: 'Election test census',
  startDate: new Date(Date.now()),
  endDate: new Date(Date.now() + 1000 * 60 * 60 * 24),
  census
});

election.addQuestion('Ain\'t this census awesome?', 'Question description', [
  {
    title: 'Yes',
    value: 0,
  },
  {
    title: 'No',
    value: 1,
  }
]);

const electionData = {};

// Create the election
const newElection = async () => {
  const id = await client.createElection(election)
  electionData["id"] = id;
  electionData["censusIdentifier"] = client.censusService.auth.identifier;
  electionData["censusAddress"] = client.censusService.auth.wallet.address;
  electionData["censusPrivateKey"] = client.censusService.auth.wallet.privateKey;
  electionData["censusPublicKey"] = client.censusService.auth.wallet.publicKey;

  console.log("New election created with");
  console.log(electionData);
  console.log("\n\n");
  console.log("You can run this script with the following ENV var in order to skip the creation of a new election:");
  console.log(`WALLET=${process.env.WALLET} ELECTION_DATA=${JSON.serialize(electionData)} node node-wrapper/test_census.js`);
};

if(process.env["ELECTION_DATA"]) {
	electionData = JSON.parse(process.env.ELECTION_DATA);
	console.log("Using election data from ENV var:");
	console.log(electionData);
} else {
	newElection();
}

// TODO:
// 1. let's check the random wallet is in the census
// 2. Let's change the census
// 3. Let's check the random wallet is not in the census anymore
// 4. Let's check the new wallet is in the census