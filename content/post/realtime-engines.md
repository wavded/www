---
commentURL: ""
date: 2013-11-14T14:33:02-06:00
strongloopURL: http://strongloop.com/strongblog/real-time-engines-in-node-js
tags: ["nodejs", "websocket"]
title: Real-time Engines in Node
---

Node arrived on the scene around the time the WebSocket protocol was drafted. Node’s fast, evented approach to server-side programming was a perfect pairing for WebSocket. Out of that marriage emerged the popular [socket.io framework](http://socket.io/): an instant favorite used heavily in the first [Node Knockout](http://nodeknockout.com/) competition.

Now that WebSocket is [mature](http://tools.ietf.org/html/rfc6455) and has support in [all the modern desktop browsers](http://caniuse.com/#search=websocket) and most mobile platforms, the dust has settled a bit. Let’s take a look at what’s available in Node for WebSocket.

## The WebSocket module ecosystem

{{< figure src="/_media/ws-ecosystem.png" title="The layers of real-time engines" >}}

WebSocket modules can be divided up into three categories. The first are _protocol implementations_ (drivers) which focus on high performance of and standards compliance to the WebSocket protocol. Like the http module, they provide a low-level implementation.

WebSocket _emulators_ build on the protocol implementations by adding fallback WebSocket-like functionality using transports like XHR long-polling or htmlfile. These modules exist as a compatibility layer to enable real-time for browsers or networks that do support WebSocket.

Lastly, there are _high-level_ modules which build on the emulation layer with conveniences such as broadcast messages, channels, rooms, and custom event emitters.

> The intention of this article is not to provide an exhaustive list of all modules existing in Node space as there are simply [too many to cover](https://npmjs.org/search?q=websocket). However, if there is one I missed that will add to the discussion, please make a comment!

## The WebSocket Protocol implementations

Drivers implement the core WebSocket functionality by providing both server and client interfaces. Typically, they are not used directly. However, if you know your environment has reliable WebSocket support (as there is no falling back), drivers provide a nice minimal surface to build on.

Here are some popular drivers:

### Module: ws

The [ws](https://github.com/einaros/ws) module backs the popular socket.io framework. It boasts the fastest compliant implementation of WebSocket and includes a helpful wscat command line tool for debugging WebSocket servers. It requires compilation of native add-ons.

### Module: faye-websocket

The [faye-websocket](https://github.com/faye/faye-websocket-node) module is a pure JavaScript implementation that backs the popular sockjs framework. In addition to a WebSocket driver, it also includes an [EventSource](http://www.w3.org/TR/eventsource/#the-eventsource-interface) implementation for when you only need server-sent events. The WebSocket driver has been broken out into a separate [module](https://github.com/faye/websocket-driver-node), and provides a neat streaming API.

### Module: websocket

The [websocket](https://github.com/faye/websocket-driver-node) module is another popular implementation that has existed for a while. It is fast and can be run without native module compilation (although not as efficiently).

## The WebSocket Emulation modules

Unfortunately, WebSocket does not work [everywhere](https://github.com/sockjs/sockjs-client#supported-transports-by-browser-html-served-from-http-or-https). Even browsers supporting WebSocket run into issues if the network isn’t conducive to WebSocket. Here is where emulation modules come into play. They employ different strategies to ensure the browser gets the best possible real-time transport available (which ultimately is WebSocket).

Here are some popular emulation modules:

### Module: sockjs

The [sockjs](https://github.com/sockjs/sockjs-node) module is built on faye-websocket and is a mature WebSocket emulation layer that follows a _downgrade_ path. This means it will try the best protocol first and then fallback, if necessary, until it finds a working transport. It is used in conjunction with the client-side [sockjs-client](https://github.com/sockjs/sockjs-client) module. It includes a number of faster streaming transports as well as polling. Implementations exist for a number of other, non-Node, platforms if interoperability is important.

### Module: engine.io

The [engine.io](https://github.com/LearnBoost/engine.io) module is newer on the scene. It is built on ws by the guys behind socket.io. It follows an _upgrade_ path. This means it will try the most _reliable_ protocol first and then upgrade to the best available protocol. The [reasons](https://github.com/LearnBoost/engine.io#goals) stem from failures in the downgrade path detailed in the readme. It is used in conjunction with the client-side [engine-io-client](https://github.com/LearnBoost/engine.io-client) module.

## High-level API Sugar

If you need a high-functioning real-time engine without a ton of bells and whistles, sockjs or engine.io is the way to go. However, if your applications needs channels, rooms, broadcasting, or custom event emitters, there are options for that as well.

Since numerous modules fall under this category, we will only cover a few here:

### Module: socket.io

The [socket.io](https://github.com/learnboost/socket.io/tree/0.9) module is the original wildly popular real-time engine. It includes features such as broadcasting, rooms, namespaces, and custom event emitters. It is “still” in development, but version 1.0 integrates with engine.io (the latest stable 0.9.x does not).

### Modules: websocket-multiplex and shoe

The [websocket-multiplex](https://github.com/sockjs/websocket-multiplex) module builds on sockjs and provides channel support. The [shoe](https://github.com/substack/shoe) module also builds on sockjs and provides a neat stream-based approach to WebSocket.

### Module: primus

The [primus](https://github.com/primus/primus) module wraps around several real-time frameworks, such as engine.io and sockjs, to prevent vender lock-in. It includes a number of modules that add the functionality you need: channels (multiplexing), custom event emitters, rooms, etc.

## A fireside chat about real-time engines

Here’s a little advice from one who has “walked through the fire” of debugging real-time engines:

1.  Use only what you need and nothing more. In my experience, staying at the emulation layer with a library like sockjs or engine.io and building only what I need has proven easier to debug. I haven’t used primus personally, but I like the modular approach there. However, something feature-rich like socket.io enables faster prototyping of ideas.
2.  The downgrade approach is slightly faster to set up, but [has problems on some networks](https://github.com/sockjs/sockjs-client/issues/94?source=cc); upgrade approach is slightly slower, but more reliable. Both approaches have their merits. I’m curious as to how that is playing out for others.
3.  WebSocket running on port 80 can be the most troublesome for corporate firewalls as everybody likes to have their hands on that port! Try switching to 443 (SSL) or any other port to fix problems upgrading the protocol.

## Keeping it real-time

In this article, we surveyed a number of WebSocket modules in Node. We started with implementations (drivers) which provide the core WebSocket protocol. Then we looked at emulation modules which wrap WebSocket and a number of fallback transports in a common API. Lastly, we looked at high-level sugar modules that extend the emulation layers with additional conveniences.

WebSocket has become a game-changer in web development by enabling games, frameworks, and applications that were not possible before. What will you build?
