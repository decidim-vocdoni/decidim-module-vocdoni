const checkCredentialsGenerationProgress = async () => {
  const container = document.getElementById("census-processing-percentage");
  if (!container) {
    return;
  }

  const response = await fetch(location.href, {
    headers: {
      "X-Requested-With": "XMLHttpRequest"
    }
  });
  const result = await response.json();
  container.innerHTML = result.percentageText;
  if (result.percentageComplete < 100) {
    setTimeout(checkCredentialsGenerationProgress, 1000);
  } else {
    location.reload();
  }
};

document.addEventListener("DOMContentLoaded", () => {
  checkCredentialsGenerationProgress();
});
