const { Election, PlainCensus, CensusService, CensusType } = require("@vocdoni/sdk");
const { Wallet } = require("@ethersproject/wallet");

/**
 * Builds a Vocdoni Election object from the data provided
 * suitable for creating a new election using the Vocdoni SDK
 */
const vocdoniElection = async (electionData, questionsData, censusData) => {
  const census = new PlainCensus();
  // Add census
  censusData.forEach((entry) => census.add(entry));
  electionData.census = census;

  const election = await Election.from(electionData);

  // Add questions
  questionsData.forEach((question) => election.addQuestion(...question));

  return election;
};

const updateElectionCensus = async (client, censusAttributes, censusData) => {
  const censusWallet = new Wallet(censusAttributes["privateKey"]);
  const censusIdentifier = censusAttributes["identifier"];
  const service = new CensusService({ 
    url: client.censusService.url, 
    chunk_size: client.censusService.chunk_size,
    auth: {
      identifier: censusIdentifier,
      wallet: censusWallet
    } 
  });
  const newCensus = await service.create(CensusType.WEIGHTED);
  await service.add(
    newCensus.id,
    censusData.map((wallet) => ({ key: wallet, weight: BigInt(1) }))
  );
  // Publish the new census
  const info = await service.publish(newCensus.id);
  return await client.changeElectionCensus(client.electionId, info.censusID, info.uri);
};

module.exports.vocdoniElection = vocdoniElection;
module.exports.updateElectionCensus = updateElectionCensus;
