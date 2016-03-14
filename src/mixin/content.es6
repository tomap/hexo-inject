import 'babel-polyfill'
import _ from 'underscore'
import Promise from 'bluebird'

function resolve (o, ...args) {
  if (typeof o === 'function') return o(...args)
  return o
}

const Content = {
  async _resolveContent ({ html, opts }) {
    opts = opts || { shouldInject: true }
    html = resolve(html)
    let shouldInject = resolve(opts.shouldInject)
    return await Promise.props({ html, shouldInject })
  },
  async _resolveInjectionPoint (pos) {
    return await Promise.map(this._injectors[pos], this._resolveContent.bind(this))
  },
  async _buildHTMLTag (name, attrs, content, endTag) {
    [ attrs, content ] = await Promise.all([
      Promise.props(_.mapObject(attrs, (value) => resolve(value))),
      resolve(content || '')
    ])
    let attr_list = _.map(attrs, (value, key) => `${key}='${value}'`).join(' ')
    let html = `<${name} ${attr_list}>${endTag ? `${content}</${name}>`: ''}`
    return html
  },
  raw (pos, html, opts) {
    this._injectors[pos].push({ html, opts })
  },
  tag (pos, name, attrs, content, endTag, opts) {
    return this.raw(pos, this._buildHTMLTag.bind(this, name, attrs, content, endTag), opts)
  },
  script (pos, attrs, content, opts) {
    return this.tag(pos, 'script', attrs, content, true, opts)
  },
  style (pos, attrs, content, opts) {
    return this.tag(pos, 'style', attrs, content, true, opts)
  },
  link (pos, attrs, opts) {
    return this.tag(pos, 'link', attrs, "", false, opts)
  }
}

export default Content
