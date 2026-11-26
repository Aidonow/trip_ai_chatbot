import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  send(event) {
    const form = event.target
    const content = new FormData(form).get("message[content]")?.trim()
    if (!content) return

    const pending = document.createElement("div")
    pending.id = "pending-message"

    pending.innerHTML = `
      <div class="d-flex align-items-end justify-content-end gap-2 w-100 mb-3">
        <div class="message-bubble">
          <strong>You</strong>
          <p class="mb-0" data-message-content></p>
        </div>
        <span class="avatar avatar-vert flex-shrink-0"
              data-user-avatar aria-hidden="true"></span>
      </div>

      <div class="d-flex align-items-end justify-content-start gap-2 w-100 mb-3">
        <img class="avatar flex-shrink-0" data-aido-avatar alt="">
        <div class="message-bubble">
          <strong>Aïdo</strong>
          <small class="text-muted" role="status">Aïdo is typing…</small>
        </div>
      </div>
    `

    pending.querySelector("[data-message-content]").textContent = content
    pending.querySelector("[data-user-avatar]").textContent = this.element.dataset.userInitial
    pending.querySelector("[data-aido-avatar]").src = this.element.dataset.aidoAvatarUrl

    this.messagesTarget.append(pending)
    this.pendingBubble = pending

    pending.firstElementChild.scrollIntoView({
      behavior: "smooth",
      block: "center"
    })
  }

  finish(event) {
    if (!event.detail.success) {
      this.pendingBubble?.remove()
    }
  }
}
