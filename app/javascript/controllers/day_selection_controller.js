import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["order"]

  selectOrder(event) {
    const orderId = event.currentTarget.dataset.orderId
    this.clear()
    this.orderTargets.forEach((el) => {
      const selected = el.dataset.orderId === orderId
      el.dataset.selected = selected ? "true" : "false"
      el.dataset.related = selected ? "true" : "false"
      el.dataset.dimmed = selected ? "false" : "true"
    })
  }

  clear() {
    this.orderTargets.forEach((el) => {
      el.dataset.selected = "false"
      el.dataset.related = "false"
      el.dataset.dimmed = "false"
    })
  }
}
