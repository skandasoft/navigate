{CompositeDisposable,Point, Range} = require 'atom'
path = require 'path'
fs = require 'fs'
findup = require 'findup-sync'
glob = require 'glob'
resolve = require 'resolve'

{NavigateView,ListView} = require './navigate-view'
module.exports =
  navigateView: null
  subscriptions: null
  config:
    dblclick:
      title: 'New Window'
      type: 'boolean'
      default: false

  activate: (state) ->
    console.log 'Project State ',state
    @pathCache = state['pathCache'] or {}
    @new = false
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @loading = new NavigateView()
    @modalPanel = atom.workspace.addModalPanel item:@loading.getElement(), visible:false
    @navi = {}
    atom.workspaceView.command 'navigate:back', 'atom-text-editor', =>@back()
    atom.workspaceView.command 'navigate:forward', 'atom-text-editor', =>
      @new = atom.config.get('navigate.dblclick')
      @forward()

    atom.workspaceView.command 'navigate:forward-new', 'atom-text-editor', =>
        @new = true
        @forward()
    atom.workspaceView.command 'navigate:refresh', 'atom-text-editor', =>@refresh()
    atom.workspace.observeTextEditors (editor)=>
      view = atom.views.getView(editor)
      view.ondblclick = =>
        @new = atom.config.get('navigate.dblclick')
        @forward()

  refresh: ->
    ed = atom.workspace.getActiveTextEditor()
    projectPath = atom.project.getPath()
    if text = ed?.getSelectedText()
      delete @pathCache[projectPath]?[text]
    else
      @pathCache[projectPath] = {}

  forward: ->
      editor = atom.workspaceView.getActivePaneItem()
      cursor = editor.cursors[0].getBufferPosition()
      startRange = new Range new Point(cursor.row,0), cursor
      editor.buffer.backwardsScanInRange /['|"]/g, startRange, (obj)=>
        @p1 = obj.range.start
        obj.stop()
      endRange = new Range cursor, new Point(cursor.row,Infinity)
      editor.scanInBufferRange /['|"]/g, endRange, (obj)=>
        @p2 = obj.range.end
        r1 = new Range(@p1,@p2)
        @uri = editor.getTextInBufferRange(r1)
        @uri = @uri.substr(1,@uri.length-2)
        return if @uri is editor.getPath()
        return unless @uri
        if @uri.indexOf('http') >= 0  or @uri.indexOf('https') > 0
        else
          fpath = path.dirname editor.getPath()
          ext = path.extname editor.getPath()
          url = fpath+'/'+@uri
          @modalPanel.show()
          projectPath = atom.project.getPath()
          fs.exists url, (exists)=>
            if exists
              @open([url],editor)
            else
              filename = path.basename(@uri)
              if ofname = @pathCache[projectPath]?[@uri]
                @open([ofname],editor)
              else
                globSearch = =>
                    glob "**/*#{filename}*",{cwd:projectPath,stat:false,nocase:true,nodir:true}, (err,files)=>
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
                try
                  @complex = true
                  unless path.extname filename
                    if filepath = resolve.sync(filename,basedir:projectPath)
                      if fs.statsSync filepath
                          @open([filepath],editor)
                          return

                  globSearch()
                catch e
                  console.log 'Error find the filepath',e
                  globSearch()


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
          projectPath = atom.project.getPath()
          ed.setCursorScreenPosition(url[1]) if url[1]
          @navi["#{ed.getPath()}"] = [editor.getPath(),editor.getCursorScreenPosition()] unless back
          if @complex
            @complex = false
            @pathCache[projectPath] or= {}
            @pathCache[projectPath][@uri] = ed.getPath() unless back
          @modalPanel.hide()
          if @new then @new = false else editor.destroy()

  back: ->
    editor = atom.workspaceView.getActivePaneItem()
    fpath = editor.getPath()
    return unless navi = @navi[fpath]
    delete @navi[fpath]
    @open(navi,editor,true)

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
    pathCache: @pathCache
  toggle: ->
