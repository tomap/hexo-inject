import Inject from './inject'
import patch from './patch'

patch(hexo)
new Inject(hexo).register()
