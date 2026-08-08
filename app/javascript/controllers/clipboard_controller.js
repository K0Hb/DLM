import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "status"]

  async copy(event) {
    event.preventDefault()
    const text = this.hasSourceTarget ? this.sourceTarget.value || this.sourceTarget.textContent : ""
    if (!text) return

    try {
      await navigator.clipboard.writeText(text.trim())
      this.flash("Скопировано")
    } catch (_e) {
      if (this.hasSourceTarget && this.sourceTarget.select) {
        this.sourceTarget.select()
        document.execCommand("copy")
        this.flash("Скопировано")
      } else {
        this.flash("Не удалось скопировать")
      }
    }
  }

  flash(message) {
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = message
    window.clearTimeout(this._timer)
    this._timer = window.setTimeout(() => {
      this.statusTarget.textContent = ""
    }, 2000)
  }
}
