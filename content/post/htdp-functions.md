---
commentURL: ""
date: 2016-12-15T15:00:53-06:00
strongloopURL: "https://strongloop.com/strongblog/systematic-function-design-in-javascript/"
tags: ["design","javascript","nodejs"]
title: "Systematic function design in JavaScript"
draft: True
---

Habits can be damning or liberating. Perhaps you are like me. I know having tests, examples, and documentation are good things for any program but why do they always seem to be an afterthought? Wouldn't it be great to have a coding methodology that propels me to write well-documented and tested programs that are easy to change? Thankfully, a team of professors/researchers have tackled this very problem and distilled their insights in what is called [systematic program design](https://www.edx.org/xseries/how-code-systematic-program-design) or the [HtDP](http://www.ccs.neu.edu/home/matthias/HtDP2e/) methodology (How to Design Programs).

Why would you want to learn the HtDP methodology? HtDP gives you a _process_ for designing functions, data, and worlds that driven by documentation, example, and tests. Well-designed HtDP programs are clear, tested, and easy to change. In this three-part series, we will look at some core concepts of HtDP as they apply to JavaScript:

1.  Functions.
2.  Data.
3.  Worlds.

This first part is on functions. Let's get started.

## Designing functions

Let's define a function that takes a number and produces a number that is double the number provided. I'm sure you've already done this function in your head and have seen it used in countless examples prior. However, we are going to take a step back and take a systematic approach that will land us with a well-documented and tested function in the end.

In our examples, we will use [JSDoc](http://usejsdoc.org/)-style comments. This will make our comments more useful for other tools like [Tern](http://ternjs.net/) and it allows us to easily generate and publish documentation for our projects.

### 1. Signature

When thinking about how to design functions, we first access the signature**.** The **signature** represents the _types_ of data the function will receive as parameters and what _type_ of data the function will return. The signature should use the _most specific_ types that satisfy the requirements of the function. In this case, we can double _any_ number but if we had a function that only applied to integers or natural numbers, we use the most specific type.

> But wait! JavaScript doesn't have static typing or custom types. That's correct, we can't enforce these types at a code level but it is still important to clearly document types as they inform our design of the function and inform others (including our future self) that use the function in the future. We will look at designing custom data in the next article.

Let's write our signature:

```js
/**
 * @param {number} n
 * @return {number}
 */
```

Here we state our function will take a number (which we call `n`) and return a number.

### 2. Purpose

The **purpose** is a succinct description of what the function will produce given its inputs. Let's add our purpose:

```js
/**
 * Produce a number that is double the number given.
 * @param {number} n
 * @return {number}
 */
```

A purpose should include any special cases if they exist as well. For example, say we had a function that searches for a value's index in an array. If it does not find the value it will return `-1` instead. Sound familiar? Our purpose in that case would read something like:

_Produce the index for the provided value, if none return -1._

### 3. Stub

Lastly, the **stub** is a bare bones implementation of the function. A stub should define a good _name_ for our function and include the right amount of _arguments_ that also are named clearly. The stub also returns a _valid_ value given the function's return type. Here we return a number, so we use the zero value for the stub.

```js
/**
 * Produce a number that is double the number given.
 * @param {number} n
 * @return {number}
 */
function double(n) { return 0 }
```

> For JavaScript, falsy or empty values work well for stub return values. So a good base for a number type is `0`, a Boolean type `false`, a string `""`, an array `[]`, etc.

The order in which you tackle the signature, purpose and stub doesn't have to be sequential. You may find that one may inform another better depending on the function you are writing and that's OK. In fact, JSDoc comments encourage you to consider your stub's parameter names when you are writing your signature.

### 4. Examples

With these three pieces in place (the signature, purpose, and stub), we then start to write our examples. **Examples** should include all the variance that the function may have given its inputs (like base/edge cases if they exist). Examples are also tests.

Our double function doesn't have any edge cases, so any number will work for our tests:

```js
/**
 * Produce a number that is double the number given.
 * @param {number} n
 * @return {number}
 */
console.assert(double(0) === 0)
console.assert(double(1) === 1)
console.assert(double(2) === 4)
function double(n) { return 0 }
```

> For conciseness and focus we are just using **console.assert** here as it exists in Node and modern browsers out of the box. In practice, using a test framework like [Tape](https://github.com/substack/tape) or [Mocha](http://mochajs.org) and having your examples/tests in a separate file scales better.

We now run our file to ensure our tests are well formed. You also should notice that most are failing.

> **Pop quiz**: When thinking about the `indexOf` function that was mentioned in the purpose section, we will have a base/edge case. Write a `console.assert` statement for that case. Notice how the purpose helps inform your examples.

### 5. Template

The next part of the process is the **template** which is a reference implementation of the function given the types of data it consumes. Since we are using a simple atomic type here, the template is basic:

```js
function double(n) { return n }
```

A template gives us what we _have to work with_ when implementing your function. In our simple example, the `n` indicates we have the data **n** to work with. Templates for a basic function like double may seem useless or obvious, but _they will serve a more important role when we start looking at data design_. For now, its good to understand why they exist.

### 6. Implementation

The last piece is the actual **implementation** of the function. At this stage, we can delete or comment out the stub and start fleshing out our template with a function that is informed by all we've learned so far.

```js
function double(n) { return n * 2 }`js
```

When we are finished, we run our tests against them to ensure they all pass and that our function is well formed. Our final code looks like this:


```js
/**
 * Produce a number that is double the number given.
 * @param {number} n
 * @return {number}
 */
console.assert(double(0) === 0)
console.assert(double(1) === 1)
console.assert(double(2) === 4)
// function double(n) { return 0 } // stub
// function double(n) { return n } // template
function double(n) { return n * 2}
```

Note that it is normal to revisit the other pieces of the formula as you work though the steps. For example, you may recognize that you can use a more specific type and therefore update your signature to reflect. Or, you notice that you are missing some tests so you go back and add them in.

## Wrap-up

In this article, we looked at how to do design functions following the HtDP method. In the next article, we are going to look at how to design data and you’ll see how the templates start to get more interesting.

In the meantime, try following this method step-by-step and write the following functions:

1.  Write a function called _exclaim_ that converts any string into a string with an exclamation point at the end.
2.  Write a function called _first_ that takes an array of values and returns the first one. If the array is empty, it should return null. Note: you should use the any type (`{}`) in your `@return` tag.
3.  Write a function called _dashString_ that takes an array of string values (`{Array.<string>}`) and joins them together with dashes. If the array is empty, you should return an empty string.
