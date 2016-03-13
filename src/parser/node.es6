export default class Node {
  constructor (type) {
    this.type = type
    this.children = []
  }
  get content () {
    return this.children.map((c) => c.content).join('')
  }
}

export class Block extends Node {
  constructor (type, begin, end) {
    super(type || 'block')
    this.begin = begin
    this.end = end
  }
  get content () {
    return this.begin.content + super.content + this.end.content
  }
  injectBefore (content) {

  }
  injectAfter (content) {

  }
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
