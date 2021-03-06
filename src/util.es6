import { INJECTION_POINTS, REGEX } from './const'
import path from 'path'

export function camalize (str) {
  return str.split('_')
    .filter((s) => s.length > 0)
    .map((s, i) => i === 0 ? s : (s[0].toUpperCase() + s.substr(1)))
    .join('')
}

export function callsite () {
  function parse (t) {
    let [, functionName, alias, filePath, line, col] = REGEX.stack_trace.exec(t)
    let file = path.parse(filePath)

    line = parseInt(line)
    col = parseInt(col)

    return {
      functionName, alias,
      filePath, file,
      line, col
    }
  }
  let stack = new Error().stack
    .split('\n').slice(2) // First line is 'Error', second line is this function
    .map(parse)

  return stack
}
