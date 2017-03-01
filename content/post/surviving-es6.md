---
commentURL: ''
date: 2016-08-07T20:33:02.000Z
strongloopURL: 'http://strongloop.com/strongblog/surviving-ecmascript-6'
tags:
  - nodejs
  - javascript
  - ecmascript
title: Surviving ECMAScript 6
---

I recently watched [an insightful talk](http://www.thedotpost.com/2015/11/rob-pike-simplicity-is-complicated) from [Rob Pike](https://en.wikipedia.org/wiki/Rob_Pike) where he shared his experience attending [Lang.Next](https://channel9.msdn.com/events/lang-next), a conference focusing on new and upcoming trends in programming languages. While there, Rob noticed how many presenters focused on things they were _adding_ to their respective languages. This concerned him because languages were becoming more complex and similar to one another.

# JavaScript complexity has grown

JavaScript (as standardized in ECMAScript aka ES) existed as ES3 with the same set of features for over 10 years. When ES5 was standardized, the syntax remained unchanged (version 4 was abandoned). However, the arrival of ES6 (aka ECMAScript 2015) feels in many ways like a new language. I'm not sure if the change is good or bad, but it is a certainly a change.

I've found ES6 both fun and frustrating. I hope to provide some tips to help you focus on writing quality maintainable code.

# Pace yourself

You don't need to convert everything to ES6 or adopt all the ES6 features immediately! It will take time to understand what works well and what doesn't. ES3 took years to boil down to the good parts, as this photo illustrates:

{{< figure src="/_media/js-compare.jpg" title="<https://twitter.com/absinthol/status/571002000135086080>" >}}

Think about it: _whole new sets of anti-patterns are under active development right now!_

Rushing in too quickly to new features could be counterproductive. I've watched this happen in the React community. ES6 classes used to be all the hotness, but then we realized that classes lacked essential features like static properties and mix-ins. So, we used Babel and new language proposals to add those features in, but we depended on languages features that didn't even exist. Now, many have moved back to `React.createClass` or strictly ES6 classes [with dangling static properties](https://github.com/reactjs/react-redux/blob/c20ae482a274dd2002b7814dd46ac503efb300ec/src/components/Provider.js#L47). Ironically, the initial code was easier to read and understand.

My advice: use what you know and understand well, then add in what makes sense.

> Keep in mind that some of the new ES6 "syntactic sugar" can make things [slower](https://kpdecker.github.io/six-speed/) than its ES5 counterparts.

# Use what's supported

I love [Babel](https://babeljs.io/) and what it provides to the JavaScript community. So this isn't intended to knock that project, but Babel allows all sorts of new syntax (even beyond ES6) like it's a thing right now! But... it's not a thing right now!

Babel also rewrites your code and now you depend on Babel. I experienced the downside of this when Babel 6 came out. Modules behaved differently and working syntax broke. If I use stable language features that are supported in the runtime, I don't worry about my code breaking when new updates arrive.

One beneficial addition to my Express development is the ES7 proposal for [async/await](https://github.com/tc39/ecmascript-asyncawait). This enables control flow that fits the semantics of JavaScript (**if**/**else**/**try**/**catch**/**return**) but for asynchronous programming. However, Node 6 does not support this proposal. So either I could include Babel or just use [co](https://www.npmjs.com/package/co) or [Bluebird.coroutine](http://bluebirdjs.com/docs/api/promise.coroutine.html), which give me the same benefits in Node 4+. I prefer what is supported.

# Tools over features

Spend time getting familiar with good JavaScript code quality tools. [ESLint](http://eslint.org/) is a crucial tool that makes me feel good about still using **var** in my projects because it has my edge cases covered. One killer feature in ESLint is auto-fix (`--fix` flag). If you don't have that integrated into your editor, go figure that out right now and come back!

Another huge time-saver is automatic formatting. ESLint is getting better with this all the time (with the `--fix` flag). I'm looking forward to the next releases now that [JSCS has joined the team](http://jscs.info/). [ESFormatter](https://github.com/millermedeiros/esformatter) is another great option.

Other indispensable tools include a [good testing framework](https://github.com/substack/tape), [test coverage](https://github.com/gotwarlost/istanbul), and [continuous integration](https://strongloop.com/strongblog/roll-your-own-node-js-ci-server-with-jenkins-part-1/).

Tools increase my confidence in the code my team and I write. If a new language feature doesn't work with my tools, I don't care to use it yet. I'd much rather have my tools work.

# **Adopt new features with care**

As you think about using a new feature, ask yourself:

1. Will this feature require me to compile my code?
2. Does this feature break the tools I'm using now?
3. What do I gain or lose from using this feature?

If the benefits clearly outweigh the losses, using that new feature might be a good move. If not, perhaps your best bet may be achieving your goal through other means.
