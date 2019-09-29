process.env.NODE_ENV = process.env.NODE_ENV || 'development'

// const environment = require('./environment')
//
// const extractText = environment.plugins.get('ExtractText')
// extractText.filename = '[name].js'
//
// module.exports = environment.toWebpackConfig()

const merge = require('webpack-merge')
const environment = require('./environment')
const webpack = require('webpack')

const customConfig = {
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ],
  output: {
    filename: 'matestack-ui-core.js',
    libraryTarget: 'var',
    library: 'MatestackUiCore'
  }
};

const config = environment.toWebpackConfig();

module.exports = merge(environment.toWebpackConfig(), config, customConfig)
