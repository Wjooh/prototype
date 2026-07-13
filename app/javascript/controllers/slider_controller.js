import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display", "caption"]

  connect() {
    this.update()
  }

  update() {
    const value = Number(this.inputTarget.value)

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.displayLabel(value)
    }

    if (this.hasCaptionTarget) {
      this.captionTarget.textContent = this.captionFor(value)
    }

    this.inputTarget.setAttribute("aria-valuenow", String(value))
  }

  increment() {
    this.nudge(1)
  }

  decrement() {
    this.nudge(-1)
  }

  nudge(delta) {
    const min = Number(this.inputTarget.min)
    const max = Number(this.inputTarget.max)
    const next = Math.min(max, Math.max(min, Number(this.inputTarget.value) + delta))
    this.inputTarget.value = next
    this.update()
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  displayLabel(value) {
    const labels = this.inputTarget.dataset.sliderLabels
    if (!labels) return String(value)

    try {
      const parsed = JSON.parse(labels)
      return parsed[value] ?? String(value)
    } catch {
      return String(value)
    }
  }

  captionFor(value) {
    const bands = this.inputTarget.dataset.sliderBands
    if (!bands) return ""

    try {
      const parsed = JSON.parse(bands)
      const match = parsed.find((band) => {
        const inclusiveMax = band.inclusive_max === true
        return inclusiveMax
          ? value >= band.min && value <= band.max
          : value >= band.min && value < band.max
      })
      return match?.label ?? ""
    } catch {
      return ""
    }
  }
}
