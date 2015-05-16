module.exports =

  newwindow:
    title: 'New Window'
    type: 'boolean'
    default: false
  dblclk:
    title: 'Double Click'
    type: 'boolean'
    default: false
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

  basedir:
    title: 'Base Directory'
    type: 'array'
    default:['/public/']

  ignore:
    title: 'Ignore Pattern/Files(glob Pattern)'
    type: 'array'
    default: '**/*.css'
