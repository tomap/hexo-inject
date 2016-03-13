import 'babel-polyfill'
import Promise from 'bluebird'

const Content = {
  raw (pos, html, opts) {
    this._injectors[pos].push({ html, opts })
  },
  tag (pos, name, attrs, content, opts = { endTag: true }) {
    async function getHtml() {
      let [ attrs, content ] = await Promise.all([
        Promise.props(attrs),
        content
      ])
      let attr_list = _.map(attrs, (value, key) => `${key}='${value}'`).join(' ')
      let html = `<${name} ${attr_list}>${opts.endTag ? `${content}</${name}>`: ''}`
      return html
    }
    return this.raw(pos, getHtml, opts)
  },
  script (pos, attrs, content, opts) {
    return this.tag(pos, 'script', attrs, content, _.extend(opts, { endTag: true }))
  },
  style (pos, attrs, content, opts) {
    return this.tag(pos, 'style', attrs, content, _.extend(opts, { endTag: true }))
  },
  link (pos, attrs, opts) {
    return this.tag(pos, 'link', attrs, "", _.extend(opts, { endTag: false }))
  }
}

export default Content
