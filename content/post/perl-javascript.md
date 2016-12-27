---
date: 2010-10-26T15:00:53-06:00
tags: ["javascript","perl"]
title: "Influenced by Perl"

---

I'm interested in various language paradigms, syntax, and behavior.  Whenever I learn a new language, it helps me rethink other languages. Recently, that language has been Perl.

## Perl subroutines

Functions in Perl do not have parameter lists like most C-style languages.  Instead you have to `shift` off the arguments within the body of the subroutine for a class, for example:

```pl
sub hash2item {
  my $self=shift;
  my $hash=shift;
  ...
}
```

The first argument shifted off is a reference to the object itself (named `$self` here).  The first parameter passed to the function is `$hash`.

In JavaScript, this would be akin to a method like:

```js
function hash2item (hash) {
  var self = this
}
```

## Using `$self` in JavaScript functions

The `$self` concept made me think about vanilla functions in JavaScript.  Although they don’t have a helpful `this` reference (i.e. global object), you can use something like `$self` in Perl to reference the function itself and use it as an object:

```js
function renderElement() {
  var self = renderElement
  var element = null

  if(!self.renderedEl){
    element = document.createElement("div")
    element.className = "my-element"
    document.body.appendChild(element)
    self.renderedEl = element
  }

  self.renderedEl.style.display = "block"
}
```

The first time we call `renderElement`, we create and cache an element on the function object itself.  On subsequent calls, we utilize the data stored on the object.

This example helps clean up parent scope `var` clutter found below when storing data:

```js
var renderedEl
function renderElement() {
  var element

  if(!renderedEl){
    element = document.createElement("div")
    element.className = "my-element"
    document.body.appendChild(element)
    renderedEl = element
  }

  renderedEl.style.display = "block"
}
```
