# http://www.skandasoft.com//
fs = require 'fs'
{Range} = require 'atom'
module.exports =
  subscriptions: null
  config: require './config'
  activate: (state) ->
    {CompositeDisposable} = require 'atom'
    @pathCache = state['pathCache'] or {}
    @new = false
    requires = atom.config.get('navigate.require')
    req = require(requires)
    for key,value of req
      param = {}
      param['atom-text-editor'] = {}
      param['atom-text-editor'][key] = "navigate:browser"
      atom.keymaps.add "navigate", param
      atom.config.set("navigate.#{key}",value) if value

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    {NavigateView} = require './navigate-view'
    @loading = new NavigateView()
    @modalPanel = atom.workspace.addModalPanel item:@loading.getElement(), visible:false
    @navi = {}
    atom.commands.add "atom-text-editor",'navigate:back': =>@back()
    atom.commands.add 'atom-text-editor', 'navigate:forward': =>
      @new = atom.config.get('navigate.newwindow')
      @forward()

    atom.commands.add 'atom-text-editor', 'navigate:forward-new': =>
      @new = true
      @forward()
    atom.commands.add "atom-text-editor", 'navigate:refresh': =>@refresh()
    if atom.config.get('navigate.dblclk')
      atom.workspace.observeTextEditors (editor)=>
        view = atom.views.getView(editor)
        view.ondblclick = =>
          @new = atom.config.get('navigate.dblclick')
          @forward()
    atom.commands.add 'atom-text-editor',
        'navigate:browser': (evt)=> @openBrowser(evt)

  browserOption: (evt,text)->
    if evt and evt.originalEvent
      key = evt.originalEvent.keyIdentifier
      key = "CTRL-#{key}" if evt.originalEvent.ctrlKey
      key = "SHIFT-#{key}" if evt.originalEvent.shiftKey
      key = "ALT-#{key}" if evt.originalEvent.altKey
    else
      key = "CTRL-F1"
    @uri = atom.config.get("navigate.#{key}")
    @uri = atom.config.get("navigate.#{key.toUpperCase()}") unless @uri
    @uri = atom.config.get("navigate.#{key.toLowerCase()}") unless @uri

    if @uri
      @uri = @uri.replace('&searchterm',text)
      split = @getPosition()
      opt = {split:split, searchAllPanes:true}
      if atom.config.get('navigate.openInSameWindow')
        opt.openInSameWindow = true
      atom.workspace.open @uri, opt

  openBrowser: (evt)->
    # try get text directly
    active = atom.workspace.getActivePaneItem()
    text = active.getSelectedText() or @getText(active)
    @browserOption evt,text if text

  refresh: ->
    ed = atom.workspace.getActiveTextEditor()
    projectPath = atom.project.getPaths()[0]
    return unless projectPath
    if text = ed?.getSelectedText()
      delete @pathCache[projectPath]?[text]
    else
      @pathCache[projectPath] = {}

  getText: (ed)->
    cursor = ed.getCursors()[0]
    # range = ed.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    # if range
    #   text = ed.getTextInBufferRange(range)[1..-2]
    rn = @getQuoteRange(cursor,ed)
    if rn and rn.end.row is rn.start.row
      text = ed.getTextInBufferRange(rn)
    unless text
      text = ed.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    if text
      text = text[0..-2] if text.slice(-1) is ':'
      text.trim()

  getQuoteRange: (cursor,ed)->
    closing = @getClosingQuotePosition(cursor,ed)
    return false unless closing?
    opening = @getOpeningQuotePosition(cursor,ed)
    return false unless opening?
    new Range opening, closing

  getOpeningQuotePosition: (cursor,ed) ->
    range = cursor.getCurrentLineBufferRange()
    range.end.column = cursor.getScreenPosition().column
    quote = false
    ed.buffer.backwardsScanInRange /[`|'|"]/g, range, (obj) =>
      return false unless @quoteType
      obj.stop() if obj.matchText is @quoteType
      quote = obj.range.end
    quote

  getClosingQuotePosition: (cursor,ed) ->
    range = cursor.getCurrentLineBufferRange()
    range.start.column = cursor.getScreenPosition().column
    quote = false
    delete @quoteType
    ed.buffer.scanInRange /[`|'|"]/g, range, (obj) =>
      @quoteType = obj.matchText
      obj.stop()
      quote = obj.range.start
    quote

  forward: ->
    editor = atom.workspace.getActiveTextEditor()
    @uri = editor.getSelectedText()
    line =  editor.lineTextForScreenRow editor.getCursorScreenPosition().row
    @uri = editor.getSelectedText() or @getText(editor)
    return unless @uri
    split = @getPosition()

    open = =>
      path = require 'path'
      # check if it has require
      fpath = path.dirname editor.getPath()
      ext = path.extname editor.getPath()
      projectPath = atom.project.getPaths()[0]
      exists = fs.existsSync or fs.accessSync
      filename = path.basename(@uri)

      globSearch = =>
        findup = require 'findup-sync'
        glob = require 'glob'
        ignore = atom.config.get('navigate.ignore') or []
        glob "**/*#{filename}*",{cwd:projectPath,stat:false,nocase:true,nodir:true,ignore:ignore}, (err,files)=>
          if err or not files.length
            fpaths = findup filename,{cwd:projectPath,nocase:true}
            if fpaths
              stats = fs.lstatSync(fpaths)
              if not stats or stats.isDirectory() or stats.isSymbolicLink()
                console.log 'Found Path but it is directory',fpaths
                @modalPanel.hide()
                return
              @matchFile(@uri,ext,fpaths,editor)
            else
              @modalPanel.hide()
          else
            @matchFile(@uri,ext,files,editor)

      openFile = =>
        path = require 'path'
        try
          if ofname = @pathCache[projectPath]?[@uri]
            @open([ofname],editor)
            return

          baseDir = atom.config.get('navigate.basedir') or []
          fileSrc = []
          if @uri[0] is '/' or @uri[0] is '\\'
            if fpath.startsWith(projectPath)
              fileSrc.unshift projectPath+'/'+@uri
              fileSrc.unshift projectPath+'/'+@uri+ext unless path.extname @uri
            else
              fileSrc.unshift fpath+"/../"+@uri
              fileSrc.unshift fpath+"/../"+@uri+ext unless path.extname @uri
          else
            fileSrc.unshift fpath+@uri
            fileSrc.unshift fpath+@uri+ext unless path.extname @uri

          for i,dir of baseDir
            if @uri[0] is '/' or @uri[0] is '\\'
              if fpath.startsWith(projectPath)
                fileSrc.unshift projectPath+'/'+ dir+'/'+@uri
              else
                fileSrc.unshift fpath+'/../'+ dir+'/'+@uri
            else
              fileSrc.unshift fpath+'/'+ dir+'/'+@uri

          for url in fileSrc
            if exists url
              @open([url],editor)
              return

          filename = path.basename(@uri)
          # else
          @complex = true
          globSearch()
        catch e
          console.log 'Error finding the filepath',e
      try
        resolve = require 'resolve'
        @modalPanel.show()
        if line.includes 'require'
          if resolve.isCore(@uri)
            url = "https://github.com/joyent/node/blob/master/lib/#{@uri}.js"
            @modalPanel.hide()
            return atom.workspace.open url, {split:split, searchAllPanes:true}

          filepath = resolve.sync(@uri, basedir:fpath,extensions:['.js','.coffee'])
          return @open([filepath],editor) if fs.statSync filepath
        openFile()
      catch e
        console.log 'Error finding the filepath',e
        try
          module  = require 'module'
          return @open([filepath],editor) if fs.statSync filepath if filepath =  module._resolveFilename @uri
          openFile()
        catch e
          console.log 'Error finding the filepath with module',e
          openFile()

    if @uri.indexOf('http:') is 0  or @uri.indexOf('https:') is 0 or @uri.indexOf('localhost:') is 0
      atom.workspace.open @uri, {split:split, searchAllPanes:true}
    else
      open(@uri)

  matchFile: (filename,ext,files,editor)->
    @modalPanel.hide()
    if typeof files is 'string'
      @open([files],editor)
    else
      if filename in files
        @open([filename],editor)
      else
        if fname = filename+ext in files
          @open([fname],editor)
        else
          # Open files in the list view & open the select file and save it
          # fuse = new Fuse files
          # result = fuse.search(filename)[0]
          # @open([files[result]],editor)
          if files.length is 1
            @open(files,editor)
          else
            {ListView} = require './navigate-view'
            new ListView files, (file)=>
              @open([file],editor)

  open: (url,editor,back=false)->
    @modalPanel.hide()
    unless @new
      if editor.isModified()
        if editor.shouldPromptToSave()
          it = atom.workspace.getActivePaneItem()
          pane = atom.workspace.getActivePane()
          return unless pane.promptToSaveItem(it)
        else
          editor.save()
    atom.workspace.open url[0]
      .then (ed)=>
        projectPath = atom.project.getPaths()[0]
        ed.setCursorScreenPosition(url[1]) if url[1]
        @navi["#{ed.getPath()}"] = [editor.getPath(),editor.getCursorScreenPosition()] unless back
        if @complex
          @complex = false
          @pathCache[projectPath] or= {}
          @pathCache[projectPath][@uri] = ed.getPath() unless back
        @modalPanel.hide()
        if @new then @new = false else editor.destroy()

  back: ->
    editor = atom.workspace.getActivePaneItem()
    fpath = editor.getPath()
    return unless navi = @navi[fpath]
    delete @navi[fpath]
    @open(navi,editor,true)

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    pathCache: @pathCache
  toggle: ->

  getPosition: ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    paneAxis = activePane.getParent()
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if  paneIndex is 0 then 'right' else 'left'
    else
      if  paneIndex is 0 then 'down' else 'up'
