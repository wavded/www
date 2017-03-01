---
commentURL: ''
date: 2016-12-15T21:00:53.000Z
strongloopURL: 'https://strongloop.com/strongblog/systematic-function-design-in-javascript/'
tags:
  - design
  - javascript
  - nodejs
title: Systematic data design in JavaScript
draft: true
---

In the previous article, we discussed [systematic function design][1]: a test, example, and documentation-driven approach to designing functions using the [HtDP methodology][3].

In this three-part series, we are covering systematic design as it applies to:

1. Functions
2. Data
3. Worlds

Let's now turn our attention to the design of **data**.

# Data definitions

_Data definitions_ bridge the gap between information and data. For example, representing a traffic light in JavaScript could be done multiple ways:

1. Using strings like `"red"`, `"green"`, and `"yellow"`; or `"stop"`, `"go"`, and `"slow down"`.
2. Using numbers like `1`, `2`, and `3`.
3. Combining types like `true`, `false`, and `undefined`.
4. Etc.

Regardless, we are translating information into data that represents that information. So if `var trafficLight = "red"`, we interpret the data to mean a traffic light signaling to stop.

Data definitions also help us distinguish between similar data. For example, the string `"red"` may indicate a background color elsewhere in our program.

## Atomicity

Data should be _atomic_, meaning it should be _reduced to its essence_ without loosing meaning. For instance, we could define a city as a string or we could define a city as a list of characters. Although, technically a city is made up of a list of characters, those characters have to be meaningfully formed together to be used in our domain.

Similarly, atomic data is _specific_. Even though a traffic light could be represented by any number of strings, it is specifically the strings `"green"`, `"red"`, and `"yellow"`.

## Orthogonality

Data definitions should be _orthogonal_ to the way we define functions. In other words, data should be _mostly independent_ from the functions that operate on that data. This helps with refactoring our application later on as it can reduce the amount of places that need to change when functionality changes.

# Designing data

We are going to design three different types of data, taking each through the systematic design process. They are data that represents: a traffic light, a natural number, and a coordinate.

## 1\. Type comment

A type comment gives a descriptive name to the new type of data as well as how to form that data. JSDoc provides a way to define our data types using [`@typedef`][2] comments. Let's look at how we might define a `TrafficLight`.

```javascript
/**
 * @typedef {("green"|"red"|"yellow")} TrafficLight
 */
```

Here we are defining a new type called `TrafficLight` that can either be the string `"green"`, `"red"`, or `"yellow"`. In other words, any string that is one of the three defined above is a valid instance of a `TrafficLight`.

> Note: Although these are just comments and don't enforce any runtime checks, they communicate the purpose and structure of our data enriching the meaning of any functions that make use of them.

Let's look at a couple more examples. The natural numbers can represent things like a primary key in a database. Since the `number` type in JavaScript includes all the Natural numbers, we write a definition like this:

```javascript
/**
 * @typedef {number} Natural
 */
```

We can also represent compound types using `@typedef` and `@prop`. For example here is an X and Y coordinate:

```javascript
/**
 * @typedef {Object} Coordinate
 * @prop {number} x
 * @prop {number} y
 */
```

Note: you could use a constructor function as well for compound data. The important piece is that all the properties of the compound data type are documented.

## 2\. Interpretation

Next, we provide an interpretation for our new data type. The interpretation bridges the gap between our data type and the information it represents.

```javascript
/**
 * A traffic light.
 * @typedef {("green"|"red"|"yellow")} TrafficLight
 */
```

In our `Natural` type comment, we can use our interpretation to clarify our type as a JavaScript `number` includes rational numbers and negative integers. Also, throw in the fact that the natural numbers [may start at zero or one][4]. For this we can use [interval notation][5] to be more specific.

```javascript
/**
 * A natural number: [1,∞)
 * @typedef {number} Natural
 */
```

Now our interpretation states that a `Natural` for our application includes any positive integer.

Take a moment to come up with a clear and concise interpretation of the coordinate example above before continuing on.

## 3\. Examples

Examples provide more explanation of type if it would be helpful. Depending on whether type is self-defining. For an enumeration like `TrafficLight`, all the possible examples are already encapsulated in the type comment so examples are not necessary. In the same way, a simple atomic type like `Natural` documents its cases.

However, `Coordinate` can be clarified with examples:

```javascript
/**
 * A coordinate.
 * @typedef {Object} Coordinate
 * @prop {number} x
 * @prop {number} y
 * @example
 *   { x: 34.54342, y: -95.43132 }
 */
```

## 4\. Template

The last step is defining a one argument function that operates on that data type. A template function provides a roadmap for any functions created later on that need to operate on this type of data.

Let's look at a template function for our enumeration type `TrafficLight`:

```javascript
function tmplForStopLight(tl) {
  switch (tl) {
  case 'green':
    return tl
  case 'red':
    return tl
  case 'yellow'
    return tl
  }
}
```

A simple atomic type like a Natural has a much simpler template:

```javascript
function tmplForNatural(n) {
  return n
}
```

You may be wondering, why even write a template this simple. In practice, you probably won't. Templates are intended to be copied when writing functions that operate on the given data. By writing a template you can easily see all the scenarios you need to account for in your function. Anything you determine to not be needed can be cut out.

# Writing functions using data definitions

Once you have your data defined, you can use those new types as your write functions to operate on that data. For example, here is a function that indicates if a traffic light is in a stopped state:

```javascript
/**
 * Produce true if traffic light stopped.
 * @param {TrafficLight} tl
 * @return {boolean}
 */
console.assert(isStopped("green"), false)
console.assert(isStopped("yellow"), false)
console.assert(isStopped("red"), true)
function isStopped(tl) {
  switch (tl) {
  case 'red':
    return true
  }
  return false
}
```

[1]: {{< ref "post/htdp-functions.md" >}}

[2]: http://usejsdoc.org/tags-typedef.html
[3]: http://www.ccs.neu.edu/home/matthias/HtDP2e
[4]: https://en.wikipedia.org/wiki/Natural_number
[5]: https://en.wikipedia.org/wiki/Interval_(mathematics)
