{ default: Node, Block, InjectionBlock, wrap } = require('../src/parser/node')

console.log(Node)

describe 'Node', ->
  foo = wrap('test', 'foo')
  bar = wrap('test', 'bar')
  baz = wrap('test', 'baz')
  it 'Node::firstChild', ->
    n = new Node()
    n.children.push(foo)
    n.children.push(bar)
    n.firstChild.should.equal(foo)
  it 'Node::firstChild - empty', ->
    n = new Node()
    expect(n.firstChild).to.be.null
  it 'Node::lastChild', ->
    n = new Node()
    n.children.push(foo)
    n.children.push(bar)
    n.lastChild.should.equal(bar)
  it 'Node::lastChild - empty', ->
    n = new Node()
    expect(n.lastChild).to.be.null
  it 'Block::injectBefore', ->
    n = new Block()
    i = new InjectionBlock()
    i.children.push(foo)
    n.children.push(i)
    n.children.push(foo)
    n.children.push(bar)
    n.injectBefore(baz)
    n.firstChild.type.should.equal('injection')
    n.firstChild.lastChild.should.deep.equal(wrap('injection_text', baz))
    n.validate().should.be.true
  it 'Block::injectBefore - no injection block', ->
    n = new Block()
    n.injectBefore(baz)
    n.firstChild.type.should.equal('injection')
    n.firstChild.lastChild.should.deep.equal(wrap('injection_text', baz))
    n.validate().should.be.true
  it 'Block::injectAfter', ->
    n = new Block()
    i = new InjectionBlock()
    i.children.push(foo)
    n.children.push(foo)
    n.children.push(bar)
    n.children.push(i)
    n.injectAfter(baz)
    n.lastChild.type.should.equal('injection')
    n.lastChild.lastChild.should.deep.equal(wrap('injection_text', baz))
    n.validate().should.be.true
  it 'Block::injectAfter - no injection block', ->
    n = new Block()
    n.injectAfter(baz)
    n.lastChild.type.should.equal('injection')
    n.lastChild.firstChild.should.deep.equal(wrap('injection_text', baz))
    n.validate().should.be.true
