#!/bin/bash

./node_modules/.bin/stylus \
	--use nib \
	--compress \
	--out build/development/css/main.css \
	src/stylus/main.styl 

INDEX_FILE=index.jsx

# Build React JS
node_modules/.bin/browserify src/$INDEX_FILE \
	--extension=.jsx \
	--external react \
	--standalone CharterPortaal \
	--transform [ babelify --plugins object-assign ] \
	--verbose > build/development/js/react-src.js
