const { Election, PlainCensus } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");

const newElection = async (client, census) => {
  const election = await Election.from({
    title: 'Election test #' + Math.round(Math.random()*1000000),
    description: 'Election test census',
    startDate: new Date(Date.now()),
    endDate: new Date(Date.now() + 1000 * 60 * 60 * 24),
    census,
    electionType: {
      autoStart: true,
      interruptible: true,
      dynamicCensus: true,
      secretUntilTheEnd: false,
      anonymous: false
    }
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

  const id = await client.createElection(election)
  const electionData = {
    "id": id,
    "censusIdentifier": client.censusService.auth.identifier,
    "censusAddress": client.censusService.auth.wallet.address,
    "censusPrivateKey": client.censusService.auth.wallet.privateKey,
    "censusPublicKey": client.censusService.auth.wallet.publicKey,
  }

  console.log("New election created with");
  console.log(electionData);
  console.log("\n\n");
  console.log("You can run this script with the following ENV var in order to skip the creation of a new election:");
  console.log(`WALLET=${process.env["WALLET"]} ELECTION_DATA=${JSON.serialize(electionData)} node node-wrapper/test_census.mjs`);
  return electionData;
};

const runTests = async () => {
};

module.exports.newElection = newElection;
module.exports.runTests = runTests;