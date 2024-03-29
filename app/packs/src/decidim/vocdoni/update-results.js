/*
 * Function to update results
 * @param {Object} data - The data received from the server.
*/
const updateResults = function (data) {
  data.election_data.result.forEach(function (question, questionIndex) {
    question.forEach(function (votes, answerIndex) {
      const selector = `.votes-for-answer[data-question-index="${questionIndex}"][data-answer-index="${answerIndex}"]`;
      const element = document.querySelector(selector);
      if (element) {
        element.textContent = parseInt(votes, 10).toString();
      }
    });
  });
};

/*
 * Function to handle the DOMContentLoaded event
*/
const handleDOMContentLoaded = function () {
  const url = document.querySelector(".js-votes-count").dataset.url;
  const MILLISECONDS_TO_REFRESH = 10 * 1000;

  setInterval(function () {
    fetch(url).then(function (response) {
      return response.json();
    }).then(updateResults);
  }, MILLISECONDS_TO_REFRESH);
};

document.addEventListener("DOMContentLoaded", handleDOMContentLoaded);
