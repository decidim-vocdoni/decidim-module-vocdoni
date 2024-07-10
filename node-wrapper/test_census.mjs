/* eslint-disable no-unused-vars */
/* eslint-disable no-relative-import-paths/no-relative-import-paths */

/**
 * Manual testing of the Vocdoni SDK Census features
 * */
process.env.VOCDONI_WRAPPER_PATH = "./";
import { PlainCensus, VocdoniSDKClient, CensusService, CensusType } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";
import { vocdoniClient, clientInfo } from "./client.js";
import { vocdoniElection, updateElectionCensus } from "./election.js";
import { newElection, checkAddress } from "./test_helpers.js";

if (!process.env.WALLET) {
  const errorMessage = "WALLET env variable not found\n\n" +
      "Try running:\n\n\tbin/rails runner 'puts Decidim::Vocdoni::Wallet.last.private_key'\n" +
      "Usage:\n\n" +
      "\tENV=dev|stg WALLET=random node node-wrapper/test_census.js\n" +
      "\tENV=dev|stg WALLET=<private_key> node node-wrapper/test_census.js\n" +
      "\tENV=dev|stg WALLET=<private_key> ELECTION_DATA={id:<electionId>,censusPrivateKey:<censusPrivateKey>} node node-wrapper/test_census.js\n";
  console.error(errorMessage);
  throw new Error(errorMessage);
}

const env = process.env.ENV || "dev";
let wallet = null;
let client = null;
if (process.env.WALLET === "random") {
  console.log("Using random wallet and creating the organization");
  wallet = Wallet.createRandom();
  console.log({publicKey: wallet.publicKey, privateKey: wallet.privateKey, address: wallet.address});
  client = new VocdoniSDKClient({ env, wallet });
  // prepare account
  const info = await client.createAccount();
  console.log("Account created with:");
  console.log(info);
  console.log("\n\n");
  console.log("You can run this script with the following ENV var in order to skip the creation of a new account:");
  console.log(`ENV=${env} WALLET=${wallet.privateKey} node node-wrapper/test_census.mjs`);
  process.env.WALLET = wallet.privateKey;
}
wallet = new Wallet(process.env.WALLET);
client = new VocdoniSDKClient({ env, wallet });
console.log("Using env:", env, "API URL", client.censusService.url)

try {
  await client.collectFaucetTokens();
} catch (error) {
  console.error("Error collecting faucet tokens", error.message);
}

console.log("Using wallet:");
console.log({publicKey: wallet.publicKey, privateKey: wallet.privateKey, address: wallet.address});

let census = null;
let newCensus = null;
let service = null;
let electionData = null;
let censusId = process.env.CENSUS_ID;
let censusIdentifier = process.env.CENSUS_IDENTIFIER;
let censusDetails = null;
let censusInfo = null;
let info = null;
const censusWallets = [
  await VocdoniSDKClient.generateWalletFromData("a-test-1").address, 
  await VocdoniSDKClient.generateWalletFromData("a-test-2").address,
  await VocdoniSDKClient.generateWalletFromData("a-test-3").address
];
const newCensusWallet = await VocdoniSDKClient.generateWalletFromData("b-test-1").address;
const addCensusWallet = await VocdoniSDKClient.generateWalletFromData("b-test-2").address;
if (process.env.ELECTION_ID && process.env.CENSUS_WALLET && process.env.CENSUS_ID && process.env.CENSUS_IDENTIFIER) {
  console.log("Using census data from ENV vars CENSUS_WALLET, CENSUS_IDENTIFIER and CENSUS_ID");
  service = new CensusService({ 
    url: client.censusService.url,
    // eslint-disable-next-line camelcase
    chunk_size: client.censusService.chunk_size,
    auth: {
      identifier: process.env.CENSUS_IDENTIFIER,
      wallet: new Wallet(process.env.CENSUS_WALLET)
    },
    async: { async: true, wait: 30000 }
  });

  console.log("CensusService:", service)
  census = await service.get(process.env.CENSUS_ID);
  console.log("Census:", census);
  electionData = await client.fetchElection(process.env.ELECTION_ID);
  console.log("Using election data from ENV var ELECTION_ID");
  console.log("ElectionID:", electionData.id, "Census:", electionData.census);
} else {
  console.log("Using deterministic wallets in the census:", censusWallets);
  electionData = await newElection(client, censusWallets);
  console.log("New election created with");
  console.log(electionData);
  censusId = electionData.censusId;
  censusIdentifier = electionData.censusIdentifier;
  console.log("\n\n");
  console.log("You can run this script with the following ENV var in order to skip the creation of a new election:");
  console.log(`ENV=${env} WALLET=${process.env.WALLET} ELECTION_ID=${electionData.id} CENSUS_ID=${censusId} CENSUS_IDENTIFIER=${censusIdentifier} CENSUS_WALLET=${electionData.censusPrivateKey} node node-wrapper/test_census.mjs`);
  service = client.censusService;
  censusInfo = await service.get(censusId);
  console.log("censusInfo", censusInfo);
  console.log("Census size:", censusInfo.size);
}

console.log("\n==========\n");

console.log("Are the old addresses in the old census?")
console.log(await checkAddress(service, censusId, censusWallets[0]))
console.log(await checkAddress(service, censusId, censusWallets[1]))
console.log(await checkAddress(service, censusId, censusWallets[2]))
console.log("Are the new addresses in the old census?")
console.log(await checkAddress(service, censusId, newCensusWallet))
console.log(await checkAddress(service, censusId, addCensusWallet))

console.log("Adding the new census...");
info = await updateElectionCensus(client, { privateKey: process.env.WALLET, id: censusId, identifier: censusIdentifier, electionId: electionData.id }, [newCensusWallet, addCensusWallet]);
console.log("updateElectionCensus INFO", info);
if (!info.success) {
  throw new Error(`Error updating election census: ${info.error}`);
}

console.log("Are the old addresses in the new census?")
console.log(await checkAddress(service, info.newCensusId, censusWallets[0]))
console.log(await checkAddress(service, info.newCensusId, censusWallets[1]))
console.log(await checkAddress(service, info.newCensusId, censusWallets[2]))
console.log("Are the new addresses in the old census?")
console.log(await checkAddress(service, info.newCensusId, newCensusWallet))
console.log(await checkAddress(service, info.newCensusId, addCensusWallet))

try {
  console.log("Is the election using the new census?");
  const election = await client.fetchElection(electionData.id);
  console.log(election.census);
} catch (error) {
  console.error("Error fetching election", error.message);
  throw error;
}
