import { INJECTION_POINTS, REGEX } from '../const'
import { Block, Document } from './node'

var parser = null
export default class Parser {
  static get () {
    if (parser === null) parser = new Parser()
    return parser
  }
  _parseRules (src, ruleNames, defaultType = 'text') {
    ruleNames = ruleNames || INJECTION_POINTS
    let rules = ruleNames.map((i) => REGEX[i])

    let delta = 0
    let { tokens, text } = rules.reduce((context, r, i) => {
      let ruleName = ruleNames[i]
      let [rule, pos] = ruleName.split('_')
      let isEnd = pos === 'end'
      let m = r.exec(context.text)
      if (m) {
        delta++
        let tag = m[1]
        let offset = m.index
        let before = context.text.substr(0, offset)
        let remain = context.text.substr(offset + tag.length)
        context.text = remain
        if (before !== '') {
          context.tokens.push({
            type: isEnd ? `${rule}_text` : defaultType,
            content: before
          })
        }
        context.tokens.push({
          type: ruleName,
          content: tag
        })
      }
      return context
    }, { text: src, tokens: [] })

    if (text !== '') {
      if (delta === 0) {
        tokens.push({
          type: defaultType,
          content: text
        })
      } else {
        tokens = tokens.concat(this._parseRules(text, ruleNames, defaultType))
      }
    }
    return tokens
  }
  _tokenize (src) {
    let tokens = this._parseRules(src)

    const INJECTION_REGION = ['injection_begin', 'injection_end']

    let headIndex = tokens.findIndex((t) => t.type === 'head_text')
    this._expandToken(tokens, headIndex, INJECTION_REGION)

    let bodyIndex = tokens.findIndex((t) => t.type === 'body_text')
    this._expandToken(tokens, bodyIndex, INJECTION_REGION)

    return tokens
  }
  _expandToken (tokens, index, ruleNames) {
    if (index < 0) return
    let token = tokens[index]
    tokens.splice(index, 1, ...this._parseRules(token.content, ruleNames, token.type))
  }
  _reduceBlock (tokens) {
    let root = new Document()
    let stack = [ root ]

    function top () { return stack[stack.length - 1] }

    tokens.forEach((token) => {
      let [t, p] = token.type.split('_')
      switch (p) {
        case 'begin':
          stack.push(Block.make(t, token))
          break
        case 'end':
          let block = stack.pop()
          if (block.type !== t) throw new SyntaxError(`No matching '${t}_begin'`)
          block.end = token
          top().append(block)
          break
        default:
          top().append(token)
      }
    })

    if (stack.length > 1) throw new SyntaxError(`No matching '${top().type}_end'`)

    return root
  }
  parse (src) {
    let tokens = this._tokenize(src)

    let doc = this._reduceBlock(tokens)

    return doc
  }
}
