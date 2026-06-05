import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.handleKeydown = this.handleKeydown.bind(this)
  }

  open() {
    this.backdropTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.panelTarget.classList.remove("translate-x-full")
    })
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this.handleKeydown)
  }

  close() {
    this.panelTarget.classList.add("translate-x-full")
    this.backdropTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
