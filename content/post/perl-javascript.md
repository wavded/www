---
date: 2010-10-26T15:00:53-06:00
tags: ["javascript","perl"]
title: "Influenced by Perl"

---

I have become particularly more interested in various language paradigms, syntax, and behavior.  Other languages help me rethink about JavaScript and how I write code. I just inherited a Perl project at work and I have never worked with Perl before so if you are a Perl programmer reading this, please clarify any of my misunderstandings :-).

## Perl subroutines

One particular thing about Perl that was interesting to me was how function (subroutines) don’t have argument lists like most C-style languages.  Instead you have to "shift" off the arguments within the body of the subroutine, for example:

```pl
sub hash2item {
    my $self=shift;
    my $hash=shift;
    ...
}
```

So in this example `$hash` is one of the arguments.

What also was interesting to me is the first argument that is shifted off when dealing with a "class-like" structures is a reference to the object itself (`$self`), sorta like this in other languages.

## Using `$self` in JavaScript functions

The `$self` concept made me think about plain (non-constructor, no new operator) functions in JavaScript.  Although they don’t have a helpful this reference (points to the global object), you can use something like `$self` in Perl. Take this example:

```js
function renderElement(hash) {
    var self = renderElement,
        element = null;
    if(!self.renderedEl){
        element = document.createElement("div");
        element.className = "my-element";
        document.body.appendChild(element);
        self.renderedEl = element;
    }
    self.renderedEl.style.display = "block";
}
```

Whenever `renderElement` is called after its first time, it has information about the element so it doesn’t have to create it again because the state is stored in the function object and made available even after it has returned.

This example really helps clean up the parent scope "var" clutter found in examples like:

```js
var renderedEl; //outside var doesn't feel like it's part of the function
function renderElement(hash) {
    var element;
    if(!renderedEl){
        element = document.createElement("div");
        element.className = "my-element";
        document.body.appendChild(element);
        renderedEl = element;
    }
    renderedEl.style.display = "block";
}
```

Of course, you may have uses for this second example, like if you need it easily accessible by many functions but I think it enforces clean code to keep this information stored within the function if its only to be used by the function.  What are your thoughts?
