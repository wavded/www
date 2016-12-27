---
date: 2010-05-07T15:00:53-06:00
tags: ["javascript"]
title: "Cycling through an array using the comma operator"

---

The comma operator in JavaScript was a long time a mystery to me but once I started using it I found it can be quite handy in certain situations.  In this example, picking the next color out of the available six.

```js
var colorIndex = 0
var colors = ["FF0000", "008000", "FF0086", "A2FF00", "0000FF", "800080"]
function selectNextColor(){
  return colors[colorIndex++] || colors[colorIndex = 0, colorIndex++]
}
```

So what’s this all about:

```js
return colors[colorIndex++] || colors[colorIndex = 0, colorIndex++]
```

So if the current index exists in the array use that and if not, reset the array to 0 and then grab the current index (which is now 0).  The mystery of the comma operator is that only the last value gets accessed by the array and I’m using the first value to perform an assignment.  So what do you think?  Bad practice?  Handy?  Have some of your own examples to share?
