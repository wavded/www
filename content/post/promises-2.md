---
commentURL: ''
date: 2020-02-14T21:00:53.000Z
ibmURL: >-
  https://developer.ibm.com/articles/promises-in-nodejs-an-alternative-to-callbacks/
tags:
  - nodejs
  - promises
  - javascript
title: Promise composition
---

In the [last article on promises]({{< ref "post/promises.md" >}}), we focused on the [Promises/A+](http://promises-aplus.github.io/promises-spec/) specification and the ES6 implementation of promises. We learned the benefits of using promises over raw callbacks. We also learned some terminology to help wrap our minds around the concepts. If you run into any terms that are unfamiliar, please review the first article as this builds on top of it.

Now, we're going to take it up a notch and focus on promise composition, which we'll define as _functional programming and asynchronous control flow using promises_.

# Promise chaining

The `then` method allows us to chain promises (see 3.2.6 in [Promises/A+](http://promises-aplus.github.io/promises-spec/) spec). The value returned from a chain of promises _is itself a promise_. This returned promise will resolve to the value returned from the last `onFulfilled` or `onRejected` handler in the chain. Let's look at some examples:

```js
let chainPromise = getActiveUser()
  .then(JSON.parse)
  .then(getSubscriptionsForUser)
  .then(JSON.parse)
chainPromise.then(console.log, console.error)
```

Here, `chainPromise` could either be:

1. Fulfilled with a list of parsed subscriptions for the active user since that is the last `onFulfilled` handler in the chain _or_
2. Rejected at any point of the chain since there are no `onRejected` handlers

The same is true for nesting; this accomplishes the same task as above:

```javascript
let nestedPromise = getActiveUser().then(userJson => {
  let user = JSON.parse(userJson)
  return getSubscriptionsForUser(user).then(subJson => {
    return JSON.parse(subJson)
  })
})
nestedPromise.then(console.log, console.error)
```

Armed with this knowledge, we can create a recursive chain that calls a function forever until an error occurs.

```javascript
function forever(fn) {
  return fn().then(function() {
    return forever(fn) // Re-execute if successful
  })
}
// If an error occurs, log and done
forever(doThis).catch(console.error)
```

> **Won't this blow the stack?** No, because Promises/A+ requires the `onFulfilled` and `onRejected` handlers to trigger on a future turn in the event loop after the stack unwinds (3.2.4 in Promises/A+).

# Starting chains and grouping

Promises provide some tools out of the box to aid in composition. We'll focus on two of them: `Promise.resolve` and `Promise.all`.

`Promise.resolve(value)` converts a value into a promise that is automatically fulfilled with that value. This is useful for a couple reasons:

- First, if we have a function that could return a value or promise, we can make our API consistent by turning the value into a promise so the caller will always expect that.
- Second, `Promise.resolve` helps us start promise chains.

Here is an example:

```js
Promise.resolve('monkeys').then(console.log) // Will log 'monkeys'
```

The second tool is `Promise.all`. It takes an array of promises and returns a new promise, which we'll call a "group" promise. The group promise will either be:

1. Resolved when _all_ the promises resolve _or_
2. Rejected when _any_ reject.

`Promise.all` is helpful for grouping the fulfillment values from promises, regardless if the execution is in series or parallel:

```js
let groupPromise = Promise.all([doThis(), doThat()])
groupPromise.then(([resultOfThis, resultOfThat]) => {}, console.error)
```

`Promise.all` maintains the ordering of the results array, so the result of `doThis()` would be index `0` and so on. If either promise rejects, then the `groupPromise` also rejects and we'd log it with `console.error`.

# Working with collections

## Concurrent maps

Let's look at iterating through collections of data that require asynchronous action per element. Like `Array.prototype.map`, which synchronously deals with each element in an array, we can write a function that performs an asynchronous action on each element using promises.

```js
function promiseMap(xs, fn) {
  // Execute the function for each element in the array and collect the results
  let promises = xs.map(function(x) {
    return fn(x)
  })
  return Promise.all(promises) // Return the group promise
}
```

We can shorten this useful utility down to one line:

```js
let promiseMap = (xs, fn) => Promise.all(xs.map(x => fn(x)))
```

We then can use this function as such:

```js
const fs = require('fs')
let stat = util.promisify(fs.stat)
promiseMap(['list', 'of', 'files'], stat).then(console.log, console.error)
```

The beauty of this approach is that even non-promise-returning functions will work. For example, let's say we wanted to `stat` the files we do not already have in our cache:

```js
let cache = Object.create(null)
function statCache(file) {
  if (cache[file]) return cache[file] // If exists, return cache.
  let promise = stat(file)

  // Here we introduce a promise side-effect, we cache the stat.
  promise.then(stat => (cache[file] = stat))
  return promise
}
promiseMap(['list', 'of', 'files'], statCache).then(console.log, console.error)
```

Here, `statCache` returns a value or a promise. Regardless of what's returned, we can group it and provide the results with `Promise.all`. Sweet!

> How can this work? `Promise.all` internally transforms all values returned into promises.

## Serial maps

We talked about iterating through a collection with promises concurrently, but what about iterations in series? To do this, we programmatically create a promise chain:

```js
let promiseMapSeries = (xs, fn) => {
  // Create a empty promise to start our chain.
  let chain = Promise.resolve()

  let promises = xs.map(
    // Execute the next function after the previous has resolved.
    x => (chain = chain.then(() => fn(x)))
  )
  // Group the results and return the group promise.
  return Promise.all(promises)
}
```

In the above example, we used `Promise.all` to group operations done in series and `Promise.resolve` to start our promise chain. Each time through `xs.map`, we built a larger chain and returned a promise for that point in the chain until we reached the end of the array. If we unraveled this code, it would look something like this:

```js
let promises = []
let series1 = Promise.resolve().then(first)
promises.push(series1)
let series2 = series1.then(second)
promises.push(series2)
let series3 = series2.then(third)
promises.push(series3)
// ... etc
Promise.all(promises)
```

When structured this way, we maintain the order in our results and the serial execution.

# Combining recursion and composition

Let's write a program that uses some of the skills we acquired earlier to recursively traverse a directory tree asynchronously providing the caller with a list of file paths. The program will execute as so:

```sh
node traverse.js [STARTING DIRECTORY]
```

Here is the implementation:

```js
const fs = require('fs')
const {promisify} = require('util')

let readdir = promisify(fs.readdir)
let stat = promisify(fs.stat)

// Create our helper function.
let promiseMap = (xs, fn) => Promise.all(xs.map(x => fn(x)))

function readTree(path) {
  return (
    readdir(path) // Read directory at path.
      .then(files =>
        promiseMap(files, file => {
          let fpath = path + '/' + file

          // Get file stats.
          return stat(fpath).then(stat => {
            // If we have a directory, recurse into it.
            if (stat.isDirectory()) return readTree(fpath)
            return fpath
          })
        })
      )
      // Flatten any nested arrays and sort.
      .then(paths => paths.flat().sort())
  )
}

readTree(process.argv[2]).then(console.log, console.error)
```

If we wanted to execute this serially, we swap out `promiseMap` with `promiseMapSeries`. Nice!

# Going further with promises

Your best grasp of these concepts will come by playing around with them. Here are some ideas to get you started:

1. Try implementing `promiseMap` where it limits the number of items it handles concurrently. Then, try implementing it for `promiseMapSeries`.
2. Turn `setTimeout` into a promise-returning function called `delay`. Then, use delay to create a new `promiseMapSeries` function that adds a delay between calls.

For more examples of chaining, grouping, and using recursion with promises, this [gist](https://gist.github.com/wavded/6116786) implements other functional concepts.
