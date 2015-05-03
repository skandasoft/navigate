INSTALL  BROWSER-PLUS --> apm install browser-plus or check out in the packages

# Jump to any file/Back(f2/f3)

Jump to any file by dbl clicking(f2) on the file url/any word, even if it is not on the path and jump back(f3) with support for Node Modules. Simple!!!

Drill your way in to the file..any level !! and back

**Special support for npm modules..Jump straight to locally installed module by clicking on the require**

The package will keep track of navigations, which takes time and will jump immediately next time.

To Refresh its memory type navigate:refresh

if you just wanted to refresh a single path select the path and type navigate:refresh in the command window.


KeyPress
________

F2/DoubleClick to navigate forward to the file(uses same window).

F4 - To open in a new window.

F3 to navigate backward.

Navigate by double clicking and back on f3
![navigate](https://github.com/skandasoft/navigate/blob/master/navigate.gif?raw=true)

Open New window - f4
![new-window](https://github.com/skandasoft/navigate/blob/master/open-new-window.gif?raw=true)

Navigating into local node modules in the same window

![localnodemoudules](https://github.com/skandasoft/navigate/blob/master/nodemodules.gif?raw=true)

UPDATES
________

BrowserPlus has to be installed to take advantage of the new features
This package help in navigating/links to html file. when you press f2 on a html file it opens up the browser
The browser url can be provided added in the config against the keys. The default key combinations are now

'F1':
  title: 'F1 - Help'
  type: 'string'
  default: 'http://devdocs.io/#q=&searchterm'

'CTRL-F1':
  title: 'F1 - Help'
  type: 'string'
  default: 'https://www.google.com/search?q=&searchterm'

'CTRL-F2':
  title: 'Stack Overflow Search'
  type: 'string'
  default: 'http://stackoverflow.com/search?q=&searchterm'

'CTRL-F3':
  title: 'AtomIO Search'
  type: 'string'
  default: 'https://atom.io/docs/api/search/latest?q=&searchterm'

  Custom keys(CTRL-F4) can be added against custom url. The word under cursor is available in the search term. So Currently any help for the key words, are provided through devdocs.
  ![browser-plus](https://github.com/skandasoft/navigate/blob/master/help-browser-plus.gif?raw=true)
