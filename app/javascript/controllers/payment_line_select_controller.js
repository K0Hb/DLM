import { Controller } from "@hotwired/stimulus"

// Checkbox selection for technician payout confirmation.
export default class extends Controller {
  static targets = ["line", "amountInput", "total", "submit"]

  connect() {
    this.recalc()
  }

  checkAll() {
    this.lineTargets.forEach((el) => { el.checked = true })
    this.recalc()
  }

  uncheckAll() {
    this.lineTargets.forEach((el) => { el.checked = false })
    this.recalc()
  }

  recalc() {
    const selected = this.lineTargets.filter((el) => el.checked)
    const sum = selected.reduce((acc, el) => acc + this.amountForLine(el), 0)
    if (this.hasTotalTarget) {
      this.totalTarget.textContent = this.formatMoney(sum)
    }
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = selected.length === 0
    }
  }

  amountForLine(line) {
    if (this.hasAmountInputTarget) {
      const row = line.closest("tr")
      const input = row?.querySelector('[data-payment-line-select-target="amountInput"]')
      return Number(input?.value || 0)
    }

    return Number(line.dataset.amount || 0)
  }

  formatMoney(value) {
    return new Intl.NumberFormat("ru-RU", {
      style: "currency",
      currency: "RUB",
      minimumFractionDigits: 2
    }).format(value)
  }
}
