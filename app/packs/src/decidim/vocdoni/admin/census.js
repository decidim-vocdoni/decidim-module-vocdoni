/**
 * Toggle sections based on the selected radio button.
 * @returns {undefined}
 */
const toggleSectionsBasedOnRadioButton = function() {
  const csvRadioButton = document.getElementById("csv_radio_button");
  const permissionsRadioButton = document.getElementById("permissions_radio_button");
  const csvUploadDiv = document.getElementById("csv_upload");
  const permissionsSelectDiv = document.getElementById("permissions_select");
  const warningDiv = document.querySelector(".census_warning_text");

  if (!csvRadioButton || !permissionsRadioButton || !csvUploadDiv || !permissionsSelectDiv) {
    return;
  }

  const updateWarningMessage = () => {
    const translations = document.getElementById("translations");
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
