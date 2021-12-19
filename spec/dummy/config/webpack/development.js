process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const { merge } = require('webpack-merge');
const environment = require('./environment')

const customWebpackConfig = {
  resolve: {
    alias: {
      vue: '@vue/compat/dist/vue.esm-browser'
    }
  },
  module: {
    rules: [
      {
        test: /\.vue$/,
        loader: 'vue-loader',
        options: {
          compilerOptions: {
            compatConfig: {
              MODE: 2
            }
          }
        }
      }
    ]
  }
}

module.exports = merge(environment.toWebpackConfig(), customWebpackConfig)
