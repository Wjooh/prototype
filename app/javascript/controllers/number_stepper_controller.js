import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "display"]
  static values = {
    min: { type: Number, default: 0 },
    max: { type: Number, default: 200 }
  }

  increment() {
    this.setValue(this.currentValue + 1)
  }

  decrement() {
    this.setValue(this.currentValue - 1)
  }

  get currentValue() {
    return Number(this.inputTarget.value) || 0
  }

  setValue(value) {
    const next = Math.min(this.maxValue, Math.max(this.minValue, value))
    this.inputTarget.value = next
    if (this.hasDisplayTarget) this.displayTarget.textContent = next
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }
}
