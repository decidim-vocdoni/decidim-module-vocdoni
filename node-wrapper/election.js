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
  try {
    const censusWallet = new Wallet(censusAttributes.privateKey);
    const censusIdentifier = censusAttributes.identifier;
    const service = new CensusService({
      url: client.censusService.url,
      chunkSize: client.censusService.chunk_size,
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
    const info = await service.publish(newCensus.id);
    await client.changeElectionCensus(censusAttributes.electionId, info.censusID, info.uri);
    return JSON.stringify({ success: true, count: censusData.length, timestamp: new Date(), newCensusId: info.censusID});
  } catch (error) {
    return JSON.stringify({ success: false, error: error.message, count: 0, timestamp: new Date() });
  }
};

module.exports.vocdoniElection = vocdoniElection;
module.exports.updateElectionCensus = updateElectionCensus;
