# Navigate to any file/back(f2/f3) under cursor

Navigate to any file by double clicking(f2) on the file url/any word, even if it is not on the path and jump back(f3), with support for Node Modules. Simple!!!

Drill your way in to the file..any level !!! and back

**Special support for npm modules. Jump straight to locally installed module by clicking on the require**

The package will keep track of navigations, which takes time and will jump immediately next time.

To Refresh its memory  __navigate:refresh__

if you just wanted to refresh a single path select the path and type navigate:refresh in the command window.


### KeyMaps

F2/DoubleClick to navigate forward to the file(uses same window).

F3 to navigate backward.

Navigate by double clicking and back on f3

![navigate](https://github.com/skandasoft/navigate/blob/master/navigate.gif?raw=true)

F4 - To open in a new window.

![new-window](https://github.com/skandasoft/navigate/blob/master/open-new-window.gif?raw=true)

Navigating into local node modules in the same window

![localnodemoudules](https://github.com/skandasoft/navigate/blob/master/nodemodules.gif?raw=true)

__[BrowserPlus][1]__ has to be installed to take advantage of all features

This package help in navigating/links to html file. when you press f2 on a html file it opens up the browser/BrowserPlus

Navigating to custom url can been provided in the config against the set of keys.

The default key combinations are now

```javascript
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
```

*Ablity to add custom key map*

Custom keys(CTRL-F4) can be added against custom url. The word under cursor is available in the field searchterm. Currently any help for the words under cursor, are provided through devdocs.

![browser-plus](https://github.com/skandasoft/navigate/blob/master/help-browser-plus.gif?raw=true)

Maintain the custom key to custom url in any file in json format and save as .coffee file.

for eg.

``` coffee
module.exports =
  'f1': 'http://devdocs.io/#q=&searchterm'
```

**looks like the keymap has to be in lowercase in windows for it to work for some reason**

check lib\\keymap.coffee in this package for eg and its filepath is specified in the setting for the navigate package. Go to the "require" setting in the config and specify the file path.

File could be any where in the system for eg in windows if it is
> c:/keymap.coffee

update in settings for

>> "require" to c:/keymap.coffee

and this file could contain the same keymap as the default config.coffee keymap..
** your key map will be given the preference **

[1]: http://atom.io/packages/browser-plus
