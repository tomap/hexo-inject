export const INJECTION_POINTS = [
  'head_begin',
  'head_end',
  'body_begin',
  'body_end'
]

export const API = [
  'raw',
  'tag',
  'script',
  'style',
  'link',
  'require'
]

export const REGEX = {
  head_begin  : /([\s\S]*)(<head.*>)([\s\S]*)/i,
  body_begin  : /([\s\S]*)(<body.*>)([\s\S]*)/i,
  head_end    : /([\s\S]*)(<\/head>)([\s\S]*)/i,
  body_end    : /([\s\S]*)(<\/body>)([\s\S]*)/i
}
