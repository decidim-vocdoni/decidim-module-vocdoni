document.addEventListener("DOMContentLoaded", () => {
  const censusDataElement = document.querySelector(".js-census-data");
  if (!censusDataElement) {
    return;
  }

  let previousUpdateDate = null;
  const censusDataPath = censusDataElement.dataset.updateCensusUrl;

  const updateCensusInfo = async () => {
    try {
      const response = await fetch(censusDataPath, {
        method: "GET"
      });
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      const data = await response.json();

      document.getElementById("census-last-updated").textContent = data.info.census_last_updated_at;
      document.getElementById("census-records-added").textContent = data.info.last_census_update_records_added;

      const usersAwaitingCount = parseInt(data.info.users_awaiting_census.match(/\d+/)[0], 10);

      document.querySelector("[data-users-awaiting-census]").innerHTML = data.info.users_awaiting_census;

      const updateCensusElement = document.getElementById("update-census-link") || document.querySelector(".update-census-span");

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
            const linkElement = document.createElement("a");
            linkElement.href = updateCensusElement.parentNode.getAttribute("data-update-url");
            linkElement.id = "update-census-link";
            linkElement.className = "button primary alert";
            linkElement.textContent = window.translations.updateCensusNow;
            linkElement.setAttribute("data-method", "put");
            linkElement.setAttribute("rel", "nofollow");
            linkElement.setAttribute("data-accessibility-violation", "true");
            updateCensusElement.parentNode.replaceChild(linkElement, updateCensusElement);
          } else {
            updateCensusElement.classList.add("disabled");
          }
        }
      }

      const currentDate = data.info.census_last_updated_at;

      const showMessage = () => {
        const messageElement = document.getElementById("census-update-message");
        messageElement.style.display = "block";
        setTimeout(() => {
          messageElement.style.display = "none";
        }, 5000);
      };

      if (previousUpdateDate !== null && previousUpdateDate !== currentDate) {
        document.getElementById("census-update-message-text").innerHTML = data.info.update_message;
        showMessage();
      }

      previousUpdateDate = currentDate;
      console.log("previousUpdateDate", previousUpdateDate);
    } catch (error) {
      console.error("Error:", error);
    }
  };

  setInterval(updateCensusInfo, 3000);
});
