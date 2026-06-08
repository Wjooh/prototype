import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  open() {
    this.backdropTarget.setAttribute("aria-hidden", "false")
    this.panelTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this.handleKeydown)
  }

  close() {
    this.backdropTarget.setAttribute("aria-hidden", "true")
    this.panelTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
