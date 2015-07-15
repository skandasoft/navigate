{View,SelectListView} = require("atom-space-pen-views")
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
    # @addClass 'overlay from-top'
    @setItems items
    # atom.workspaceView.append(@)
    atom.workspace.addModalPanel item:@
    @focusFilterEditor()

  viewForItem: (item)->
    "<li>#{item}</li>"

  confirmed: (item)->
    @cb(item)
    @remove()

  cancelled: ->
    @remove()

module.exports = { NavigateView,ListView}
