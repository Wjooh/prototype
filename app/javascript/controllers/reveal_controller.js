import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle(event) {
    this.panelTarget.classList.toggle("hidden", !event.target.checked)
  }
}
