import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display", "band"]

  connect() {
    this.update()
  }

  update() {
    const value = Number(this.inputTarget.value)

    if (this.hasDisplayTarget) {
      this.displayTarget.textContent = this.displayLabel(value)
    }

    this.bandTargets.forEach((band) => {
      const exact = band.dataset.sliderValue
      let active = false

      if (exact !== undefined) {
        active = Number(exact) === value
      } else {
        const min = Number(band.dataset.sliderMin)
        const max = Number(band.dataset.sliderMax)
        const inclusiveMax = band.dataset.sliderInclusiveMax === "true"
        active = inclusiveMax ? value >= min && value <= max : value >= min && value < max
      }

      band.classList.toggle("bg-gray-800", active)
      band.classList.toggle("text-white", active)
      band.classList.toggle("bg-gray-100", !active)
      band.classList.toggle("text-gray-500", !active)
    })
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
}
