document.addEventListener('DOMContentLoaded', function() {
  const url = document.querySelector('.js-votes-count').dataset.url;
  setInterval(function() {
    fetch(url)
      .then(response => response.json())
      .then(data => updateResults(data));
  }, 10000);
});

function updateResults(data) {
  data.election_data.result.forEach(function(question, questionIndex) {
    question.forEach(function(votes, answerIndex) {
      const selector = `.votes-for-answer[data-question-index="${questionIndex}"][data-answer-index="${answerIndex}"]`;
      const element = document.querySelector(selector);
      if (element) {
        element.textContent = parseInt(votes, 10).toString();
      }
    });
  });
}
