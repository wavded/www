---
commentURL: ''
date: 2017-03-02T21:00:53.000Z
tags:
  - design
  - javascript
  - nodejs
title: Systematic world design in JavaScript
draft: true
---

In the previous article, we discussed [systematic data design][2]: a test, example, and documentation-driven approach to designing functions using the [HtDP methodology][3].

In this three-part series, we are covering systematic design as it applies to:

1. [Functions][1]
2. [Data][2]
3. Worlds

Let's now turn our attention to the design of **worlds**.

# What is a world?

A world is simply the program your functions and data live in. In larger programs, it could also refer to a particular module or package.

# World planning

This aspect of systematic design has nothing to do with code and it should precede data and function design. When thinking about the design of a world, we must think of:

1. What data in my world will not change? In other words, what is _constant_?
2. What data in my world will change?
3. What functions will I need to bring about those changes?
4. Illustrate or describe the possible states.

> Show worksheet.

[1]: {{< ref "post/htdp-functions.md" >}}

[2]: {{< ref "post/htdp-data.md" >}}

[3]: http://www.ccs.neu.edu/home/matthias/HtDP2e
