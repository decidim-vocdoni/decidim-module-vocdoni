import CreateVocdoniElection from "src/decidim/vocdoni/admin/utils/create_vocdoni_election";

const setupElectionStep = async () => {
  // Setup election step
  const createElectionForm = document.querySelector("form.create_election");
  if (!createElectionForm) {
    return;
  }

  const createAnswersValuesOnElection = async () => {
    const url = window.location.pathname.split('/').filter((param) => param != "steps") .join("/") + "/answers_values";

    return new Promise((resolve) => {
      fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": $("meta[name=csrf-token]").attr("content")
        } })
        .then((response) => response.json())
        .then((data) => {
          console.log("Successfully created the Answers values:", data);
          resolve(data);
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    });
  }

  const onSuccess = (vocdoniElectionId) => {
    createElectionForm.querySelector("#setup_vocdoni_election_id").value = vocdoniElectionId;
    createElectionForm.submit();
  }

  const onFailure = () => {
    createElectionForm.querySelector(".js-election-create-error-message").classList.remove("hide");
  }

  const showLoadingSpinner = (setupElectionButton) => {
    setupElectionButton.disabled = true;
    setupElectionButton.querySelector(".loading").classList.remove("hide");
    setupElectionButton.querySelector(".text").classList.add("hide");
  }

  // If we do it with Vanilla JavaScript, the event is still submitted. This is a problem with Rails UJS, and we
  // need to use JQuery as a workaround
  // createElectionForm.addEventListener("submit", (event) => {
  $("form.create_election").on("submit", async (event) => {
    event.preventDefault();

    const setupElectionButton = createElectionForm.querySelector(".form-general-submit button");
    showLoadingSpinner(setupElectionButton);

    const answersResponse = await createAnswersValuesOnElection();
    if (answersResponse.status !== "ok") {
      return {};
    }

    const election = new CreateVocdoniElection({
      graphqlApiUrl: `${window.location.origin}/api`,
      defaultLocale: document.querySelector(".js-vocdoni-client").dataset.defaultLocale,
      componentId: window.location.pathname.split("/")[5],
      electionId: window.location.pathname.split("/")[8],
      containerClass: ".process-content"
    }, onSuccess, onFailure);
    election.run();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  setupElectionStep();
});
