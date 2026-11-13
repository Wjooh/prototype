import { Controller } from "@hotwired/stimulus"

// Draws curved SVG edges between [data-workflow-node] boxes.
// Ports are spaced along each node's edge so parallel inputs don't cross.
export default class extends Controller {
  static targets = ["canvas", "edge"]

  connect() {
    this.draw = this.draw.bind(this)
    this.observer = new ResizeObserver(this.draw)
    this.observer.observe(this.element)
    requestAnimationFrame(this.draw)
  }

  disconnect() {
    this.observer?.disconnect()
  }

  draw() {
    const svg = this.canvasTarget
    const root = this.element.getBoundingClientRect()

    svg.setAttribute("viewBox", `0 0 ${root.width} ${root.height}`)
    svg.innerHTML = ""

    const outCounts = {}
    const inCounts = {}
    this.edgeTargets.forEach((edge) => {
      outCounts[edge.dataset.from] = (outCounts[edge.dataset.from] || 0) + 1
      inCounts[edge.dataset.to] = (inCounts[edge.dataset.to] || 0) + 1
    })

    const outIndex = {}
    const inIndex = {}

    this.edgeTargets.forEach((edge, index) => {
      const fromEl = this.element.querySelector(`[data-workflow-node="${edge.dataset.from}"]`)
      const toEl = this.element.querySelector(`[data-workflow-node="${edge.dataset.to}"]`)
      if (!fromEl || !toEl) return

      const fromKey = edge.dataset.from
      const toKey = edge.dataset.to
      const oi = outIndex[fromKey] || 0
      outIndex[fromKey] = oi + 1
      const ii = inIndex[toKey] || 0
      inIndex[toKey] = ii + 1

      const from = fromEl.getBoundingClientRect()
      const to = toEl.getBoundingClientRect()
      const x1 = from.right - root.left
      const y1 = from.top - root.top + ((oi + 0.5) / outCounts[fromKey]) * from.height
      const x2 = to.left - root.left
      const y2 = to.top - root.top + ((ii + 0.5) / inCounts[toKey]) * to.height
      const dx = Math.max(36, (x2 - x1) * 0.5)
      const d = `M ${x1} ${y1} C ${x1 + dx} ${y1}, ${x2 - dx} ${y2}, ${x2} ${y2}`

      const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
      path.setAttribute("d", d)
      path.setAttribute("class", "workflow-edge")
      path.style.animationDelay = `${index * 0.2}s`
      svg.appendChild(path)

      if (edge.dataset.label) {
        const mx = cubic(x1, x1 + dx, x2 - dx, x2, 0.5)
        const my = cubic(y1, y1, y2, y2, 0.5) - 7
        const text = document.createElementNS("http://www.w3.org/2000/svg", "text")
        text.setAttribute("x", mx)
        text.setAttribute("y", my)
        text.setAttribute("text-anchor", "middle")
        text.setAttribute("class", "workflow-edge-label")
        text.textContent = edge.dataset.label
        svg.appendChild(text)
      }
    })
  }
}

function cubic(a, b, c, d, t) {
  const mt = 1 - t
  return mt * mt * mt * a + 3 * mt * mt * t * b + 3 * mt * t * t * c + t * t * t * d
}
