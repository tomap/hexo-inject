Inject = require('../src/inject')
sinon = require('sinon')
path = require('path')
_ = require('underscore')

describe 'Require', ->
  hexo = new Hexo(__dirname)
  inject = new Inject(hexo)

  beforeEach ->
    sinon.stub(inject, 'raw')
  afterEach ->
    inject.raw.restore()

  swig_asset = './asset/foo.swig'
  js_asset = './asset/foo.js'
  css_asset = './asset/foo.css'

  mock_module = (p, content) ->
    m_path = path.resolve(__dirname, p)
    m = path.parse(m_path)
    m.filePath = m_path
    if content?
      m.content = content
    m

  it 'should resolve module path from callsite', ->
    sinon.stub(inject, '_loadModule')
    m = mock_module(js_asset)
    try
      inject.require('test', js_asset)
      inject.headBegin.require(js_asset)
      inject._loadModule.calledTwice.should.be.true
      m1 = inject._loadModule.getCall(0).args[0]
      m2 = inject._loadModule.getCall(1).args[0]
      m1.should.deep.equal(m)
      m1.should.deep.equal(m2)

    catch error
      throw error
    finally
      inject._loadModule.restore()

  describe 'render', ->

    before -> hexo.init()

    it 'should render content with hexo renderer', ->
      m = mock_module(swig_asset)
      inject._loadModule(m, { inline: true, data: { test: 'foo' } })
        .should.eventually.equal('this is a foo\n')

    it 'should replace module extension name with output\'s', ->
      m = mock_module(swig_asset)
      inject._loadModule(m, { inline: true, data: { test: 'foo' } })
        .then ->
          m.ext.should.equal('.html')

    it 'should delay render if opts.inline == false', ->
      m = mock_module(swig_asset)
      inject._loadModule(m, { inline: false, data: { test: 'foo' } })
        .should.eventually.equal('')
        .then () ->
          route_data = inject.router._routes[0].data
          route_data.should.be.a('function')
          route_data()
        .should.eventually.equal('this is a foo\n')

  describe 'loader', ->
    it 'should returns as-is if not available', ->
      m = mock_module(swig_asset, 'foo content')
      inject.loader.load(m, inline: true)
        .should.eventually.equal('foo content')

    it 'should should have empty content if opts.inline == false', ->
      m = mock_module(swig_asset, 'foo content')
      inject.loader.load(m, inline: false)
        .should.eventually.equal('')

    it 'built-in .js loader opts.inline == true', ->
      m = mock_module(js_asset, 'var foo = 1;')
      inject.loader.load(m, inline: true)
        .should.eventually.equal('<script>var foo = 1;</script>')

    it 'built-in .js loader opts.inline == false', ->
      m = mock_module(js_asset, 'var foo = 1;')
      opts =
        inline: false
        src: '/injected/foo.js'
      inject.loader.load(m, opts)
        .should.eventually.equal("<script src='#{opts.src}'></script>")

    it 'built-in .css loader opts.inline == true', ->
      m = mock_module(css_asset, 'body { display: none; }')
      inject.loader.load(m, inline: true)
        .should.eventually.equal('<style>body { display: none; }</style>')

    it 'built-in .css loader opts.inline == false', ->
      m = mock_module(css_asset, 'body { display: none; }')
      opts =
        inline: false
        src: '/injected/foo.css'
      inject.loader.load(m, opts)
        .should.eventually.equal("<link rel='stylesheet' href='#{opts.src}'>")

    it 'custom loader', ->
      inject.loader.register('.foo', (content, opts) -> "FOO #{content} OOF")
      m = mock_module('./asset/foo.foo', 'bar')
      inject.loader.load(m, inline: true)
        .should.eventually.equal('FOO bar OOF')


  describe 'serve', ->
    beforeEach -> inject.router._routes = []
    it 'should serve when opts.inline == false', ->
      m = mock_module(swig_asset)
      inject._loadModule(m, { inline: false, data: { test: 'foo' } })
        .should.eventually.equal('')
        .then () ->
          inject.router._routes.should.be.an('array').of.length(1)
          route = inject.router._routes[0]
          route.path.should.equal('/injected/foo.html')
          route_data = route.data
          route_data.should.be.a('function')
          route_data()
        .should.eventually.equal('this is a foo\n')

    it 'should not serve when opts.inline == true', ->
      m = mock_module(swig_asset)
      inject._loadModule(m, { inline: true, data: { test: 'foo' } })
        .then () ->
          inject.router._routes.should.be.an('array').of.length(0)
