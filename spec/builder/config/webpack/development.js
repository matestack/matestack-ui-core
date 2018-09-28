process.env.NODE_ENV = process.env.NODE_ENV || 'development'

// const environment = require('./environment')
//
// const extractText = environment.plugins.get('ExtractText')
// extractText.filename = '[name].js'
//
// module.exports = environment.toWebpackConfig()

const merge = require('webpack-merge')
const environment = require('./environment')

const customConfig = {
    output: {
        filename: 'basemate-ui-core.js'
    }
};

module.exports = merge(environment.toWebpackConfig(), customConfig)
