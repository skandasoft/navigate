module.exports =
class NavigateView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('navigate')
    @element.style.textAlign = 'center'
    # Create message element
    loading = document.createElement('span')
    loading.classList.add('loading,loading-spinner-large,inline-block')
    @element.appendChild(loading)
  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
