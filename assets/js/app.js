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
  toggleAddDelete() {
      const deleter = document.getElementById('deleter')
      if (deleter) {
        const adder = document.getElementById('adder')
        deleter.hidden = adder.hidden
        adder.hidden = !adder.hidden
      }
  },

  get dragImage() {
    const canvas = document.createElement("canvas")
    canvas.width = canvas.height = 60
    const ctx = canvas.getContext("2d")

    ctx.beginPath()
    ctx.arc(30, 30, 30, 0, 2 * Math.PI)
    ctx.fill()

    return canvas
  },

  mounted() {
    this.el.addEventListener("dragstart", event => {
      event.dataTransfer.setData("text/plain", `task-id:${this.el.dataset.taskId}`)
      event.dataTransfer.setDragImage(this.dragImage, 25, 25)
      this.toggleAddDelete()
    })

    this.el.addEventListener("dragend", event => {
      this.toggleAddDelete()
    })
  },
}

Hooks.AddDropper = {
  get bgClass() { return "has-background-warning"},

  addTaskToPlan(payload) { return this.pushEvent("add-task-to-plan", payload) },

  getTaskPayload(event) { return event.dataTransfer.getData("text/plain") },

  parseTaskPayload(payload) { return payload.startsWith("task-id:") ? payload.split(":")[1] : null },

  addHoverClass(event) { event.target.classList.add(this.bgClass) },

  removeHoverClass(event) { event.target.classList.remove(this.bgClass) },

  mounted() {
    this.el.addEventListener("drop", event => {
      event.preventDefault()
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) {
        const planID = this.el.dataset.planId
        this.addTaskToPlan({ "task-id": taskID, "plan-id": planID, })
        this.removeHoverClass(event)
      }
    })

    this.el.addEventListener("dragover", event => event.preventDefault())

    this.el.addEventListener("dragenter", event => {
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) { this.addHoverClass(event) }
    })

    this.el.addEventListener("dragleave", event => {
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) { this.removeHoverClass(event) }
    })
  }
}

Hooks.DeleteDropper = {
  get hoverBGClass() { return "has-background-warning"},

  get baseBGClass() { return "has-background-danger"},

  deleteTaskFromPlan(payload) { return this.pushEvent("delete-task-from-plan", payload) },

  getTaskPayload(event) { return event.dataTransfer.getData("text/plain") },

  parseTaskPayload(payload) { return payload.startsWith("task-id:") ? payload.split(":")[1] : null },

  addHoverClass(event) {
    event.target.classList.add(this.hoverBGClass)
    event.target.classList.remove(this.baseBGClass)
  },

  removeHoverClass(event) {
    event.target.classList.remove(this.hoverBGClass)
    event.target.classList.add(this.baseBGClass)
  },

  mounted() {
    this.el.addEventListener("drop", event => {
      event.preventDefault()
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) {
        const planID = this.el.dataset.drop
        this.deleteTaskFromPlan({ "task-id": taskID, "plan-id": planID, })
        this.removeHoverClass(event)
      }
    })

    this.el.addEventListener("dragover", event => event.preventDefault())

    this.el.addEventListener("dragenter", event => {
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) { this.addHoverClass(event) }
    })

    this.el.addEventListener("dragleave", event => {
      const payload = this.getTaskPayload(event)
      const taskID = this.parseTaskPayload(payload)
      if (taskID !== null) { this.removeHoverClass(event) }
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
