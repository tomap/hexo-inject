import { INJECTION_POINTS, REGEX } from './const'

export function camalize (str) {
  return str.split('_')
    .filter((s) => s.length > 0)
    .map((s, i) => i === 0 ? s : (s[0].toUpperCase() + s.substr(1)))
    .join('')
}
