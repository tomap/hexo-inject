import Promise from 'bluebird'
import _ from 'underscore'

const Transform = {
  async _resolveContent ({ html, opts }) {
    function resolve (o, ...args) {
      switch (typeof o) {
        case 'string':
          return o
        case 'function':
          return o(...args)
        default:
          throw new TypeError('Expect attributes or HTML to be a string or a function')
      }
    }
    html = resolve(html)
    let shouldInject = opts.shouldInject = resolve(opts.shouldInject)
    return await Promise.props({ html, shouldInject })
  },
  async _resolveInjectionPoint (pos) {
    return await Promise.map(this._injectors[pos], this._resolveContent.bind(this))
  },

  _transform (src, data) {
    // let { script } = this
    // let shouldInject =
    //   BODY_REGEX.test(src)          &&
    //   (
    //   src.indexOf(MATH_MARKER) >= 0 ||
    //   INLINE_MATH_REGEX.test(src)   ||
    //   BLOCK_MATH_REGEX.test(src)
    //   )
    // return shouldInject ? src.replace(INJECTION_REGEX, `$1${script.src}$2`)
    //                     : src
  }
}

export default Transform
