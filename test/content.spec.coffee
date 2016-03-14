Inject = require('../src/inject')
Promise = require('bluebird')
_ = require('underscore')
sinon = require('sinon')

describe 'Content', ->
  inject = new Inject()

  describe 'tag', ->
    src = 'foo bar baz'
    it '._buildHTMLTag - link', ->
      css_attrs =
        src: '/foo/bar.css'
        'data-foo': (s) ->
          s.should.equal(src)
          'foo'
        'data-bar': Promise.resolve('bar').delay(1000)
      inject._buildHTMLTag('link', css_attrs, null, false, src)
        .should.eventually.equal("<link src='/foo/bar.css' data-foo='foo' data-bar='bar'>")
    it '._buildHTMLTag - script', ->
      js_attrs =
        type: 'text/foo-config'
        'data-foo': (s) ->
          s.should.equal(src)
          'foo'
        'data-bar': Promise.resolve('bar').delay(1000)
      content = 'var foo = {}'

      getContent = (s) ->
        s.should.equal(src)
        content

      inject._buildHTMLTag('script', js_attrs, getContent, true, src)
        .should.eventually.equal("<script type='text/foo-config' data-foo='foo' data-bar='bar'>#{content}</script>")

  describe 'resolve', ->
    src = 'foo bar baz'
    it 'sync', ->
      content =
        html: 'html content'
        opts:
          shouldInject: false
      inject._resolveContent(src, content).should.eventually.deep.equal({
        html: content.html
        shouldInject: false
      })
      inject._resolveContent(src, _.omit(content, 'opts')).should.eventually.deep.equal({
        html: content.html
        shouldInject: true
      })
    it 'async - function', ->
      content =
        html: (s) ->
          s.should.equal(src)
          Promise.resolve('html content').delay(1000)
        opts:
          shouldInject: (s) ->
            s.should.equal(src)
            false
      inject._resolveContent(src, content).should.eventually.deep.equal({
        html: 'html content'
        shouldInject: false
      })
    it 'async - promise', ->
      content =
        html: Promise.resolve('html content').delay(1000)
        opts:
          shouldInject: Promise.resolve(false).delay(300)
      inject._resolveContent(src, content).should.eventually.deep.equal({
        html: 'html content'
        shouldInject: false
      })
