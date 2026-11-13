import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["order", "delivery"]

  selectOrder(event) {
    const orderId = event.currentTarget.dataset.orderId
    this.clear()
    this.orderTargets.forEach((el) => {
      const selected = el.dataset.orderId === orderId
      el.dataset.selected = selected ? "true" : "false"
      el.dataset.related = selected ? "true" : "false"
      el.dataset.dimmed = selected ? "false" : "true"
    })
    this.deliveryTargets.forEach((el) => {
      const related = el.dataset.orderIds.split(" ").includes(orderId)
      el.dataset.selected = "false"
      el.dataset.related = related ? "true" : "false"
      el.dataset.dimmed = related ? "false" : "true"
    })
  }

  selectDelivery(event) {
    const deliveryId = event.currentTarget.dataset.deliveryId
    const orderIds = event.currentTarget.dataset.orderIds.split(" ").filter(Boolean)
    this.clear()
    this.deliveryTargets.forEach((el) => {
      const selected = el.dataset.deliveryId === deliveryId
      el.dataset.selected = selected ? "true" : "false"
      el.dataset.related = selected ? "true" : "false"
      el.dataset.dimmed = selected ? "false" : "true"
    })
    this.orderTargets.forEach((el) => {
      const related = orderIds.includes(el.dataset.orderId)
      el.dataset.selected = "false"
      el.dataset.related = related ? "true" : "false"
      el.dataset.dimmed = related ? "false" : "true"
    })
  }

  clear() {
    ;[...this.orderTargets, ...this.deliveryTargets].forEach((el) => {
      el.dataset.selected = "false"
      el.dataset.related = "false"
      el.dataset.dimmed = "false"
    })
  }
}
