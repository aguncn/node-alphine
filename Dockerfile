FROM alpine:3.8

ENV NODE_VERSION 6.3.1

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        binutils-gold \
        curl \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    56730D5401028683275BD23C23EFEFE93C4CFFFE \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) \
    && make install \
    && apk del .build-deps \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN cat << EOF >/tmp/package.json
{
    "name": "panode",
    "version": "1.0.0",
    "description": "A Nodejs SFB(Separation of Front and Back ends) framework, build with koa 2.x",
    "main": "./src/app.js",
    "directories": {
        "test": "test"
    },
    "scripts": {
        "test": "mocha",
        "dev": "./node_modules/.bin/nodemon bin/server.js",
        "forever": "./node_modules/.bin/forever start --uid nodeActivity -l forever.log -o ../../log/forever/out.log -e ../../log/forever/err.log -w -a server.js",
        "forever-list": "./node_modules/.bin/forever list",
        "forever-stop": "./node_modules/.bin/forever stop nodeActivity"
    },
    "repository": {
        "type": "git",
        "url": ""
    },
    "keywords": [
        "koa",
        "koajs",
        "panode"
    ],
    "author": "liuyongming",
    "license": "MIT",
    "bugs": {
        "url": ""
    },
    "homepage": "",
    "dependencies": {
        "bluebird": "3.4.6",
        "bytes": "^2.4.0",
        "co": "^4.6.0",
        "co-body": "^4.2.0",
        "compressible": "^2.0.8",
        "copy-to": "^2.0.1",
        "formidable": "^1.0.17",
        "grace-consolidate": "^0.14.3",
        "http-errors": "^1.5.0",
        "koa": "^2.0.0-alpha.7",
        "koa-compose": "^3.1.0",
        "koa-generic-session": "^1.11.3",
        "koa-is-json": "^1.0.0",
        "koa-send": "^3.2.0",
        "koa-socket": "^4.4.0",
        "lodash": "^4.17.4",
        "methods": "^1.1.2",
        "mongoose": "^4.6.3",
        "net": "^1.0.2",
        "path-to-regexp": "^1.6.0",
        "protobufjs": "^6.1.1",
        "raven": "^0.12.1",
        "request": "^2.75.0",
        "socket.io": "^1.7.2",
        "statuses": "^1.3.0",
        "strip-json-comments": "^2.0.1",
        "swiger": "0.0.2"
    },
    "devDependencies": {
        "babel-plugin-syntax-async-functions": "^6.13.0",
        "babel-plugin-syntax-decorators": "^6.13.0",
        "babel-plugin-transform-async-to-generator": "^6.16.0",
        "babel-plugin-transform-decorators-legacy": "^1.3.4",
        "babel-plugin-transform-runtime": "^6.15.0",
        "babel-polyfill": "^6.20.0",
        "babel-preset-es2015-node5": "^1.2.0",
        "babel-preset-es2015-node6": "^0.4.0",
        "babel-preset-stage-0": "^6.16.0",
        "babel-register": "^6.16.3",
        "cryptico": "^1.0.2",
        "crypto-js": "^3.1.9-1",
        "forever": "^0.15.3",
        "formidable": "^1.1.1",
        "ioredis": "^2.4.3",
        "koa-session2": "^2.2.4",
        "koa-uploadify": "^1.0.3",
        "log4js": "^1.0.1",
        "mm": "^2.0.0",
        "mocha": "^3.1.0",
        "mysql": "^2.13.0",
        "node-xlsx": "^0.7.4",
        "nodemon": "^1.10.2",
        "postal": "^2.0.5",
        "should": "^11.1.0",
        "supertest": "^2.0.0",
        "underscore": "^1.8.3"
    }
}
EOF &&cd /tmp/ &&npm install &&npm install pm2@latest -g

CMD [ "node" ]
