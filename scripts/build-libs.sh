#!/bin/bash

# Create dirs
rm -rf build/development
mkdir -p build/development/js
mkdir build/development/css

cp static/index.html build/development


# Bundle React libs
node_modules/.bin/browserify \
	--require classnames \
	--require react > build/development/js/react-libs.js

