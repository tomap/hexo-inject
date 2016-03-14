export const INJECTION_POINTS = [
  'head_begin',
  'head_end',
  'body_begin',
  'body_end'
]

export const REGEX = {
  head_begin        : /([\s\S]*?)(<head.*>[\n\r\s\t]*)([\s\S]*)/i,
  head_end          : /([\s\S]*?)([\n\r\s\t]*<\/head>)([\s\S]*)/i,
  body_begin        : /([\s\S]*?)(<body.*>[\n\r\s\t]*)([\s\S]*)/i,
  body_end          : /([\s\S]*?)([\n\r\s\t]*<\/body>)([\s\S]*)/i,
  injection_begin   : /([\s\S]*?)(<!-- hexo-inject:begin -->)([\s\S]*)/i,
  injection_end     : /([\s\S]*?)(<!-- hexo-inject:end -->)([\s\S]*)/i
}

export const API = [
  'raw',
  'tag',
  'script',
  'style',
  'link',
  'require'
]
