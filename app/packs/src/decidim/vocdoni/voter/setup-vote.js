/* eslint-disable no-unused-vars */

import { VocdoniSDKClient, Vote } from "@vocdoni/sdk";

/*
 * Submit a vote to the Vocdoni API
 *
 * @param {object} options All the different options that interact with Submitting a vote
 * @property {string} options.vocdoniEnv - The environment of the Vocdoni API
 * @property {string} options.electionId - The election ID to vote in
 * @property {object} options.wallet - The wallet to use to sign the vote
 * @property {array} options.voteValue - The values of the votes to submit
 *
 * @return {Promise<object>} A Promise of an object with two possible reposnses, depending if the
 *   vote was successfull or not.
 *   - If it was sucessful, the format will be `{status: "OK", voteId: voteId}`
 *   - If it was a failure, the format will be `{status: "ERROR", message: error}`
 */
const submitVote = (options) => {
  const client = new VocdoniSDKClient({
    env: options.vocdoniEnv,
    wallet: options.wallet
  });
  client.setElectionId(options.electionId);

  console.log("Voting...");
  const vote = new Vote(options.voteValue);
  return new Promise((resolve) => {
    client.submitVote(vote).
      then((voteId) => {
        console.log("Vote sent! CONFIRMATION ID => ", voteId);
        resolve({status: "OK", voteId: voteId});
      }).
      catch((error) => {
        resolve({status: "ERROR", message: error});
      });
  });
}

// A vote component, to send the real votes to the Vocdoni API, using the Vocdoni SDK
export default class VoteComponent {
  constructor({ vocdoniEnv, electionUniqueId, wallet }) {
    this.vocdoniEnv = vocdoniEnv;
    this.electionUniqueId = electionUniqueId;
    this.wallet = wallet;
  }

  async bindEvents({
    onBindSubmitButton,
    onStart,
    onBallotSubmission,
    onFinish,
    onBindVerifyBallotButton,
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
    console.log("- ENV => ", this.vocdoniEnv);
    console.log("- ELECTION ID => ", this.electionUniqueId);
    console.log("- WALLET => ", this.wallet);
    console.log("- VALUE => ", vote);
    const response = await submitVote({
      env: this.vocdoniEnv,
      electionId: this.electionUniqueId,
      wallet: this.wallet,
      voteValue: vote
    });

    return response;
  }
}
/* eslint-enable no-unused-vars */
