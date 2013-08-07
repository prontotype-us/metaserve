#!/bin/sh

echo "Building metaserve..."
# Ugly hack to prepend shebang
coffee -o bin -c src
cp bin/metaserve.js bin/metaserve.js.tmp
echo "#!/usr/bin/env node" > bin/metaserve.js.tmp
cat bin/metaserve.js >> bin/metaserve.js.tmp
mv bin/metaserve.js.tmp bin/metaserve.js
