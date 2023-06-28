document.addEventListener("DOMContentLoaded", () => {
  const manualStartCheckbox = document.getElementById("election_calendar_manual_start");
  const startTimeField = document.getElementById("election_calendar_start_time");

  if (manualStartCheckbox === null || startTimeField === null) { 
    return;
  }

  const toggleStartTimeField = () => {
    const isManualStartChecked = manualStartCheckbox.checked;
    startTimeField.disabled = isManualStartChecked;
    startTimeField.classList.toggle("text-muted", isManualStartChecked);
  }

  manualStartCheckbox.addEventListener("change", toggleStartTimeField);
  toggleStartTimeField();
});
