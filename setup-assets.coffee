path = require 'path'
fs = require 'fs'
hogan = require 'hogan.js'
assets = require 'connect-assets'

fs.exists = fs.exists or path.exists
fs.existsSync = fs.existsSync or path.existsSync

assets.jsCompilers.mustache =
  namespace: 'Templates'
  match: /\.js$/
  compileSync: (sourcePath, source) ->
    assetName = path.basename(sourcePath, '.mustache')
    compiled = hogan.compile(source, asString: true)
    "(function() { window.#{@namespace} = window.#{@namespace} || {};
     window.#{@namespace}['#{assetName}'] = #{compiled}; })();"

module.exports = assets
