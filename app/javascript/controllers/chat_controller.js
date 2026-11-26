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
    <div class="d-flex justify-content-end w-100 mb-3">
      <div class="message-bubble">
        <strong>You</strong>
        <p class="mb-0"></p>
      </div>
    </div>

    <div class="d-flex justify-content-start w-100 mb-3">
      <div class="message-bubble">
        <strong>Aïdo</strong>
        <small class="text-muted" role="status">Aïdo is typing…</small>
      </div>
    </div>
  `

  pending.querySelector("p").textContent = content
  this.messagesTarget.append(pending)
  this.pendingBubble = pending

// La première ligne de pending contient le message « You ».
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
