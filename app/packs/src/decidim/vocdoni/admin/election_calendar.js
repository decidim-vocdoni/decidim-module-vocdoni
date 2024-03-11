/**
 * Toggle start time field based on the state of the checkbox.
 * @returns {undefined}
 */
const toggleStartTimeFieldBasedOnCheckbox = function() {
  const manualStartCheckbox = document.getElementById("election_calendar_manual_start");
  const startTimeField = document.getElementById("election_calendar_start_time");

  if (!manualStartCheckbox || !startTimeField) {
    return;
  }

  const toggleStartTimeField = () => {
    const isManualStartChecked = manualStartCheckbox.checked;
    startTimeField.disabled = isManualStartChecked;
    startTimeField.classList.toggle("text-muted", isManualStartChecked);
  };

  manualStartCheckbox.addEventListener("change", toggleStartTimeField);
  toggleStartTimeField();
}

document.addEventListener("DOMContentLoaded", toggleStartTimeFieldBasedOnCheckbox);
