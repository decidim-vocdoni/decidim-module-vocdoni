const { Election, PlainCensus } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");

const newElection = async (client, participants) => {
  const census = new PlainCensus();
  // Add census
  participants.forEach((entry) => census.add(entry));
  const election = Election.from({
    title: 'Election test #' + Math.round(Math.random()*1000000),
    description: 'Election test census',
    endDate: new Date(Date.now() + 1000 * 60 * 60 * 24),
    census,
    electionType: {
      autoStart: false,
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
    "censusId": census.censusId,
    "censusIdentifier": client.censusService.auth.identifier,
    "censusAddress": client.censusService.auth.wallet.address,
    "censusPrivateKey": client.censusService.auth.wallet.privateKey,
    "censusPublicKey": client.censusService.auth.wallet.publicKey,
  }
  return electionData;
};

const checkAddress = async (service, censusId, wallet) => {
  try {
    return await service.fetchProof(censusId, wallet) ? "Yes" : "No";
  } catch(e) {
    return "No";
  }
};

module.exports.newElection = newElection;
module.exports.checkAddress = checkAddress;