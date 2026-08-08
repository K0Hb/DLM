import { Controller } from "@hotwired/stimulus"

// Click thumbnail → lightbox preview; download/delete stay as separate links.
export default class extends Controller {
  static targets = ["dialog", "image"]

  open(event) {
    event.preventDefault()
    const src = event.currentTarget.dataset.previewUrl
    if (!src || !this.hasDialogTarget || !this.hasImageTarget) return
    this.imageTarget.src = src
    this.imageTarget.alt = event.currentTarget.dataset.previewAlt || "Фото"
    this.dialogTarget.showModal()
  }

  close() {
    if (!this.hasDialogTarget) return
    this.dialogTarget.close()
    if (this.hasImageTarget) this.imageTarget.removeAttribute("src")
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
