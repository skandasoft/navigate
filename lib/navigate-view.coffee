{View,SelectListView} = require("atom")
class NavigateView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('navigate')
    loading = document.createElement('span')
    loading.classList.add('loading')
    loading.classList.add('loading-spinner-large')
    loading.classList.add('inline-block')
    @element.appendChild(loading)
  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element


class ListView extends SelectListView
  initialize: (items,@cb)->
    super
    @addClass 'overlay from-top'
    @setItems items
    atom.workspaceView.append(@)
    @focusFilterEditor()

  viewForItem: (item)->
    "<li>#{item}</li>"

  confirmed: (item)->
    @cancel()
    @cb(item)

module.exports = { NavigateView,ListView}
