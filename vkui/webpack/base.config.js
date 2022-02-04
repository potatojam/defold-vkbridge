'use strict';

const webpack = require('webpack');
const path = require('path');
const rootPath = path.join(__dirname, '../');
const config = require(path.join(rootPath, 'package.json'));

module.exports = {
    entry: path.join(rootPath, 'ts/app.tsx'),
    plugins: [],
    module: {
        rules: [
            {
                test: /\.css$/i,
                use: ["style-loader", "css-loader"],
            },
            {
                test: /\.tsx?$/,
                use: 'ts-loader',
                exclude: /node_modules/
            },
        ],
    },
    resolve: {
        extensions: ['.tsx', '.ts', '.js'],
    },
    externals: {
        '@vkontakte/vk-bridge': 'vkBridge'
    },
};