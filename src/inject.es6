import _ from "underscore"
import { mixins } from 'core-decorators'
import { Content, Register, Transform, Require } from './mixin'
import { INJECTION_POINTS, API } from './const'
import { camalize } from './util'


@mixins(Content, Register, Transform, Require)
export default class Inject {
  constructor (hexo) {
    this.hexo = hexo
    this._initAPI()
  }
  _initAPI () {
    this._injectors = {}
    INJECTION_POINTS.forEach((i) => {
      this._injectors[i] = []
      let api = this[camalize(i)] = _.chain(this)
        .pick(API)
        .mapObject((fn) => (...args) => {
          fn.call(this, i, ...args)
          return api
        })
        .value()
    })
  }
}
