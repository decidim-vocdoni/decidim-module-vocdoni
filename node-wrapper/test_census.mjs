/* eslint-disable no-unused-vars */

/**
 * Manual testing of the Vocdoni SDK Census features
 * */
process.env.VOCDONI_WRAPPER_PATH = `./`;
import { PlainCensus, VocdoniSDKClient, CensusService, CensusType } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";
import { vocdoniClient, clientInfo } from "./client.js";
import { vocdoniElection, updateElectionCensus } from "./election.js";
import { newElection, checkAddress } from "./test_helpers.js";

if (!process.env["WALLET"]) {
  console.error("WALLET env variable not found\n\nTry running:\n\n\tbin/rails runner 'puts Decidim::Vocdoni::Wallet.last.private_key'\n");
  console.log("Usage:\n\n");
  console.log("\tENV=dev|stg WALLET=random node node-wrapper/test_census.js\n");
  console.log("\tENV=dev|stg WALLET=<private_key> node node-wrapper/test_census.js\n");
  console.log("\tENV=dev|stg WALLET=<private_key> ELECTION_DATA={id:<electionId>,censusPrivateKey:<censusPrivateKey>} node node-wrapper/test_census.js\n");
  process.exit();
}

const env = process.env["ENV"] || "dev";
let wallet = null;
let client = null;
if(process.env.WALLET == "random") {
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
	process.env["WALLET"] = wallet.privateKey;
}
wallet = new Wallet(process.env.WALLET);
client = new VocdoniSDKClient({ env, wallet });
console.log("Using env:", env, "API URL", client.censusService.url)

try {
	await client.collectFaucetTokens();
} catch(e) {
	console.error("Error collecting faucet tokens", e.message);
}

console.log("Using wallet:");
console.log({publicKey: wallet.publicKey, privateKey: wallet.privateKey, address: wallet.address});

let census = null;
let newCensus = null;
let service = null;
let electionData = null;
let censusId = process.env["CENSUS_ID"];
let censusIdentifier = process.env["CENSUS_IDENTIFIER"];
const censusWallet = await VocdoniSDKClient.generateWalletFromData("a-test").address;
const newCensusWallet = await VocdoniSDKClient.generateWalletFromData("a-test-2").address;
if(process.env["ELECTION_ID"] && process.env["CENSUS_WALLET"] && process.env["CENSUS_ID"] && process.env["CENSUS_IDENTIFIER"]) {
	console.log("Using census data from ENV vars CENSUS_WALLET, CENSUS_IDENTIFIER and CENSUS_ID");
  service = new CensusService({ 
    url: client.censusService.url, 
    chunk_size: client.censusService.chunk_size,
    auth: {
      identifier: process.env["CENSUS_IDENTIFIER"],
      wallet: new Wallet(process.env["CENSUS_WALLET"])
    } 
  });

  console.log("CensusService:",service)
  census = await service.get(process.env["CENSUS_ID"]);
	console.log("Census:",census);
	electionData = await client.fetchElection(process.env.ELECTION_ID);
	console.log("Using election data from ENV var ELECTION_ID");
	console.log("ElectionID:", electionData["id"], "Census:", electionData["census"]);
} else {
	console.log("Using deterministic wallets in the census:", censusWallet);
	electionData = await newElection(client, [censusWallet]);
	console.log("New election created with");
	console.log(electionData);
	censusId = electionData["censusId"];
	censusIdentifier = electionData["censusIdentifier"];
	service = client.censusService;
	console.log("\n\n");
	console.log("You can run this script with the following ENV var in order to skip the creation of a new election:");
	console.log(`ENV=${env} WALLET=${process.env["WALLET"]} ELECTION_ID=${electionData["id"]} CENSUS_ID=${censusId} CENSUS_IDENTIFIER=${censusIdentifier} CENSUS_WALLET=${electionData["censusPrivateKey"]} node node-wrapper/test_census.mjs`);
}

console.log("Is the old address in census?")
console.log(await checkAddress(service, censusId, censusWallet))
console.log("Is the new addres in census?")
console.log(await checkAddress(service, censusId, newCensusWallet))

let censusDetails = null;
try {
	console.log("Adding the new census...");
	newCensus = await service.create(CensusType.WEIGHTED);
	console.log(newCensus)
	const add = await service.add(newCensus.id, [{ key: newCensusWallet, weight: BigInt(1) }]);
	console.log("ADD", add);
	censusDetails = await service.publish(newCensus.id);
	console.log("censusDetails", censusDetails);
} catch(e) {
	console.error("Error adding new census", e.message);
	process.exit();
}

console.log("Is the old address in census?")
console.log(await checkAddress(service, newCensus.id, censusWallet))
console.log("Is the new addres in census?")
console.log(await checkAddress(service, newCensus.id, newCensusWallet))

try {
	await client.changeElectionCensus(electionData["id"], censusDetails.censusID, censusDetails.uri);
} catch(e) {
	console.error("Error updating election census", e);
}

try {
	console.log("Is the election using the new census?");
	const election = await client.fetchElection(electionData["id"]);
	console.log(election.census);
} catch(e) {
	console.error("Error fetching election", e.message);
	process.exit();
}
