'use strict';

const webpack = require('webpack');
const path = require('path');
const rootPath = path.join(__dirname, '../');
const config = require(path.join(rootPath, 'package.json'));

const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const ForkTsCheckerNotifierWebpackPlugin = require('fork-ts-checker-notifier-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin')

const baseConfig = require('./base.config.js');

module.exports = function () {
    let distConfig = baseConfig;
    // distConfig.devtool = 'inline-source-map';
    distConfig.mode = 'production';
    distConfig.output = {
        path: path.join(rootPath, '../vkbridge/res/web/'),
        filename: config.name + '.min.js',
        libraryTarget: 'var',
        library: 'App'
    };
    distConfig.plugins = distConfig.plugins.concat([
        new ForkTsCheckerWebpackPlugin({
            eslint: {
                files: path.join(rootPath, 'ts/**/*.{ts,tsx,js,jsx}')
            }
        }),
        new ForkTsCheckerNotifierWebpackPlugin({
            alwaysNotify: true
        }),
        new CleanWebpackPlugin()
    ]);
    distConfig.optimization = {
        minimizer: [
            new TerserPlugin(
                {
                    parallel: 4,
                    // sourceMap: false,
                    extractComments: false,
                    terserOptions: {
                        output: {
                            comments: false,
                        },
                        compress: {
                            pure_funcs: ['console.info', 'console.log', 'console.debug', 'console.warn']
                        }
                    }
                }
            )
        ],
    };
    return distConfig;
};