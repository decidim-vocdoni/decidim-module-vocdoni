// A vote component, to send the real votes to the Vocdoni API, using the Vocdoni SDK

import { EnvOptions, VocdoniSDKClient, Vote } from "@vocdoni/sdk";

/*
 * Submit a vote to the Vocdoni API
 *
 * @param {string} electionId - The election ID to vote in
 * @param {object} wallet - The wallet to use to sign the vote
 * @param {array} voteValue - The values of the votes to submit
 *
 * @return {Promise<object>} A Promise of an object with two possible reposnses, depending if the
 *   vote was successfull or not.
 *   - If it was sucessful, the format will be `{status: "OK", voteHash: voteHash}`
 *   - If it was a failure, the format will be `{status: "ERROR", message: error}`
 */
const submitVote = (electionId, wallet, voteValue) => {
  const client = new VocdoniSDKClient({
    env: EnvOptions.DEV,
    wallet: wallet
  });
  client.setElectionId(electionId);

  console.log("Voting...");
  const vote = new Vote(voteValue);
  return new Promise((resolve) => {
    client.submitVote(vote).
      then((voteHash) => {
        console.log("Vote sent! CONFIRMATION ID => ", voteHash);
        resolve({status: "OK", voteHash: voteHash});
      }).
      catch((error) => {
        resolve({status: "ERROR", message: error});
      });
  });
}

export default class VoteComponent {
  constructor({ electionUniqueId, wallet }) {
    this.electionUniqueId = electionUniqueId;
    this.wallet = wallet;
  }

  async bindEvents({
    onBindSubmitButton,
    onStart,
    onBallotSubmission,
    onFinish,
    onBindVerifyBallotButton,
    onVerifyBallot,
    onVerifyComplete,
    onClose,
    onInvalid
  }) {
    onBindSubmitButton(async () => {
      onStart();
      onBallotSubmission(
        (vote) => {
          console.log(vote);
          this.submit(vote).then((ballot) => {
            console.log(ballot);

            if (ballot.status === "OK") {
              onFinish(ballot.voteId);
            } else {
              onInvalid();
            }
          });
        },
        () => {
          onInvalid();
        }
      );
    });
  }
  async submit(vote) {
    console.log("Submiting vote to Vocdoni API with:");
    console.log("- ELECTION ID => ", this.electionUniqueId);
    console.log("- WALLET => ", this.wallet);
    console.log("- VALUE => ", vote);
    const response = await submitVote(this.electionUniqueId, this.wallet, vote);

    return response;
  }
}
