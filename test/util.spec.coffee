{ camalize, callsite } = require('../src/util')

describe "Util", ->
  it ".camalize", ->
    camalize('foo_bar').should.equal('fooBar')
    camalize('foo___bar').should.equal('fooBar')
    camalize('_').should.equal('')

  it ".callsite", ->
    cs = callsite()
    cs.should.be.an('array').of.length.above(0)
    # First stack trace should be this function
    cs[0].filePath.should.equal(__filename)
    cs.forEach (s) ->
      s.filePath.should.be.a('string').that.is.not.empty
      s.file.should.be.an('object')
      s.line.should.be.a('number')
      s.col.should.be.a('number')
