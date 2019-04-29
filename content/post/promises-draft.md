---
commentURL: ''
date: 2019-04-20T21:00:53.000Z
ibmURL: >-
  https://developer.ibm.com/node/2016/07/27/auto-fixing-formatting-your-javascript-with-eslint/
tags:
  - nodejs
  - promises
  - javascript
title: 'Promises in Node: An alternative to callbacks'
draft: true
---

Promises provide a compelling alternative to callbacks when dealing with asynchronous code. Still, promises can be confusing and perhaps you've written them off or skipped directly to the syntactic sugar for promises, namely [`async/await`][2] without understanding how they work and behave at a fundamental level. As of this writing, the building blocks for promises exist in current versions of Node and browsers. Let's take a look how this all works.

> I would be remiss not to mention the [significant work done][1] to bring out the essential beauty of promises in a way that is interoperable and verifiable, namely, the [Promises/A+](http://promises-aplus.github.io/promises-spec/) specification which started us all down this path.

# Promises in the abstract

First we'll talk about the **behavior** of promises: What are they and how can they be useful? Then we'll discuss how to create and use promises.

What is a promise? Let's look at a definition:

> A promise is an abstraction for asynchronous programming. It's an object that proxies for the return value or the exception thrown by a function that has to do some asynchronous processing. -- [Kris Kowal on JSJ](http://javascriptjabber.com/037-jsj-promises-with-domenic-denicola-and-kris-kowal/)

Callbacks are the simplest possible mechanism for asynchronous code in JavaScript. Yet, raw callbacks sacrifice the control flow, exception handling, and function semantics familiar from synchronous code. Promises provide a way to get that back.

The core component of a promise object is its `then` method. The `then` method is how we get the return value (known as the _fulfillment value_) or the exception thrown (known as the _rejection reason_) from an asynchronous operation. `then` takes two optional callbacks as arguments, which we'll call `onFulfilled` and `onRejected`:

```javascript
var promise = doSomethingAync()
promise.then(onFulfilled, onRejected)
```

`onFulfilled` and `onRejected` trigger when the promise resolves (the asynchronous processing has completed). One of these functions will trigger because _only_ one resolution is possible.

## Callbacks to promises

Given this basic knowledge of promises, let's take a look at a familiar asynchronous Node callback:

```javascript
readFile(function(err, data) {
  if (err) return console.error(err)
  console.log(data)
})
```

If our `readFile` function _returned a promise_, we would write the same logic as:

```javascript
var promise = readFile()
promise.then(console.log, consoler.error)
```

At first glance, it looks like the aesthetics changed. But, we now have access to a **value** representing the asynchronous operation (the promise). We can pass the promise around and anyone with access to the promise can consume it using `then` _regardless if the asynchronous operation has completed or not_. We also have guarantees that the result of the asynchronous operation won't change somehow, as the promise will resolve once (either fulfilled or rejected).

> It's helpful to think of `then` not as a function that takes two callbacks (`onFulfilled` and `onRejected`), but as a function that _unwraps_ the promise to reveal what happened from the asynchronous operation. Anyone with access to the promise can use `then` to unwrap it. For more about this idea, read [Callbacks are imperative, promises are functional: Node's biggest missed opportunity](http://blog.jcoglan.com/2013/03/30/callbacks-are-imperative-promises-are-functional-nodes-biggest-missed-opportunity/).

## Chaining and nesting promises

The `then` method itself _returns a promise_:

```javascript
var promise = readFile()
var promise2 = promise.then(readAnotherFile, console.error)
```

This promise represents the return value for its `onFulfilled` or `onRejected` handlers, if specified. Since one resolution is possible, the promise proxies the triggered handler:

```javascript
var promise = readFile()
var promise2 = promise.then(
  function(data) {
    return readAnotherFile() // if readFile was successful, let's readAnotherFile
  },
  function(err) {
    console.error(err) // if readFile was unsuccessful, let's log it but still readAnotherFile
    return readAnotherFile()
  }
)
promise2.then(console.log, console.error) // the result of readAnotherFile
```

Since `then` returns a promise, it means promises can chain together to avoid the deep nesting of [callback hell](http://callbackhell.com/):

```javascript
readFile()
  .then(readAnotherFile)
  .then(doSomethingElse)
  .then(...)
```

Still, promises can nest if keeping a closure alive is important:

```javascript
readFile().then(function(data) {
  return readAnotherFile().then(function() {
    // do something with `data`
  })
})
```

## Promises and synchronous functions

Promises model synchronous functions in important ways. One such way is using `return` for continuation instead of calling another function. The previous examples returned `readAnotherFile()` to signal what to do after `readFile()`.

If you return a promise, it will signal the next `then` when the asynchronous operation completes. You can also return any other value and the next `onFulfilled` will get the value as an argument:

```javascript
readFile()
  .then(function(buf) {
    return JSON.parse(buf.toString())
  })
  .then(function(data) {
    // do something with `data`
  })
```

## Error handling in promises

You also can use the `throw` keyword and get `try/catch` semantics. This may be one of the most powerful features of promises. For example, consider the following synchronous code:

```javascript
try {
  doThis()
  doThat()
} catch (err) {
  console.error(err)
}
```

In this example, if `doThis()` or `doThat()` would `throw` an error, we would `catch` and log the error. Since `try/catch` blocks allow grouped operations, we can avoid having to explicitly handle errors for each operation. We can do this same thing asynchronously with promises:

```javascript
doThisAsync()
  .then(doThatAsync)
  .then(undefined, console.error)
```

If `doThisAsync()` is unsuccessful, its promise rejects and the next `then` in the chain with an `onRejected` handler triggers. In our case, this is the `console.error` function. And like `try/catch` blocks, `doThatAsync()` would never get called. This is a improvement over raw callbacks where you have to handle errors explicitly at each step.

But, it gets better! Any thrown exception, implicit or explicit, from the `then` callbacks is also handled in promises:

```javascript
doThisAsync()
  .then(function(data) {
    data.foo.baz = 'bar' // throws a ReferenceError as foo is not defined
  })
  .then(undefined, console.error)
```

Here, the raised `ReferenceError` triggers the _next_ `onRejected` handler in the chain. Pretty neat! Of course, this works for explicit `throw` as well:

```javascript
doThisAsync()
  .then(function(data) {
    if (!data.baz) throw new Error('Expected baz to be there')
  })
  .catch(console.error) // catch(fn) is shorthand for .then(undefined, fn)
```

## An important note with error handling

As stated earlier, promises mimic `try/catch` semantics. In a `try/catch` block, it's possible to mask an error by never explicitly handling it:

```javascript
try {
  throw new Error('never will know this happened')
} catch (e) {}
```

The same goes for promises:

```javascript
readFile().then(function(data) {
  throw new Error('never will know this happened')
})
```

To expose masked errors, a solution is to end the promise chain with a simple `.catch(onRejected)`clause:

```javascript
readFile()
  .then(function(data) {
    throw new Error('now I know this happened')
  })
  .catch(console.error)
```

Third-party libraries include options for exposing unhandled rejections.

# Promises in the concrete

Our examples have used promise-returning dummy methods to illustrate the `then` method from ES6/2015 and [Promises/A+](http://promisesaplus.com/). Let's turn now and look at more concrete examples.

## Converting callbacks to promises

You may be wondering how to create a promise in the first place. The API for creating a promise isn't specified in Promise/A+ because it's not necessary for interoperability. ES6/2015 did standardize a Promise constructor which we will come back to. One of the most common cases for use promises is converting existing callback-based libraries. Here, promise libraries like [Bluebird](http://bluebirdjs.com/) can provide convenient helpers.

For example, Node's core asynchronous functions do not return promises; they take callbacks. But, we can make them return promises using Bluebird:

```javascript
var fs = Bluebird.promisifyAll(fs)
var promise = fs.readFileAsync('myfile.txt')
promise.then(console.log, console.error)
```

Bluebird provides helper functions for adapting Node and other environments to be promise-aware. Check out the [API documentation](http://bluebirdjs.com/docs/api/promisification.html) for more details.

## Creating raw promises

You can manually create a promise using the Promise constructor. Let's say we wanted to manually wrap `fs.readFile` to return a promise, instead of taking a callback:

```javascript
function readFileAsync(file, encoding) {
  return new Promise(function(resolve, reject) {
    fs.readFile(file, encoding, function(err, data) {
      if (err) return reject(err) // rejects the promise with `err` as the reason
      resolve(data) // fulfills the promise with `data` as the value
    })
  })
}
readFileAsync('myfile.txt').then(console.log, console.error)
```

## Making APIs that support both callbacks and promises

We have seen two ways to turn callback code into promise code. You can also make APIs that provide both a promise and callback interface. For example, let's turn `fs.readFile` into an API that supports both callbacks and promises:

```javascript
function readFileAsync(file, encoding, cb) {
  if (cb) return fs.readFile(file, encoding, cb)
  return new Promise(function(resolve, reject) {
    fs.readFile(function(err, data) {
      if (err) return reject(err)
      resolve(data)
    })
  })
}
```

If a callback exists, trigger it with the standard Node style `(err, result)` arguments.

```javascript
readFileAsync('myfile.txt', 'utf8', function(er, data) {
  // ...
})
```

## Doing parallel operations with promises

We've talked about sequential asynchronous operations. For parallel operations, ES6/2015 provides the `Promise.all` method which takes in an array of promises and returns a new promise. The new promise fulfills after _all_ the operations have completed. If _any_ of the operations fail, the new promise rejects.

```javascript
var allPromise = Promise.all([fs_readFile('file1.txt'), fs_readFile('file2.txt')])
allPromise.then(console.log, console.error)
```

> It's important to note again that promises mimic functions. A function has one return value. When passing `Promise.all` two promises that complete, `onFulfilled` triggers with one argument (an array with both results). This may surprise you; yet, consistency with synchronous counterparts is an important guarantee that promises provide.

## Making promises even more concrete

The best way to understand promises is to use them. Here are some ideas to get you started:

- Wrap some standard Node library functions, converting callbacks into promises. No cheating using a "callback to Promise" utility!
- Take a function using `async/await` and rewrite it without using that syntactic sugar. This means you will return a promise and use the `then` method.
- Write something recursively using promises (a directory tree would be a good start).
- Write a passing [Promise A+ implementation](https://github.com/promises-aplus/promises-tests). Here is my [crude one](https://gist.github.com/wavded/5692344).

## Further resources

- [ES6 Promise Specification](http://www.ecma-international.org/ecma-262/6.0/#sec-promise-objects)
- [NodeUp – fortysix – a promises by promisers show](http://nodeup.com/fortysix)
- [Promises with Domenic Denicola and Kris Kowal](http://javascriptjabber.com/037-jsj-promises-with-domenic-denicola-and-kris-kowal/)
- [Redemption from Callback Hell](http://www.youtube.com/watch?v=hf1T_AONQJU&list=PLm8l5qaFJjn_1KdNpp5LEhUCtugd9Kbsf&index=1)
- [You're Missing the Point of Promises](http://domenic.me/2012/10/14/youre-missing-the-point-of-promises/)
- [Callbacks are imperative, promises are functional](http://blog.jcoglan.com/2013/03/30/callbacks-are-imperative-promises-are-functional-nodes-biggest-missed-opportunity/)
- [List of Promise/A+ compatible implementations](https://github.com/promises-aplus/promises-spec/blob/master/implementations.md)

[1]: https://promisesaplus.com/credits
[2]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/async_function
