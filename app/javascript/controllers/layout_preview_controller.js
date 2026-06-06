import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["appNav", "mobileButton", "appButton"]
  static values = { mode: String, updateUrl: String }

  connect() {
    this.modeValue = document.documentElement.dataset.layoutMode || "mobile"
  }

  setApp() {
    this.modeValue = "app"
  }

  setMobile() {
    this.modeValue = "mobile"
  }

  modeValueChanged() {
    document.documentElement.dataset.layoutMode = this.modeValue
    this.updateUI()
    this.persistMode()
  }

  persistMode() {
    fetch(this.updateUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken
      },
      body: JSON.stringify({ mode: this.modeValue })
    })
  }

  updateUI() {
    const isApp = this.modeValue === "app"

    if (this.hasAppNavTarget) {
      this.appNavTarget.classList.toggle("hidden", !isApp)
    }

    if (this.hasAppButtonTarget) {
      this.toggleSegment(this.appButtonTarget, isApp)
    }

    if (this.hasMobileButtonTarget) {
      this.toggleSegment(this.mobileButtonTarget, !isApp)
    }
  }

  toggleSegment(button, active) {
    button.classList.toggle("bg-gray-800", active)
    button.classList.toggle("text-white", active)
    button.classList.toggle("text-gray-500", !active)
    button.setAttribute("aria-pressed", active)
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
