import { Controller } from "@hotwired/stimulus"

const KEY = "timeline-drag-positions"

// Vertical drag of timeline islands. Snaps to row tops from the initial layout;
// overlaps allowed; tops persisted in localStorage.
export default class extends Controller {
  static targets = ["block", "edge", "canvas"]

  connect() {
    requestAnimationFrame(() => {
      this.rows = unique(this.blockTargets.map((el) => this.topIn(el)))
      const saved = load()
      let dirty = false
      this.blockTargets.forEach((el) => {
        if (!el.id || saved[el.id] == null) return
        el.style.top = saved[el.id]
        dirty = true
      })
      if (dirty) this.drawEdges()
    })
  }

  grab(event) {
    if (event.button != null && event.button !== 0) return
    const el = event.currentTarget
    if (!this.rows?.length) this.rows = unique(this.blockTargets.map((b) => this.topIn(b)))
    el.setPointerCapture(event.pointerId)
    this.drag = {
      el,
      originClientY: event.clientY,
      originTop: this.topIn(el),
      parentTop: this.topIn(el.offsetParent)
    }
    el.dataset.dragging = ""
    el.style.zIndex = "5"
    event.preventDefault()
  }

  move(event) {
    const d = this.drag
    if (!d) return
    const desired = d.originTop + (event.clientY - d.originClientY)
    const snap = nearest(this.rows, desired)
    d.el.style.top = `${snap - d.parentTop}px`
    this.drawEdges()
  }

  drop() {
    const d = this.drag
    if (!d) return
    delete d.el.dataset.dragging
    d.el.style.zIndex = ""
    if (d.el.id) {
      const saved = load()
      saved[d.el.id] = d.el.style.top
      localStorage.setItem(KEY, JSON.stringify(saved))
    }
    this.drag = null
    this.drawEdges()
  }

  reset() {
    localStorage.removeItem(KEY)
    location.reload()
  }

  drawEdges() {
    if (!this.hasEdgeTarget) return
    const root = this.edgeTarget.ownerSVGElement.getBoundingClientRect()
    this.edgeTargets.forEach((path) => {
      const from = this.element.querySelector(`#${CSS.escape(path.dataset.from)}`)
      const to = this.element.querySelector(`#${CSS.escape(path.dataset.to)}`)
      if (!from || !to) return
      const a = from.getBoundingClientRect()
      const b = to.getBoundingClientRect()
      const x1 = a.right - root.left
      const y1 = a.top + a.height / 2 - root.top
      const x2 = b.left - root.left
      const y2 =
        path.dataset.y2 === "from" ? y1 : b.top + b.height / 2 - root.top
      const mx = (x1 + x2) / 2
      path.setAttribute(
        "d",
        x2 < x1
          ? `M ${mx} ${y1} C ${mx} ${y1}, ${mx} ${y2}, ${mx} ${y2}`
          : `M ${x1} ${y1} C ${mx} ${y1}, ${mx} ${y2}, ${x2} ${y2}`
      )
    })
  }

  topIn(el) {
    return el.getBoundingClientRect().top - this.canvasTarget.getBoundingClientRect().top
  }
}

function load() {
  try {
    return JSON.parse(localStorage.getItem(KEY)) || {}
  } catch {
    return {}
  }
}

function unique(xs) {
  return [...new Set(xs.map((x) => Math.round(x)))].sort((a, b) => a - b)
}

function nearest(rows, y) {
  return rows.reduce((best, row) => (Math.abs(row - y) < Math.abs(best - y) ? row : best))
}
