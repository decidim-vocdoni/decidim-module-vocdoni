document.addEventListener("DOMContentLoaded", () => {
  const censusDataElement = document.querySelector(".js-census-data");
  const censusDataPath = censusDataElement.dataset.updateCensusUrl;
  const updateCensusContainer = document.getElementById("census-update-container");

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

      let censusUpdateElement = "";
      if (usersAwaitingCount > 0) {
        censusUpdateElement = `<a href="${censusDataPath}" class="button primary alert" data-method="put" data-remote="true" id="update-census-link">${window.translations.updateCensusNow}</a>`;
      } else {
        censusUpdateElement = `<span class="button primary alert disabled">${window.translations.updateCensusNow}</span>`;
      }

      updateCensusContainer.innerHTML = censusUpdateElement;
    } catch (error) {
      console.error("Error:", error);
    }
  };

  setInterval(updateCensusInfo, 3000);
});
