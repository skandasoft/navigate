{CompositeDisposable,Point, Range} = require 'atom'
path = require 'path'
fs = require 'fs'
findup = require 'findup-sync'
glob = require 'glob'
Fuse = require 'fuse.js'
NavigateView = require './navigate-view'
module.exports =
  navigateView: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
    @loading = new NavigateView()
    @modalPanel = atom.workspace.addModalPanel item:@loading.getElement(), visible:false
    @navi = {}
    atom.workspaceView.command 'navigate:back', 'atom-text-editor', =>@back()
    atom.workspaceView.command 'navigate:forward', 'atom-text-editor', =>@forward()
    atom.workspace.observeTextEditors (editor)=>
      view = atom.views.getView(editor)
      view.ondblclick = =>@forward()

  forward: ->
      @modalPanel.show()
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
        uri = editor.getTextInBufferRange(r1)
        uri = uri.substr(1,uri.length-2)
        return if uri is editor.getPath()
        return unless uri
        if uri.indexOf('http') >= 0  or uri.indexOf('https') > 0
        else
          fpath = path.dirname editor.getPath()
          ext = path.extname editor.getPath()
          url = fpath+'/'+uri
          fs.exists url, (exists)=>
            if exists
              @open([url],editor)
            else
              filename = path.basename(uri)
              glob "**/*#{filename}*",{cwd:atom.project.path,stat:false,nocase:true,nodir:true}, (err,files)=>
                if err or not files.length
                  fpaths = findup filename,{cwd:atom.project.path,nocase:true}
                  if fpaths
                    @matchFile(uri,ext,fpaths,editor)
                  else

                else
                  @matchFile(uri,ext,files,editor)
  matchFile: (filename,ext,files,editor)->
        if typeof files is 'string'
          @open([files],editor)
        else
          if filename in files
            @open([filename],editor)
          else
            if fname = filename+ext in files
              @open([fname],editor)
            else
              fuse = new Fuse files
              result = fuse.search(filename)[0]
              @open([files[result]],editor)

  open: (uri,editor,back=false)->
      atom.workspace.open uri[0]
        .then (ed)=>
          ed.setCursorScreenPosition(uri[1]) if uri[1]
          @navi["#{ed.getPath()}"] = [editor.getPath(),editor.getCursorScreenPosition()] unless back
          @modalPanel.hide()
          # editor.destroy()

  back: ->
    editor = atom.workspaceView.getActivePaneItem()
    fpath = editor.getPath()
    return unless navi = @navi[fpath]
    delete @navi[fpath]
    @open(navi,editor,true)

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  toggle: ->
