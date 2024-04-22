/**
 * Toggle sections based on the selected radio button.
 * @returns {undefined}
 */
const toggleSectionsBasedOnRadioButton = function() {
  const csvRadioButton = document.querySelector("[data-csv-radio-button]");
  const permissionsRadioButton = document.querySelector("[data-permissions-radio-button]");
  const csvUploadDiv = document.querySelector("[data-csv-upload]")
  const permissionsSelectDiv = document.querySelector("[data-permissions-select]")
  const warningDiv = document.querySelector("[data-census-warning-text]");

  if (!csvRadioButton || !permissionsRadioButton || !csvUploadDiv || !permissionsSelectDiv) {
    return;
  }

  const updateWarningMessage = () => {
    const translations = document.querySelector("[data-translations]");
    const csvWarningText = translations.getAttribute("data-csv-warning");
    const permissionsWarningText = translations.getAttribute("data-permissions-warning");

    if (csvRadioButton.checked) {
      warningDiv.innerHTML = csvWarningText;
    } else {
      warningDiv.innerHTML = permissionsWarningText;
    }
  };

  const toggleSections = () => {
    if (csvRadioButton.checked) {
      csvUploadDiv.style.display = "block";
      permissionsSelectDiv.style.display = "none";
    } else {
      csvUploadDiv.style.display = "none";
      permissionsSelectDiv.style.display = "block";
    }
    updateWarningMessage();
  };

  csvRadioButton.addEventListener("change", toggleSections);
  permissionsRadioButton.addEventListener("change", toggleSections);
  toggleSections();
}

document.addEventListener("DOMContentLoaded", toggleSectionsBasedOnRadioButton);
