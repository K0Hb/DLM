import { Controller } from "@hotwired/stimulus"

// Filters assignee options by selected service (employee service pool).
export default class extends Controller {
  static targets = ["service", "assignee"]
  static values = { map: Object }

  connect() {
    this.refresh()
  }

  refresh() {
    const serviceId = this.serviceTarget.value
    const allowed = new Set((this.mapValue[serviceId] || []).map(String))
    let selectedValid = false

    Array.from(this.assigneeTarget.options).forEach((option) => {
      if (!option.value) return

      const ok = allowed.has(option.value)
      option.hidden = !ok
      option.disabled = !ok
      if (ok && option.selected) selectedValid = true
    })

    if (!selectedValid) {
      this.assigneeTarget.value = ""
    }
  }
}
