#= require ./inspector/inspector_controller

Trix.attributes["code"] = { tagName: "code", inheritable: true }

config =
  textarea: "text"
  toolbar: "toolbar"
  input: "data"
  className: "formatted"
  delegate:
    shouldAcceptFile: (file) ->
      true

    didAddAttachment: (attachment) ->
      console.log "Host received attachment:", attachment
      saveAttachment(attachment)

      if file = attachment.file
        setTimeout ->
          if /image/.test(file.type)
           attributes = { url: "basecamp.png" }
          else
            filename = "basecamp-#{file.name}.rb"
            attributes = { url: filename, filename }

          console.log "Host setting attributes for attachment:", attachment, attributes
          attachment.setAttributes(attributes)
        , 1000

    didRemoveAttachment: (attachment) ->
      console.log "Host received removed attachment:", attachment
      removeAttachment(attachment)

    didChangeSelection: ->
      inspectorController.render()

    didRenderDocument: ->
      inspectorController.render()

saveAttachment = (attachment) ->
  item = document.createElement("li")
  item.setAttribute("id", "attachment_#{attachment.id}")
  item.textContent = "#{attachment.attributes.filename ? attachment.attributes.url} "

  link = document.createElement("a")
  link.setAttribute("href", "#")
  link.textContent = "(remove)"
  link.addEventListener "click", ->
    window.controller.composition.removeAttachment(attachment)
    removeAttachment(attachment)

  item.appendChild(link)
  document.getElementById("attachments").appendChild(item)

removeAttachment = (attachment) ->
  if item = document.getElementById("attachment_#{attachment.id}")
    item.parentElement.removeChild(item)


installTrix = ->
  if Trix.isSupported(config)
    window.controller = Trix.install(config)

    toolbarElement = document.getElementById("toolbar")
    toolbarElement.style.display = "block"

    inspectorElement = document.getElementById("inspector")
    inspectorElement.style.display = "block"

    window.inspectorController = new Trix.InspectorController inspectorElement, window.controller

  else
    config.mode = "degraded"
    if Trix.isSupported(config)
      window.controller = Trix.install(config)

document.addEventListener "DOMContentLoaded", installTrix
