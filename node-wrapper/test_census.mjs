/* eslint-disable no-unused-vars */

/**
 * Manual testing of the Vocdoni SDK Census features
 * */
process.env.VOCDONI_WRAPPER_PATH = `./`;
import { PlainCensus, VocdoniSDKClient } from "@vocdoni/sdk";
import { Wallet } from "@ethersproject/wallet";
import { vocdoniClient, clientInfo } from "./client.js";
import { vocdoniElection, updateElectionCensus } from "./election.js";
import { newElection, runTests } from "./test_helpers.js";

if (!process.env["WALLET"]) {
  console.error("WALLET env variable not found\n\nTry running:\n\n\tbin/rails runner 'puts Decidim::Vocdoni::Wallet.last.private_key'\n");
  console.log("Usage:\n\n");
  console.log("\tWALLET=random node node-wrapper/test_census.js\n");
  console.log("\tWALLET=<private_key> node node-wrapper/test_census.js\n");
  console.log("\tWALLET=<private_key> ELECTION_DATA={id:<electionId>,censusPrivateKey:<censusPrivateKey>} node node-wrapper/test_census.js\n");
  process.exit();
}

const env = "dev";
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
	console.log(`WALLET=${wallet.privateKey} node node-wrapper/test_census.mjs`);
	process.env["WALLET"] = wallet.privateKey;
}
wallet = new Wallet(process.env.WALLET);
client = new VocdoniSDKClient({ env, wallet });

console.log("Using wallet:");
console.log({publicKey: wallet.publicKey, privateKey: wallet.privateKey, address: wallet.address});

const census = new PlainCensus()
census.add(await Wallet.createRandom().getAddress())
console.log("Using random wallet in the census:");
console.log(census);

// Create the election
let electionData = null;
if(process.env["ELECTION_DATA"]) {
	electionData = JSON.parse(process.env.ELECTION_DATA);
	console.log("Using election data from ENV var ELECTION_DATA");
	console.log(electionData);
}

electionData = await newElection(client, census);

// TODO:
// 1. let's check the random wallet is in the census
// 2. Let's change the census
// 3. Let's check the random wallet is not in the census anymore
// 4. Let's check the new wallet is in the census
