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

      document.querySelector("[data-census-last-updated]").textContent = data.info.census_last_updated_at;
      document.querySelector("[data-census-records-added]").textContent = data.info.last_census_update_records_added;
      document.querySelector("[data-users-awaiting-census]").innerHTML = data.info.users_awaiting_census;

      const usersAwaitingCount = parseInt(data.info.users_awaiting_census.match(/\d+/)[0], 10);
      const updateContainer = document.querySelector("[data-update-census-container]");
      let updateLink = document.getElementById("update-census-link");

      if (usersAwaitingCount > 0) {
        if (!updateLink) {
          // Создаем кнопку, если она не существует
          updateLink = document.createElement("a");
          updateLink.href = updateContainer.getAttribute("data-update-url");
          updateLink.textContent = window.translations.updateCensusNow;
          updateLink.className = "button button__sm button__secondary my-2";
          updateLink.id = "update-census-link";
          updateLink.setAttribute("data-method", "put");
          updateLink.setAttribute("rel", "nofollow");
          updateContainer.appendChild(updateLink);
          updateContainer.style.display = "";
        }
      } else {
        if (updateLink) {
          updateLink.remove();
        }
        updateContainer.style.display = "none";
      }

      const currentDate = data.info.census_last_updated_at;

      const showMessage = () => {
        const messageElement = document.querySelector("[data-census-update-message]")
        messageElement.style.display = "block";
        setTimeout(() => {
          messageElement.style.display = "none";
        }, 5000);
      };

      if (previousUpdateDate !== null && previousUpdateDate !== currentDate) {
        document.querySelector("[data-census-update-message-text]").innerHTML = data.info.update_message;
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
