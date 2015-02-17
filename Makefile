all:
	echo "Building metaserve..."
	coffee -o lib -c src
	coffee -o bin -c src/metaserve.coffee
	cp bin/metaserve.js bin/metaserve.js.tmp
	echo "#!/usr/bin/env node" > bin/metaserve.js.tmp
	cat bin/metaserve.js >> bin/metaserve.js.tmp
	mv bin/metaserve.js.tmp bin/metaserve.js

