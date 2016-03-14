Inject = require('../src/inject')
Promise = require('bluebird')
_ = require('underscore')
sinon = require('sinon')

describe 'Content', ->
  inject = new Inject()

  describe 'tag', ->
    it '._buildHTMLTag - link', ->
      css_attrs =
        src: '/foo/bar.css'
        'data-foo': -> 'foo'
        'data-bar': Promise.resolve('bar').delay(1000)
      inject._buildHTMLTag('link', css_attrs, null, false)
        .should.eventually.equal("<link src='/foo/bar.css' data-foo='foo' data-bar='bar'>")
    it '._buildHTMLTag - script', ->
      js_attrs =
        type: 'text/foo-config'
        'data-foo': -> 'foo'
        'data-bar': Promise.resolve('bar').delay(1000)
      content = 'var foo = {}'

      getContent = -> content

      inject._buildHTMLTag('script', js_attrs, getContent, true)
        .should.eventually.equal("<script type='text/foo-config' data-foo='foo' data-bar='bar'>#{content}</script>")

  describe 'resolve', ->
    it 'sync', ->
      content =
        html: 'html content'
        opts:
          shouldInject: false
      inject._resolveContent(content).should.eventually.deep.equal({
        html: content.html
        shouldInject: false
      })
      inject._resolveContent(_.omit(content, 'opts')).should.eventually.deep.equal({
        html: content.html
        shouldInject: true
      })
    it 'async - function', ->
      content =
        html: -> Promise.resolve('html content').delay(1000)
        opts:
          shouldInject: -> false
      inject._resolveContent(content).should.eventually.deep.equal({
        html: 'html content'
        shouldInject: false
      })
    it 'async - promise', ->
      content =
        html: Promise.resolve('html content').delay(1000)
        opts:
          shouldInject: Promise.resolve(false).delay(300)
      inject._resolveContent(content).should.eventually.deep.equal({
        html: 'html content'
        shouldInject: false
      })
