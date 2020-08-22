// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

import '@fortawesome/fontawesome-free/js/all'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let Hooks = {}

Hooks.Dragger = {
  mounted() {
    this.el.addEventListener("dragstart", event => {
      event.target.style.opacity = 0.4
      event.dataTransfer.setData("text/plain", this.el.dataset.taskId)
    })
    this.el.addEventListener("dragend", event => {
      event.target.style.opacity = 1.0
    })
  },
}

Hooks.Dropper = {
  mounted() {
    this.el.addEventListener("drop", event => {
      event.preventDefault()
      event.target.style.background = ""
      const taskId = event.dataTransfer.getData("text/plain")
      const planId = this.el.dataset.planId
      this.pushEvent("add-task-to-plan", {"task-id": taskId, "plan-id": planId})
    })

    this.el.addEventListener("dragover", event => {
      event.preventDefault()
    })

    this.el.addEventListener("dragenter", event => {
      event.target.style.background = "yellow"
    })

    this.el.addEventListener("dragleave", event => {
      event.target.style.background = ""
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

document.addEventListener('DOMContentLoaded', () => {
    const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0)
    if ($navbarBurgers.length > 0) {
      $navbarBurgers.forEach( el => {
        el.addEventListener('click', () => {
          const target = el.dataset.target
          const $target = document.getElementById(target)
          el.classList.toggle('is-active')
          $target.classList.toggle('is-active')
        })
      })
    }
})
