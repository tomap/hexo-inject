import _ from 'underscore'

export function wrap(type, content) {
  // If content is another token, clone it and change the type
  if (_.isObject(content) && _.isString(content.type)) {
    content = _.clone(content)
    content.type = type
    return content
  }
  // Wrap as token
  return {
    type,
    content
  }
}

export default class Node {
  constructor (type) {
    this.type = type
    this.children = []
  }
  get content () {
    return this.children.map((c) => c.content).join('')
  }
  get firstChild () {
    return this.children.length === 0 ? null : this.children[0]
  }
  get lastChild () {
    return this.children.length === 0 ? null : this.children[this.children.length - 1]
  }
}

export class Block extends Node {
  static make (type, begin, end) {
    let T = Block.TYPES[type]
    return T ? new T(begin, end) : new Block(type, begin, end)
  }
  constructor (type, begin, end) {
    super(type || 'block')
    this.begin = begin
    this.end = end
  }
  get content () {
    return this.begin.content + super.content + this.end.content
  }
  validate () {
    if (this.children.length <= 2) return true
    for (var i = 1; i < this.children.length - 1; i++) {
      if (this.children[i].type === 'injection') return false
    }
    return true
  }
  injectBefore (content) {
    let firstChild = this.firstChild
    if (firstChild === null || firstChild.type !== 'injection') {
      firstChild = new InjectionBlock()
      this.children.unshift(firstChild)
    }
    firstChild.injectAfter(content)
  }
  injectAfter (content) {
    let lastChild = this.lastChild
    if (lastChild === null || lastChild.type !== 'injection') {
      lastChild = new InjectionBlock()
      this.children.push(lastChild)
    }
    lastChild.injectAfter(content)
  }
}

const INJECTION_BEGIN = wrap('injection_begin', '<!-- hexo-inject:begin -->')
const INJECTION_END =   wrap('injection_end'  , '<!-- hexo-inject:end -->')
export class InjectionBlock extends Block {
  constructor (begin = INJECTION_BEGIN, end = INJECTION_END) {
    super('injection', begin, end)
  }
  injectBefore (content) {
    this.children.unshift(wrap('injection_text', content))
  }
  injectAfter (content) {
    this.children.push(wrap('injection_text', content))
  }
}

Block.TYPES = {
  'injection': InjectionBlock
}

export class Document extends Node {
  constructor () {
    super('document')
  }
  get head () {
    return this.children.find(({ type }) => type === 'head')
  }
  get body () {
    return this.children.find(({ type }) => type === 'body')
  }
  get isComplete() {
    return typeof this.head === 'object' && typeof this.body === 'object'
  }
}
