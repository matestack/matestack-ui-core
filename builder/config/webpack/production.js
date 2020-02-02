process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

// Add `.min` to the production versions of the output files.
// https://github.com/matestack/matestack-ui-core/issues/343#issuecomment-580246554
// https://github.com/matestack/matestack-ui-core/issues/343#issuecomment-581149092
//
environment.config.set("output.filename", chunkData => {
  return "[name].min.js"
})
const miniCssExtractPlugin = environment.plugins.get('MiniCssExtract')
miniCssExtractPlugin.options.filename = "[name].min.css"


module.exports = environment.toWebpackConfig()
