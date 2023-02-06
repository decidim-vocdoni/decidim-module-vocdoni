import { EnvOptions, VocdoniSDKClient } from "@vocdoni/sdk";

const voteStep = async () => {
  // Setup election step
  const electionVotesMetadataTable = document.querySelector(".js-votes-count");
  if (!electionVotesMetadataTable) {
    return;
  }

  // Wait for 3s
  const WAIT_TIME_MS = 3000;

  const fetchVotesStats = async () => {
    const currentVocdoniWalletPrivateKey = electionVotesMetadataTable.dataset.vocdoniWalletPrivateKey;
    const electionUniqueId = electionVotesMetadataTable.dataset.electionUniqueId;

    const client = new VocdoniSDKClient({
      env: EnvOptions.DEV,
      wallet: currentVocdoniWalletPrivateKey
    })
    client.setElectionId(electionUniqueId);
    const electionMetadata = await client.fetchElection();

    console.group("Election Metadata");
    console.log("WALLET => ", currentVocdoniWalletPrivateKey);
    console.log("ELECTION_UNIQUE_ID =>", electionUniqueId);
    console.log("ELECTION_METADATA =>", electionMetadata);
    console.groupEnd();
  }

  setInterval(fetchVotesStats(), WAIT_TIME_MS);
}

document.addEventListener("DOMContentLoaded", () => {
  voteStep();
});
