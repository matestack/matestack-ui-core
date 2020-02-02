process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const merge = require('webpack-merge')
const environment = require('./environment')

const customConfig = {
  output: {
    filename: 'matestack-ui-core.min.js',
    libraryTarget: 'var',
    library: 'MatestackUiCore'
  }
};

const config = environment.toWebpackConfig();

module.exports = merge(environment.toWebpackConfig(), config, customConfig)
