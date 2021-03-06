{ default: Node, Block, InjectionBlock, wrap } = require('../src/parser/node')

describe 'Node', ->
  foo = wrap('test', 'foo')
  bar = wrap('test', 'bar')
  baz = wrap('test', 'baz')
  it 'Node::firstChild', ->
    n = new Node()
    n.append(foo)
    n.append(bar)
    n.firstChild.should.equal(foo)
  it 'Node::firstChild - empty', ->
    n = new Node()
    expect(n.firstChild).to.be.null
  it 'Node::lastChild', ->
    n = new Node()
    n.append(foo)
    n.append(bar)
    n.lastChild.should.equal(bar)
  it 'Node::lastChild - empty', ->
    n = new Node()
    expect(n.lastChild).to.be.null
  it 'Block::injectBefore', ->
    n = new Block()
    i = new InjectionBlock()
    i.append(foo)
    n.append(i)
    n.append(foo)
    n.append(bar)
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
    i.append(foo)
    n.append(foo)
    n.append(bar)
    n.append(i)
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
  it 'InjectionBlock::injectBefore - ensure children uniqueness', ->
    i = new InjectionBlock()
    i.injectBefore(foo)
    i.injectBefore(bar)
    i.injectBefore(foo)
    i.injectBefore(baz)
    i.injectBefore(bar)
    i.children.should.deep.equal([baz, bar, foo].map(wrap.bind(null, 'injection_text')))
  it 'InjectionBlock::injectAfter - ensure children uniqueness', ->
    i = new InjectionBlock()
    i.injectAfter(foo)
    i.injectAfter(bar)
    i.injectAfter(foo)
    i.injectAfter(baz)
    i.injectAfter(bar)
    i.children.should.deep.equal([foo, bar, baz].map(wrap.bind(null, 'injection_text')))
