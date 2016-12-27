---
date: 2010-05-07T15:00:53-06:00
tags: ["javascript"]
title: "Cycling through an array using the comma operator"

---

The comma operator in JavaScript was a long time a mystery to me but once I started using it I found it can be handy in certain situations.  In this example, picking the next color out of the available six.

```js
var colorIndex = 0
var colors = ["ff0000", "008000", "ff0086", "a2ff00", "0000ff", "800080"]
function selectNextColor(){
  return colors[colorIndex++] || colors[colorIndex = 0, colorIndex++]
}
```

So, what’s this all about:

```js
return colors[colorIndex++] || colors[colorIndex = 0, colorIndex++]
```

If the current index exists in the array, use it. If not, reset the index to `0`, then grab the current index (which is now `0`), and use that.  The mystery of the comma operator is that only the last value, `colorIndex++`, gets returned to the array and I’m using the first expression to perform an assignment -- `colorIndex = 0`.
