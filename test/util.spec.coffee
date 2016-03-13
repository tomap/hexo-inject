{ camalize } = require('../src/util')

describe "Util", ->
  it ".camalize", ->
    camalize('foo_bar').should.equal('fooBar')
    camalize('foo___bar').should.equal('fooBar')
    camalize('_').should.equal('')
