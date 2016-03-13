import { INJECTION_POINTS, REGEX } from './const'

export function camalize (str) {
  return str.split('_')
    .filter((s) => s.length > 0)
    .map((s, i) => i === 0 ? s : (s[0].toUpperCase() + s.substr(1)))
    .join('')
}

export function parse (src) {
  let rules = INJECTION_POINTS.map((i) => REGEX[i])
  let { tokens } = rules.reduce((context, r) => {
    let [m, before, tag, remain] = r.exec(src)
    if (m) {
      context.text = remain
      context.tokens.push(before)
      context.tokens.push(tag)
    }
    return contex
  })
  return tokens
}
