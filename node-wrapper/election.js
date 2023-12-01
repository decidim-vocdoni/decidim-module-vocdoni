const { Election, PlainCensus } = require("@vocdoni/sdk");

/**
 * Builds a Vocdoni Election object from the data provided
 * suitable for creating a new election using the Vocdoni SDK
 */
const vocdoniElection = async (electionData, questionsData, censusData) => {
  const census = new PlainCensus();
  // add census
  censusData.forEach((entry) => census.add(entry));
  electionData.census = census;

  const election = await Election.from(electionData);

  // add questions
  questionsData.forEach((question) => election.addQuestion(...question));

  return election;
};

module.exports.vocdoniElection = vocdoniElection;
