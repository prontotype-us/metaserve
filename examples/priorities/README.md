This example uses two metaserve modules for rendering HTML: `metaserve-html-mustache`, `metaserve-html-jade`. The server uses both modules but prioritizes Mustache over Jade so that if a `.mustache` file exists it will be used, otherwise if a `.jade` file exists it will be used, otherwise a raw `.html` file will be used.

In this directory (`metaserve/examples/priorities/`), run `coffee server.coffee` (metaserve should be installed as a module with `npm install metaserve`).

