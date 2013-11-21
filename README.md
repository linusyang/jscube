JSCube
=====
Copyright (c) 2013 Linus Yang


Introduction
-----
A simple demo to draw 3D objects __pixel by pixel__ on 2D HTML5 canvas by only ultilizing `createImageData` and `putImageData` API. Simple anti-alising algorithm is added. Both mouse and touch screen events are supported.

Inspired by [Pre3d](https://github.com/deanm/pre3d) project, totally re-written in [CoffeeScript](http://coffeescript.org/). Web page is powered by [Bootstrap](http://getbootstrap.com/).

Please see the online demo: [linusyang.com/jscube](http://linusyang.com/jscube/).

Build
-----
Node.js is required for building from source.

```Bash
git clone https://github.com/linusyang/jscube.git
cd jscube
npm install .
npm run-script build
```

License
-----
Licensed under [GPLv3](http://www.gnu.org/copyleft/gpl.html).
