all:
	echo "Building metaserve..."
	coffee -o lib -c src
	cp lib/metaserve.js lib/metaserve.js.tmp
	echo "#!/usr/bin/env node" > lib/metaserve.js.tmp
	cat lib/metaserve.js >> lib/metaserve.js.tmp
	mv lib/metaserve.js.tmp lib/metaserve.js

