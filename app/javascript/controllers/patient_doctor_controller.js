import { Controller } from "@hotwired/stimulus"

// Prefills work_order[doctor_id] when a catalog patient is selected.
export default class extends Controller {
  static targets = ["patient", "doctor"]

  fill() {
    const option = this.patientTarget.selectedOptions[0]
    if (!option) return

    const doctorId = option.dataset.doctorId
    if (!doctorId) return

    this.doctorTarget.value = doctorId
  }
}
