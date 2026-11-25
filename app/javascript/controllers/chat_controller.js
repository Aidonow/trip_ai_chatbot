import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  send(event) {
    const form = event.target
    const content = new FormData(form).get("message[content]")?.trim()
    if (!content) return

    const bubble = document.createElement("div")
    bubble.className = "mb-3"

    const author = document.createElement("strong")
    author.textContent = "You"

    const text = document.createElement("p")
    text.textContent = content

    const status = document.createElement("small")
    status.className = "text-muted"
    status.setAttribute("role", "status")
    status.textContent = "AI Travel is typing…"

    bubble.append(author, text, status)
    this.messagesTarget.append(bubble)
    this.pendingBubble = bubble

    // Déplace uniquement la conversation, pas la page entière.
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  finish(event) {
    if (!event.detail.success) {
      this.pendingBubble?.remove()
    }
  }

  // Appelé quand Turbo insère la fin de la nouvelle réponse.
  endTargetConnected(element) {
    const messages = element.parentElement
    messages.scrollTop = messages.scrollHeight
  }

  static get targets() {
    return ["messages", "end"]
  }
}
