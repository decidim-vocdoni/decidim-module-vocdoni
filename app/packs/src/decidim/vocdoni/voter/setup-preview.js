/* eslint-disable no-unused-vars */

// The wait time used to simulate the submission of the vote during the preview
const FAKE_SUBMISSION_TIME = 10000;

// A preview vote component, to try out the UI without actually sending any vote.
export default class PreviewVoteComponent {
  constructor({ electionUniqueId}) {
    this.electionUniqueId = electionUniqueId;
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
          console.log("VOTE => ", vote);
          this.fakeSubmission(vote).then((ballot) => {
            console.log("BALLOT => ", ballot);
            onFinish(ballot.voteId);
          });
        },
        () => {
          onInvalid();
        }
      );
    });
  }
  async fakeSubmission(vote) {
    await new Promise((resolve) => setTimeout(resolve, FAKE_SUBMISSION_TIME));

    console.log("Fake submitting a fake preview vote...");
    console.log("- ELECTION ID => ", this.electionUniqueId);
    console.log("- VALUE => ", vote);

    return {
      vote: vote,
      voteId: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
    };
  }
}
/* eslint-enable no-unused-vars */
