---
commentURL: ""
date: 2016-12-15T15:00:53-06:00
strongloopURL: "https://strongloop.com/strongblog/systematic-function-design-in-javascript/"
tags: ["design","javascript","nodejs"]
title: "Systematic data design in JavaScript"
draft: True
---

In the previous article, we discussed [systematic function design][1], a test/example/documentation-driven approach to designing functions in JavaScript. Please read part one (if you haven't already) before continuing here as we will build upon those concepts.

Let's turn our attention now to the design of data.

## Data definitions

_Data definitions_ bridge the gap between information in the program's domain and data that represents that information. For example, representing the state of a stop light could be done with the numbers `1`, `2`, and `3` or we could use the strings: `"red"`, `"green"`, and `"yellow"` or `true`, `false` and `undefined`. Regardless, we are translating information from the program's domain into data that represents that information.

A program's domain is the real problem/use case that needs to be solved/represented.  The data is what we can do _given our programming environment_ to as represent that.

_I don't know what the difference between a program's domain and data is. What makes them different? In this example, what is the program's domain and what is the data? Maybe I can use more than on way to describe each to be clear._

### Atomicity

Data should be _atomic_, meaning it should be _reduced to its essence_ without loosing meaning. For example, we could define a city as a string or we could define a city of a list of characters. Although, technically a city is made up of a list of characters, those characters have to be meaningfully formed together to be used in our domain.

Similarly, atomic data is _specific_, even though the stop light could be represented by any number of strings, it is specifically the strings `"green"`, `"red"`, and `"yellow"` in our example.

_This example is trivial, what are some hard cases or cases where specificity/atomicity matters?_

### Orthogonality

Another important concept is that the way we define our data should be _orthogonal_ to the way we define functions. In other words, our data definitions should be _mostly independent_ from the functions that operate on that data. When it comes to refactoring our application, this helps reduce the surface area for bugs.

_Why are bugs reduced? How the surface area reduced?_

## Designing data

We are going to design three different types of data taking each through the systematic design process. They are data that represents: a stop light, a natural number, and a coordinate.

### 1. Type comment

A type comment gives a descriptive name to the new type of data as well as how that form that data. JSDoc provides us a way to define our data types using `@typedef` comments that can used to generate documentation. Let's look at how we might define a `StopLight`.

```js
/**  
 * @typedef {("green"|"red"|"yellow")} StopLight
 */
```

Here we are defining a new type called `StopLight` that can either be the string `"green"`, `"red"`, or `"yellow"`. In other words, any string that is one of the three defined above is a valid "instance" of a `StopLight`.

> Note: Although these are just comments and don't enforce any run-time checks (something not possible with JavaScript), they communicate the purpose and structure of our data enriching the meaning of any functions that make use of them.

Let's look at a couple more examples. The natural numbers can represent things like a primary key in a database. Since the `number` type in JavaScript includes all the Natural numbers, we write a definition like this:

```js
/**  
 * @typedef {number} Natural
 */
```

We can also represent compound types using `@typedef` and `@prop`. For example here is an X and Y coordinate:

```js
/**
 * @typedef {Object} Coordinate
 * @prop {number} x
 * @prop {number} y
 */
```

### 2. Interpretation

Next, we provide an interpretation for our new data type. The interpretation bridges the gap between our data type and the information it represents.

```js
/**
 * A stop light.
 * @typedef {("green"|"red"|"yellow")} StopLight
 */
```

In our `Natural` type comment, we can use our interpretation to clarify our type as a JavaScript `number` includes rational numbers and negative integers. Also, throw in the fact that the natural numbers can include zero depending [on who you talk to](https://medium.com/r/?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FNatural_number). For this we can use [interval notation](https://medium.com/r/?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FInterval_%2528mathematics%2529) to be more specific.

```js
/**
 * A natural number: [1,∞)
 * @typedef {number} Natural
 */
```

Now our interpretation states that a `Natural` for our application includes any integer from 1 upwards.

Take a moment to come up with a clear and concise interpretation of the coordinate example above before continuing on.

### 3. Examples

Examples provide more explanation of type if it would be helpful. Depending on whether type is self-defining. For an enumeration like `StopLight`, all the possible examples are already encapsulated in the type comment so examples are not necessary. In the same way, a simple atomic type like `Natural` documents its cases.

However, `Coordinate` can be clarified with examples:

```js
/**
 * A coordinate.
 * @typedef {Object} Coordinate
 * @prop {number} x
 * @prop {number} y
 * @example
 *   { x: 34.54342, y: -95.43132 }
 */
```

### 4. Template

The last step is defining a one argument function that operates on that data type. A template function provides a roadmap for any functions we create later need to operate on this data. It is assumed that templates operate on valid data.

Let's look at a template function for our enumeration type `StopLight`:

```js
/**
 * Template for StopLight.
 * @param {StopLight} sl
 */
function tmplForStopLight(sl) {
  switch (sl) {
  case 'green':
    return sl
  case 'red':
    return sl
  case 'yellow'
    return sl
  }
}
```

A simple atomic type like a Natural doesn't has a much simpler template:

```js
/**
 * Template for Natural.
 * @param {Natural} n
 */
function tmplForNatural(n) {
  return n
}
```

You may be wondering, why even write a template this simple. In practice, you probably won't. Templates are intended to be copied when writing functions that operate on the given data. By writing a template you can easily see all the scenarios you need to account for in your function. Anything you determine to not be needed can be cut out.

[1]: {{< ref "post/htdp-functions.md" >}}
