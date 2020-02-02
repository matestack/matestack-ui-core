const { environment } = require('@rails/webpacker')

// Remove the digest from the output js filename.
// https://github.com/matestack/matestack-ui-core/issues/343#issuecomment-581149092
//
environment.config.set("output.filename", chunkData => {
  return "[name].js"
})

// Remove the digest from the output css filename.
// https://github.com/matestack/matestack-ui-core/issues/343#issuecomment-581149092
//
// Inspect with:
//
//     console.log(environment.plugins)
//
const miniCssExtractPlugin = environment.plugins.get('MiniCssExtract')
miniCssExtractPlugin.options.filename = "[name].css"

module.exports = environment
