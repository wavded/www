---
commentURL: ''
date: 2014-02-07T21:00:53.000Z
strongloopURL: 'https://strongloop.com/strongblog/robust-node-applications-error-handling/'
tags:
  - nodejs
  - errors
  - promises
title: 'Building robust Node applications: Error handling'
---

> Update 9-29-15: Domains are now [deprecated](https://nodejs.org/api/domain.html#domain_domain) in Node 4.x.

I've crashed more Node processes _in production_ than I'd like to admit. Thankfully, I've then learned how to build robustness into my Node applications. So, what can you build into your applications to keep yourself informed of errors and ultimately keep your applications running?

["Robustness"](http://en.wikipedia.org/wiki/Robustness) encompasses many aspects of application development like handling untrusted inputs or gracefully rolling-back state in response to an unexpected failure. In this article, we will focus on robustness in terms of keeping a Node application from crashing and building structures to handle and stay informed about errors. Specifically, we will look at application level errors, which is where most issues happen.

In Node, errors occur any of the following ways:

1. Explicit exceptions (those triggered by the `throw` keyword)
2. [Implicit exceptions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Error_types) (like `ReferenceError: foo not defined`)
3. The 'error' event (which may trigger an exception)
4. The error callback argument (no exceptions)

Before we look more into handling these errors, let's first step back and look at why applications terminate and how to be notified in order to address "crashers" (bugs that take down a Node process).

# The uncaught exception

_A Node process will terminate on any uncaught exception (explicit or implicit)_. This may be acceptable and preferable for short-running scripts; it is troublesome if you intend to keep the process running for a while (as you would in web servers, watch scripts, proxies, etc.). Node chooses to terminate the process because it's likely in an unstable state and may have leaked connections, files, and other I/O.

However, you can override this behavior by adding an `uncaughtException` handler on the `process` object. The following illustrates programmatically what Node does on your behalf when an uncaught exception occurs:

```javascript
process.on('uncaughtException', function (er) {
  console.error(er.stack)
  process.exit(1)
})
```

An `uncaughtException` handler should be treated as a last opportunity to say your goodbyes before calling `process.exit`. It is [not advised](http://nodejs.org/api/process.html#process_event_uncaughtexception) to keep the process running.

> **Why exit from an `uncaughtException`?** An `uncaughtException` is an event handler triggered away from the original source of the exception. All you receive back is the stack trace of the originating error. Most likely you have no reference back to the source objects surrounding the error to do damage control (cleaning up state or I/O). It's best to just exit and have your [service](http://upstart.ubuntu.com/) [manager](http://www.freedesktop.org/wiki/Software/systemd/)/[monitor](https://github.com/nodejitsu/forever) restart the process.

I will typically add an `uncaughtException` handler to send me an alert with the stack trace and other pertinent process information before shutting down. Receiving notifications for crashers is incredibly important in addressing issues quickly in production.

Here is sample email alert template using [nodemailer](https://github.com/andris9/Nodemailer):

```javascript
var nodemailer = require('nodemailer')
var transport = nodemailer.createTransport('SMTP', { // [1]
  service: "Gmail",
  auth: {
    user: "gmail.user@gmail.com",
    pass: "userpass"
  }
})
if (process.env.NODE_ENV === 'production') { // [2]
  process.on('uncaughtException', function (er) {
    console.error(er.stack) // [3]
    transport.sendMail({
      from: 'alerts@mycompany.com',
      to: 'alert@mycompany.com',
      subject: er.message,
      text: er.stack // [4]
    }, function (er) {
       if (er) console.error(er)
       process.exit(1) // [5]
    })
  })
}
```

1. Setup a transport (nodemailer supports a lot of options).
2. Ensure you are in production as you don't want to get a ton of emails while in development.
3. Log the stack trace.
4. Email the error with the stack trace.
5. Exit the process.

Ultimately, the goal is to get as few of these emails as possible. Yet, they are great way to alert yourself of anything that is taking down your Node process.

# The infamous 'error' event

Even after you receive a lovely email with a stack trace, you can get exceptions that are incredibly vague and can have absolutely no clue where they come from. Many of these originate from unhandled 'error' events. Node treats this as a special event. If left unhandled, it will `throw` an exception (instead of silently ignoring the error).

Any [EventEmitter](http://nodejs.org/api/events.html) can potentially emit an 'error' event and there are multiple objects that inherit from EventEmitters in Node (core and 3rd-party modules). The ['error' events emitted in Node core](https://github.com/nodejs/node/search?p=2&q=%22emit%28%27error%27%22+path%3Alib&type=Code) come from objects such as:

1. Streams
2. Servers
3. Requests/Responses
4. Child processes

Many 3rd-party modules will bubble up 'error' events or other errors from Node core modules as well as emit their own. For example, the [Redis](https://github.com/mranney/node_redis) module may emit 'error' events triggered by the underlying core net module:

```javascript
var redis = require('redis')
var client = redis.createClient(6379, 'some.unknown.host')
```

This code will throw an error:

```sh
events.js:72
throw er; // Unhandled 'error' event
^
Error: Redis connection to some.unknown.host:6379 failed - connect ENOENT
at RedisClient.on_error (/node_modules/redis/index.js:185:24)
at Socket.<anonymous> (/node_modules/redis/index.js:95:14)
at Socket.EventEmitter.emit (events.js:95:17)
at net.js:441:14
at process._tickCallback (node.js:415:13)
```

Thankfully, the Redis module gives you some context here. You may not be so lucky with other modules. Simply adding a listener will prevent the exception from being thrown:

```javascript
client.on('error', function (er) {
  console.trace('Module A') // [1]
  console.error(er.stack) // [2]
})
```

1. [`console.trace()`](http://nodejs.org/api/console.html#console_console_trace_label) is a handy way to let yourself know where you are in the code. Here we also labeled the stack trace for more context.
2. Handle and log the error.

I've found out (the hard way) that even if I _think_ it is unlikely for an 'error' event to occur, it may happen at some point (usually in production). The ones I'm most tempted to leave out are pipe operations, since it looks so elegant to just say:

```javascript
input.pipe(output)
```

However, a more robust approach adds error handling on both the input and output streams:

```javascript
function handleErr(er) { console.error(er) }
input.on('error', handleErr).pipe(output).on('error', handleErr)
```

You can avoid this extra stuff by grouping EventEmitter 'error' events with [domains](http://nodejs.org/api/domain.html):

```javascript
var domain = require('domain')
var fs = require('fs')
var d = domain.create() // [1]
d.on('error', console.error) // [2]
d.run(function () { // [3]
  var input = fs.createReadStream('/path/to/input')
  var output = fs.createWriteStream('/path/to/output')
  input.pipe(output)
})
```

1. Create the domain.
2. If an 'error' event is emitted by any EventEmitter while inside the domain, log it here.
3. Run a section of code inside the domain.

Here, if either the input or output streams were to have an error (like the file not existing), the domain would capture the error in one spot. This may or may not be what you want. Sometimes, it is helpful to recover from errors individually.

> With EventEmitters and domains you must explicitly add any EventEmitters to the domain if they were created outside the domain. You can add using [`d.add(eventEmitter)`](http://nodejs.org/api/domain.html#domain_domain_add_emitter).

# Catching implicit exceptions

We can't forget about common [implicit exceptions](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Error_types). A great example of this is the SyntaxError thrown when using JSON.parse.

```javascript
JSON.parse('undefined')
```

These errors are avoided by a simple try/catch block:

```javascript
try {
  JSON.parse(maybeJSON)
} catch (er) {
  console.error('Invalid JSON', er)
}
```

Linters like [ESLint](http://eslint.org), [JSHint](http://jshint.com/) or [JSLint](http://www.jslint.com/) aid in finding implicit exceptions like [ReferenceErrors on undefined variable usage](http://www.jshint.com/docs/options/#undef).

# The error argument

Node follows a convention for callbacks. I like the term _nodeback_: a callback function that receives an `error` as its first argument. If an error occurs in the asynchronous operation, the `error` object will be populated. Otherwise, it will be `null`.

> A Node process will never crash directly because of an error argument, as it's just an argument. However, it can easily cause implicit exceptions down the road if not handled.

Admittedly, I've neglected the error argument to my own peril and have come to see it as unwise to ignore it. Now, I see how important Node treats unhandled 'error' events and I try to treat the error argument just as important.

For example, we can assume we will always get a file buffer back from `fs.readFile`, but if we assume this we may crash our server due to a `ReferenceError`:

```javascript
fs.readFile('/path/to/file', function (er, buf) {
  var data = buf.toString() // ReferenceError: buf is undefined
})
```

It's also _not_ recommended to `throw` the error unless you have a mechanism to catch it (like [domains](http://nodejs.org/api/domain.html) or [promises]({{< ref "post/promises.md" >}})):

```javascript
fs.readFile('/path/to/file', function (er, buf) {
  if (er) throw er // [1]
  var data = buf.toString()
})
```

1. Nothing to catch and Node terminates the process.

A robust approach checks the error and logs it. Then, it only continues if it makes sense to do so:

```javascript
fs.readFile('/path/to/file', function (er, buf) {
  if (er) return console.error(er) // [1]
  var data = buf.toString()
})
```

1. Log the error, and do not continue since `buf` will be undefined.

It may feel messy seeing error handling all over the place; but domains and promises enable grouping of errors.

Here is an example using promises:

```javascript
var Q = require('q')
var fs_readFile = Q.denodeify(require('fs').readFile))
fs_readFile('/path/to/file')
  .then(function (buf) {
    var data = buf.toString() // [1]
    return fs_readFile('/path/to/another/file')
  })
  .then(function (buf2) {
    var data2 = buf2.toString() // [1]
  })
  .catch(function (er) {
    console.error(er) // [2]
  })
```

1. If we get here, the buffers will exist.
2. Handle errors from either file read here.

Here is a similar example with domains:

```javascript
var domain = require('domain')
var fs = require('fs')
var d = domain.create()
d.on('error', console.error)
fs.readFile(d.intercept(function (buf) {
  var data = buf.toString()
  fs.readFile('/path/to/another/file',
    d.intercept(function (buf2){
      var data2 = buf2.toString()
    })
  )
}))
```

In short, whether you are working in domains, promises or individual nodebacks -- handle the errors. _It's worse to never know an error is occurring._

# A checklist

Errors happen; its important to build structures to handle them. Use this checklist to buff up your code:

1. Where am I using `throw`? Am I prepared to handle these explicit exceptions when they occur?
2. Am I safeguarding against common sources for implicit exceptions (like `JSON.parse`, `undefined` data values in a nodeback)?
3. Am I handling `error` events on all EventEmitters?
4. Am I handling all error arguments in nodebacks?
5. Am I notified of uncaught exceptions?

Happy robust Noding!
