/* eslint-disable no-warning-comments */
/* eslint-disable no-unused-vars */

import { VocdoniSDKClient, Vote } from "@vocdoni/sdk";

/*
 * Submit a vote to the Vocdoni API
 *
 * @param {object} options All the different options that interact with Submitting a vote
 * @property {string} options.env - The environment of the Vocdoni API
 * @property {string} options.electionId - The election ID to vote in
 * @property {object} options.wallet - The wallet to use to sign the vote
 * @property {array} options.voteValue - The values of the votes to submit
 *
 * @return {Promise<object>} A Promise of an object with two possible reposnses, depending if the
 *   vote was successfull or not.
 *   - If it was sucessful, the format will be `{status: "OK", voteId: voteId}`
 *   - If it was a failure, the format will be `{status: "ERROR", message: error}`
 */
const submitVote = async (options) => {
  console.log("OPT", options);
  const client = new VocdoniSDKClient({
    env: options.env,
    wallet: options.wallet
  });
  console.log("CLIENT => ", client);
  client.setElectionId(options.electionId);

  // Workaround for the cases where the client.url is not set
  // We need to set it manually, depending on the environment
  //
  // TODO: we should pinpoint what exactly is the culprit of this issue
  // and if it's a bug in the SDK, we should fix it there
  switch (options.env) {
  case "prd":
    client.url = "https://api.vocdoni.net/v2";
    break;
  case "stg":
    client.url = "https://api-stg.vocdoni.net/v2";
    break;
  default:
    client.url = "https://api-dev.vocdoni.net/v2";
  }

  const votesLeft = await client.votesLeftCount();
  console.log("VOTES LEFT => ", votesLeft);

  return new Promise((resolve) => {
    if (votesLeft === 0) {
      resolve({status: "ERROR", message: "No votes left"});
    }

    console.log("Voting...", options.voteValue);
    const vote = new Vote(options.voteValue);
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
  constructor({ env, electionUniqueId, wallet }) {
    this.env = env;
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
              onFinish(ballot.voteId, this.env);
            } else {
              onInvalid(ballot.message);
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
    console.log("- ENV => ", this.env);
    console.log("- ELECTION ID => ", this.electionUniqueId);
    console.log("- WALLET => ", this.wallet);
    console.log("- VALUE => ", vote);
    const response = await submitVote({
      env: this.env,
      electionId: this.electionUniqueId,
      wallet: this.wallet,
      voteValue: vote
    });

    return response;
  }
}
/* eslint-enable no-unused-vars */
/* eslint-enable no-warning-comments */
