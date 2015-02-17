This example uses a bunch of different metaserve modules to compile different sorts of CSS, Javascript and HTML files.

Running this one requires:

* `metaserve-html-jade`
* `metaserve-html-mustache`
* `metaserve-css-styl`
* `metaserve-js-coffee`
* `metaserve-js-browserify-coffee-jsx`
* `metaserve-bouncer`
* `react`
* `jquery`

Install them all at once with `npm install metaserve-html-jade metaserve-html-mustache metaserve-css-styl metaserve-js-coffee metaserve-js-browserify-coffee-jsx metaserve-bouncer react jquery`

In this directory (`metaserve/examples/full/`), run `coffee server.coffee` (metaserve should be installed as a module with `npm install metaserve`). If you then navigate to [localhost:8000](http://localhost:8000/) the result should look like this:

![screenshot](https://github.com/prontotype-us/metaserve/blob/master/examples/full/screenshot.png?raw=true)
