const Register = {
  register () {
    let { filter } = this.hexo.extend
    this.hexo.inject = this
    filter.register("after_render:html", this._transform.bind(this))
    filter.register("after_init", this._filterPolyfill.bind(this))
  },
  _filterPolyfill () {
    let { hexo } = this,
      { log, extend } = hexo,
      { renderer } = extend,
      [major, minor, patch] = hexo.version.split(".").map((v) => parseInt(v))

    // Hotfix for hexojs/hexo#1791
    if (major == 3 && minor == 2) {
      log.info(`[hexo-inject] installing hotfix for hexojs/hexo#1791`)
      _.each(renderer.list(), (r, name) => {
        let { compile } = r,
          self = this
        if (typeof compile !== 'function') return
        log.info(`[hexo-inject] after_render polyfill for renderer '${name}'`)
        r._rawCompile = compile.bind(r)
        r.compile = function(data) {
          let c = r._rawCompile(data)
          return function(locals) {
            let src = c(locals)
            return self._transform(src)
          }
        }
      })
    }
  }
}

export default Register
