Inject = require('../src/inject')
sinon = require('sinon')
Parser = require('../src/parser')

describe 'Transform', ->
  mock_hexo =
    log:
      warn: sinon.stub()
      debug: sinon.stub()
      error: sinon.stub()

  inject = new Inject(mock_hexo)

  partial = """\
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title></title>
      </head>
    """

  html = """\
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title></title>
      </head>
      <body class='some-class'>
        <div>body and stuff</div>
      </body>
    </html>
    """

  injected = """\
    <!DOCTYPE html>
    <html>
      <head>
        <!-- hexo-inject:begin --><link src='foo/style.css'><!-- hexo-inject:end -->\
      <meta charset="utf-8">
        <title></title>\
      <!-- hexo-inject:begin --><script src='foo/head-script.js'></script><!-- hexo-inject:end -->
      </head>
      <body class='some-class'>
        <!-- hexo-inject:begin --><h1 class='foo-h1'>heading</h1><!-- hexo-inject:end -->\
      <div>body and stuff</div>\
      <!-- hexo-inject:begin --><script type='test/foo'>this is in body</script><!-- hexo-inject:end -->
      </body>
    </html>
    """

  before ->
    inject.headBegin.link(src: 'foo/style.css')
    inject.headEnd.script(src: 'foo/head-script.js')
    inject.bodyBegin.tag('h1', class: 'foo-h1', 'heading', true)
    inject.bodyEnd.script(type: 'test/foo', 'this is in body')

  it 'should transform complete HTML', ->
    inject._transform(html, source: 'test')
      .should.eventually.equal(injected)

  it 'should not transform incomplete HTML', ->
    inject._transform(partial, source: 'test-partial')
      .should.equal(partial)
    mock_hexo.log.debug.calledTwice.should.be.true
    mock_hexo.log.debug.calledWithMatch('[hexo-inject] SKIP: test-partial').should.be.true

  it 'should overwrite existing injeciton blocks', ->
    parser = new Parser()
    inject._transform(injected, source: 'test')
      .should.eventually.equal(injected)
