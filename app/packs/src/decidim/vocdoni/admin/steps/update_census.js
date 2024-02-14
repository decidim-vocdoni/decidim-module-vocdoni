document.addEventListener("DOMContentLoaded", () => {
  const censusDataElement = document.querySelector(".js-census-data");
  if (!censusDataElement) {
    return;
  }

  const censusDataPath = censusDataElement.dataset.updateCensusUrl;

  const updateCensusInfo = async () => {
    try {
      const response = await fetch(censusDataPath, {
        method: "GET"
      });
      if (!response.ok) {
        throw new Error("Сетевой ответ был не ok.");
      }
      const data = await response.json();

      document.getElementById("census-last-updated").textContent = data.info.census_last_updated_at;
      document.getElementById("census-records-added").textContent = data.info.last_census_update_records_added;

      const usersAwaitingCount = parseInt(data.info.users_awaiting_census.match(/\d+/)[0], 10);

      document.querySelector("[data-users-awaiting-census]").innerHTML = data.info.users_awaiting_census;

      const updateCensusElement = document.getElementById("update-census-link");

      if (updateCensusElement) {
        if (updateCensusElement.tagName === "A") {
          if (usersAwaitingCount > 0) {
            updateCensusElement.classList.remove("disabled");
          } else {
            updateCensusElement.classList.add("disabled");
          }
        } else if (updateCensusElement.tagName === "SPAN") {
          if (usersAwaitingCount > 0) {
            updateCensusElement.classList.remove("disabled");
          } else {
            updateCensusElement.classList.add("disabled");
          }
        }
      }
    } catch (error) {
      console.error("Error:", error);
    }
  };

  setInterval(updateCensusInfo, 3000);
});
