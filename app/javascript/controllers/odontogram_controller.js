import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "shade",
    "typeSelect",
    "materialSelect",
    "tooth",
    "connector",
    "summaryList",
    "toothColorField"
  ]
  static values = {
    labels: Object,
    colors: Object,
    materialLabels: Object,
    readonly: { type: Boolean, default: false }
  }

  connect() {
    try {
      this.state = JSON.parse(this.inputTarget?.value || "{}")
    } catch (_e) {
      this.state = { notation: "fdi", shade: null, teeth: [], connectors: [] }
    }
    if (!Array.isArray(this.state.teeth)) this.state.teeth = []
    if (!Array.isArray(this.state.connectors)) this.state.connectors = []
    this.state.notation = "fdi"
    this.activeN = this.state.teeth[0] ? Number(this.state.teeth[0].n) : null
    if (this.hasShadeTarget && !this.state.shade && this.shadeTarget.value) {
      this.state.shade = this.shadeTarget.value
    }
    this.syncSelectsFromActive()
    this.render()
  }

  toggle(event) {
    if (this.readonlyValue) return
    event.preventDefault()
    event.stopPropagation()
    const n = Number(event.currentTarget.dataset.n)
    if (!n) return

    const copy = event.ctrlKey || event.metaKey
    const existingIndex = this.state.teeth.findIndex((t) => Number(t.n) === n)

    if (copy) {
      const source = this.sourceToothForCopy()
      const params = {
        type: source?.type || null,
        material: source?.material || null,
        shade: null
      }
      if (existingIndex >= 0) {
        this.state.teeth[existingIndex] = { n, ...params }
      } else {
        this.state.teeth.push({ n, ...params })
      }
      this.activeN = n
    } else if (existingIndex >= 0) {
      if (this.activeN === n) {
        this.state.teeth.splice(existingIndex, 1)
        this.pruneConnectors()
        this.activeN = this.state.teeth.length ? Number(this.state.teeth[this.state.teeth.length - 1].n) : null
      } else {
        this.activeN = n
      }
    } else {
      this.state.teeth.push({ n, type: null, material: null, shade: null })
      this.activeN = n
    }

    this.syncSelectsFromActive()
    this.sync()
  }

  toggleConnector(event) {
    if (this.readonlyValue) return
    event.preventDefault()
    event.stopPropagation()
    const a = Number(event.currentTarget.dataset.a)
    const b = Number(event.currentTarget.dataset.b)
    if (!a || !b) return

    const key = this.connectorKey(a, b)
    const idx = this.state.connectors.findIndex((pair) => this.connectorKey(pair[0], pair[1]) === key)
    if (idx >= 0) {
      this.state.connectors.splice(idx, 1)
    } else {
      this.state.connectors.push([Math.min(a, b), Math.max(a, b)])
    }
    this.sync()
  }

  applyParams() {
    if (this.readonlyValue || !this.activeN) return
    const tooth = this.state.teeth.find((t) => Number(t.n) === this.activeN)
    if (!tooth) return

    tooth.type = this.typeSelectTarget.value || null
    tooth.material = this.hasMaterialSelectTarget ? (this.materialSelectTarget.value || null) : null
    this.sync()
  }

  sourceToothForCopy() {
    if (this.activeN) {
      const active = this.state.teeth.find((t) => Number(t.n) === this.activeN)
      if (active && (active.type || active.material)) return active
    }
    return [...this.state.teeth].reverse().find((t) => t.type || t.material) || null
  }

  syncSelectsFromActive() {
    if (!this.hasTypeSelectTarget) return
    const tooth = this.activeN
      ? this.state.teeth.find((t) => Number(t.n) === this.activeN)
      : null
    this.typeSelectTarget.value = tooth?.type || ""
    if (this.hasMaterialSelectTarget) {
      this.materialSelectTarget.value = tooth?.material || ""
    }
  }

  sync() {
    if (this.hasShadeTarget) {
      this.state.shade = this.shadeTarget.value || null
    }
    if (this.hasToothColorFieldTarget) {
      this.toothColorFieldTarget.value = this.state.shade || ""
    }
    if (this.hasInputTarget) {
      this.inputTarget.value = JSON.stringify(this.state)
    }
    this.render()
  }

  connectorKey(a, b) {
    return [Math.min(Number(a), Number(b)), Math.max(Number(a), Number(b))].join("-")
  }

  hasTooth(n) {
    return this.state.teeth.some((t) => Number(t.n) === Number(n))
  }

  pruneConnectors() {
    this.state.connectors = this.state.connectors.filter((pair) => {
      const [a, b] = pair
      return this.hasTooth(a) && this.hasTooth(b)
    })
  }

  render() {
    const colors = this.hasColorsValue ? this.colorsValue : {}
    const labels = this.hasLabelsValue ? this.labelsValue : {}
    const materialLabels = this.hasMaterialLabelsValue ? this.materialLabelsValue : {}
    const byN = Object.fromEntries(this.state.teeth.map((t) => [Number(t.n), t]))
    const connectorSet = new Set(this.state.connectors.map((pair) => this.connectorKey(pair[0], pair[1])))

    this.toothTargets.forEach((el) => {
      const n = Number(el.dataset.n)
      const tooth = byN[n]
      const body = el.querySelector(".odontogram-tooth-body")
      const title = el.querySelector("title")
      const isActive = this.activeN === n

      el.classList.toggle("is-active", Boolean(tooth && isActive))
      el.classList.toggle("is-selected", Boolean(tooth && tooth.type))
      el.classList.toggle("is-untyped", Boolean(tooth && !tooth.type))

      if (!body) return

      if (tooth) {
        if (tooth.type) {
          const color = colors[tooth.type] || "#94A3B8"
          body.setAttribute("fill", color)
          body.setAttribute("stroke", isActive ? "#0f172a" : this.darken(color))
        } else {
          body.setAttribute("fill", "#fde68a")
          body.setAttribute("stroke", isActive ? "#0f172a" : "#ca8a04")
        }
        const typeLabel = tooth.type ? (labels[tooth.type] || tooth.type) : "без типа"
        const materialLabel = tooth.material ? (materialLabels[tooth.material] || tooth.material) : "без материала"
        if (title) title.textContent = `${n}: ${typeLabel}, ${materialLabel}`
      } else {
        body.setAttribute("fill", "#ffffff")
        body.setAttribute("stroke", "#94a3b8")
        if (title) title.textContent = String(n)
      }
    })

    if (this.hasConnectorTarget) {
      this.connectorTargets.forEach((el) => {
        const a = Number(el.dataset.a)
        const b = Number(el.dataset.b)
        const visible = this.hasTooth(a) && this.hasTooth(b)
        el.style.display = visible ? "block" : "none"
        const on = connectorSet.has(this.connectorKey(a, b))
        el.classList.toggle("is-on", on)
        el.classList.toggle("is-off", visible && !on)
      })
    }

    if (this.hasSummaryListTarget) {
      if (this.state.teeth.length === 0) {
        this.summaryListTarget.innerHTML = `<p class="text-sm text-slate-500">Зубы не выбраны</p>`
      } else {
        const rows = this.groupedSummaryRows(this.state.teeth)
          .map((group) => {
            const typeLabel = group.type ? (labels[group.type] || group.type) : "— не задан —"
            const materialLabel = group.material ? (materialLabels[group.material] || group.material) : "— не задан —"
            const color = group.type ? (colors[group.type] || "#94A3B8") : "#EAB308"
            const numbersLabel = this.formatToothNumbers(group.numbers)
            const activeMark = group.numbers.includes(this.activeN) ? " · активный" : ""
            return `
              <div class="odontogram-summary-row">
                <span class="odontogram-legend-swatch" style="background:${color}"></span>
                <strong>${numbersLabel}</strong>
                <span>тип: ${typeLabel}</span>
                <span class="text-slate-400">·</span>
                <span>материал: ${materialLabel}</span>
                <span class="text-slate-400 text-xs">${activeMark}</span>
              </div>`
          })
          .join("")
        this.summaryListTarget.innerHTML = `<p class="odontogram-summary-title">Выбранные зубы</p>${rows}`
      }
    }
  }

  groupedSummaryRows(teeth) {
    const groups = new Map()
    teeth.forEach((t) => {
      const key = `${t.type ?? ""}\0${t.material ?? ""}`
      if (!groups.has(key)) {
        groups.set(key, { type: t.type, material: t.material, numbers: [] })
      }
      groups.get(key).numbers.push(Number(t.n))
    })
    return [...groups.values()]
      .map((g) => ({ ...g, numbers: g.numbers.sort((a, b) => a - b) }))
      .sort((a, b) => a.numbers[0] - b.numbers[0])
  }

  formatToothNumbers(numbers) {
    if (numbers.length === 0) return ""
    if (numbers.length === 1) return String(numbers[0])

    const parts = []
    let start = numbers[0]
    let prev = numbers[0]

    for (let i = 1; i <= numbers.length; i++) {
      const n = numbers[i]
      if (i < numbers.length && n === prev + 1) {
        prev = n
        continue
      }
      if (start === prev) {
        parts.push(String(start))
      } else if (prev === start + 1) {
        parts.push(`${start}, ${prev}`)
      } else {
        parts.push(`${start}–${prev}`)
      }
      if (i < numbers.length) {
        start = n
        prev = n
      }
    }
    return parts.join(", ")
  }

  darken(hex) {
    const raw = String(hex || "").replace("#", "")
    if (raw.length !== 6) return "#334155"
    const num = parseInt(raw, 16)
    const r = Math.max(0, ((num >> 16) & 255) - 35)
    const g = Math.max(0, ((num >> 8) & 255) - 35)
    const b = Math.max(0, (num & 255) - 35)
    return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`
  }
}
