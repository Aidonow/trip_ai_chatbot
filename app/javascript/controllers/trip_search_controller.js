import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card", "count", "empty"]

  filter(event) {
    const query = event.target.value.trim().toLowerCase()
    let visibleCount = 0

    this.cardTargets.forEach((card) => {
      const destination = card.dataset.destination.toLowerCase()
      const matches = destination.includes(query)

      card.classList.toggle("d-none", !matches)
      if (matches) visibleCount += 1
    })

    this.countTarget.textContent = `${visibleCount} ${visibleCount === 1 ? "trip" : "trips"}`
    this.emptyTarget.hidden = visibleCount > 0
  }
}
