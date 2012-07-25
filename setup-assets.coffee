path = require 'path'
hogan = require 'hogan.js'
assets = require 'connect-assets'

assets.jsCompilers.mustache =
  namespace: 'Templates'
  match: /\.js$/
  compileSync: (sourcePath, source) ->
    assetName = path.basename(sourcePath, '.mustache')
    compiled = hogan.compile(source, asString: true)
    "(function() { window.#{@namespace} = window.#{@namespace} || {};
     window.#{@namespace}['#{assetName}'] = #{compiled}; })();"

module.exports = assets
