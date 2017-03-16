---
commentURL: ''
date: 2015-08-30T21:00:53.000Z
strongloopURL: 'https://strongloop.com/strongblog/javascript-babel-future/'
tags:
  - babel
  - javascript
  - nodejs
title: Making the most of JavaScript's future today with Babel
---

From CoffeeScript to ClojureScript to PureScript to CobolScript to [DogeScript][1] (woof woof!), JavaScript is the write-once-run-anywhere target for many forms and styles of programming. Yet, its biggest compile-to-language today actually isn't any of these adaptations; its JavaScript itself.

Why? **Universality!**

If you are a client-side developer, it's likely you've already enhanced older platforms with newer features. Take ES5 for example. Supporting Internet Explorer 8 was a pain, but [`es5-shim`][2] made the JavaScript part a lot smoother.

One of the things that attracted me to Node (circa 2009) was the ability to break away from browser support humdrum. It was blissful for a while, but Node is not exempt from legacy JavaScript compatibility issues anymore. Say you are a library author who is using generators in io.js but wants to support Node 0.10\. Or you are sharing code between the client and server (like in a React application) and want to use classes or destructuring. The fact is, developers want to utilize new features without having to be concerned about legacy support. Legacy support isn't a passion of mine, and I bet it isn't one of yours.

**JavaScript should be a write-once-run-everywhere language!**

The JavaScript language is developing faster (ES7/2016 anyone?) than it ever has. Libraries are taking advantage of the new features, even though Node and browser's haven't yet settled in to the new standards (take React's adoption of ES6 classes, for example). I expect the trend to continue.

The good news is that it is easy to start taking advantage of new language features now with [Babel][3] and have them work across legacy and current platforms. Babel has built in a source-map support for browsers and proper stack traces for Node, so it gets out of the way for you to focus on the ES6 code.

> Babel isn't the only [source-to-source][4] compiler for ES. [Traceur][5] from Google is another example. For clarity, we will just focus on Babel here.

# Practically speaking: Developing with ES6 and beyond

The remainder of this article will be a practical launching point if you haven't used Babel before and perhaps fill in some gaps if you have. We will build a simple app to provide context. The final product is [located on GitHub][6].

Here is a starting structure:

```sh
├── build
├── modules
│   ├── utils
│   │   ├── __tests__
│   │   │   └── sleep-test.js
│   │   └── sleep.js
│   └── index.js
├── .eslintrc
├── .babelrc
├── package.json
└── index.js
```

1. The _build_ folder contains the built assets for Node. This is used in production (or for published modules) and typically ignored in version control.
2. The _modules_ folder contains the application components themselves.
3. The _.eslintrc_ file is lint configuration.
4. The _.babelrc_ file is Babel configuration.
5. The _package.json_ contains scripts for running and building the project
6. The _index.js_ file sets up Babel hooks for development.

Go ahead and create these files and directories. To create a _package.json_ file quickly, just run `npm init -y`.

# Installing dependencies

Now let's get our dependencies installed and saved. Run the following to install our development dependencies:

```sh
npm install babel babel-eslint eslint eslint-config-standard babel-tape-runner blue-tape -D
```

1. `babel` is the main core babel project that allows us to set up our development environment
2. `babel-eslint` is a parser for eslint that teaches the linter about experimental features that aren't in ES6.
3. `eslint` is a linting tool and `eslint-config-standard` is a set of configurations for `eslint` that we'll write our code against which follows the JS Standard style.
4. `babel-tape-runner` hooks in babel when running tape and `blue-tape` is an extension to tape that adds promise support (which will come in handy in a bit).

Now that we have necessary dependencies to start our development, let's install one more that will be used for production:

```sh
npm install babel-runtime -S
```

The `babel-runtime` package allows us to require only the features we need when distributing our application without polluting the global scope.

# Configuring Babel

Let's look at the _.babelrc_ file next. Having a _.babelrc_ file allows you to configure Babel in one spot in your project and it will work regardless how its run. Create a _.babelrc_ file with the following content:

```json
{
  "stage": 0,
  "loose": "all"
}
```

There are a number of [options][7] for configuration, but we will focus on two:

1. The `stage` option defines what minimum proposal stage you want to support. By default, Babel provides the functionality found in the ES6 standard. However, Babel also includes support for language proposals for the next standard. This is pretty cool because it allows you to test drive features and give feedback to implementers as it goes through standardization. Specification proposals are subject to change in breaking ways or completely fizzle out all together. The higher the stage, the further along the specification is in the standardization process. You can view all of the proposals supported on the Experimental page. We will use the async/await proposal in our application.
2. The `loose` option will generate cleaner and faster output as it won't check ECMA specification fringe cases that are likely not to appear in your code. However, make sure you are aware of the edge cases before you use loose mode. This is handy for production performance as well.

# Building our application

Now that we have Babel configured, let's write some code! First, set up the root _index.js_ file for development purposes with the following code:

```javascript
require('babel/register')
require('./modules')
```

1. The `require('babel/register')` line registers Babel, pulls in our _.babelrc_ configuration and also includes a polyfill for ES6 extensions for native objects like `Number.isNaN` and `Object.assign`.
2. Now that Babel is registered, any file we require after that will be transpiled on the fly. So, in our case, we require our application with `require('./modules')`.

Next, let's create an entirely lame app that makes use of ES6 and the experimental `async/await` proposal. Put the following code in _modules/index.js_:

```javascript
import { hostname } from 'os'
import sleep from './utils/sleep'

async function runApp () {
  console.log('time for bed', hostname())
  await sleep(200)
  console.log('😴')
  await sleep(1000)
  console.log('💤')
}

runApp()
```

I told you it was lame. However, we are making use of the new import syntax to pull in the `hostname` function from the `os` module and include a sleep module (which we'll write in a bit). We are also using the [async/await proposal][8] to write clean asynchronous code.

Let's write our sleep module next. Add the following code to _modules/utils/sleep.js_:

```javascript
export default function sleep (ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}
```

This little helper function turns `setTimeout` into a promise returning function that resolves when a timeout is completed. Since the await syntax we used above awaits promises, this allows us to write a succinct delay code.

Let's see if our application works! Run the following from the project root to test:

```sh
node index.js
```

You're output should be similar to this:

```text
time for bed wavded.local
😴
💤
```

Exciting right?! Don't answer that.

Now that we have an application to play with, let's look at a few more tools you likely use in day-to-day development and how they translate when using Babel.

# Testing Babel code

Let's add a test for our sleep utility we developed in the last section. Inside _modules/utils/**tests**/sleep-test.js_, add the following:

```javascript
import test from 'blue-tape'
import sleep from '../sleep'

test('sleep', async function (t) {
  let start = Date.now()
  await sleep(20)
  let end = Date.now()
  t.ok(end - start >= 20, 'takes about 20 milliseconds')
})
```

Notice how we are using `async/await` and ES6 syntax in our test suite just like in our application code. Let's add the following script to our _package.json_ file in order to run this:

```json
"scripts": {
  "test": "babel-tape-runner \"modules/**/__tests__/*-test.js\""
}
```

Now we can run:

```sh
npm test
```

And we will get the following output:

```text
TAP version 13
# sleep
ok 1 takes about 20 seconds

1..1
# tests 1
# pass 1

# ok
```

Groovy. We can use Babel for tests as well as application code.

# Linting Babel

Let's turn to our _.eslintrc_ file next and add the following:

```json
{
  "extends": "standard",
  "parser": "babel-eslint",
  "env": {
    "node": true,
    "es6": true
  },
  "emcaFeatures": {
    "modules": true
  }
}
```

1. The `extends` line hooks up JS Standard rule definitions.
2. The parser line tells `eslint` to use the `babel-eslint` for parsing instead of the default parser allowing us to parse experimental JavaScript features.
3. The `env` lines let `eslint` know that we are using Node and ES6 features.
4. By default the `es6` environment enables all ES6 features except modules, so we enable that as well in the `ecmaFeatures` block.

Let's add a script to our _package.json_ file for linting.

```json
"scripts": {
  "test": "babel-tape-runner \"modules/**/__tests__/*-test.js\"",
  "lint": "eslint modules index.js"
}
```

And we then can run:

```sh
npm run lint
```

Which will give us no output currently as there aren't any linting errors.

# Running Babel in production

Our _index.js_ is handy for running Babel in development as its all in-memory and we don't need a manual compilation step. However, that isn't ideal for production for a couple reasons:

1. Start up times are slower as the code base needs to be compiled in-memory first. Time increases with larger code bases.
2. Second is that "in-memory" bit. We will have extra memory overhead if we do it this way; it will vary depending on the project size and dependencies.

We can add a build step for production that can be run before publishing to npm or as part of continuous integration. Let's add a couple more scripts to our _package.json_ file:

```json
"scripts": {
  ...
  "clean": "rm -rf build || true",
  "build": "npm run clean && cp -rf modules build && babel --optional runtime -d build ./modules"
}
```

1. The clean script just cleans out our previous build.
2. The build script compiles the app. First, it cleans. Then, it copies any assets (including any _.json_ files) to the build directory so they can be referenced properly. Finally, it runs the babel command to build all the JavaScript files in modules and puts the output in the build directory.

We also include an additional configuration option for Babel called runtime. The runtime optional won't pollute the global scope with language extensions like the polyfill that is used when called `require('babel/register')` above. This keeps your packages playing nice with others.

Let's try a build by running:

```sh
npm run build
```

You should get the following output referring the compiled files:

```text
modules/index.js -> build/index.js
modules/utils/__tests__/sleep-test.js -> build/utils/__tests__/sleep-test.js
modules/utils/sleep.js -> build/utils/sleep.js
```

Now we can run our pre-compiled version with the following command:

```sh
node build
```

And we should get the same output as we did when we ran in development.

Now that we've done a build, poke around at the files in the _build_ directory and see how they compare with the originals.

# Source maps in production

Although `loose` mode (which we enabled in the _Configuring Babel_ section above) will generate cleaner and faster output, you may still want to use source maps in production. This allows you to get at the original line numbers in stack traces. To do this, change your `babel` command to:

```sh
babel --source-maps inline --optional runtime -d build ./modules
```

You will also need the `source-map-support` package in npm in order for proper stack traces to appear in your error messages.

```sh
npm install source-map-support -S
```

To enable, add the following at the top of _build/index.js_

```javascript
require('source-map-support')
```

# Wrapping up

Babel allows you to write ES6 and beyond today and have it work across different versions of Node and also work across different browsers on the client side (see <http://www.2ality.com/2015/04/webpack-es6.html> for an example). The most exciting thing for me that has been a joy to work with is universal JavaScript applications that share most of their code and then I get to write it in ES6.

# PS: Syntax and Babel

Let's quickly talk about your text editor before we go shall we? Lots of the new constructs won't be highlighted properly when you start using Babel. Thankfully, the community has rocked this one and you should definitely switch if you haven't as a lot of these have good support for things like [JSX][9] and [Flow][10].

1. [Sublime Text][11]
2. [Atom][12]
3. [Vim][13]
4. [Emacs][14]

[1]: https://dogescript.com/
[10]: http://flowtype.org/
[11]: https://github.com/babel/babel-sublime
[12]: https://atom.io/packages/language-babel
[13]: https://github.com/pangloss/vim-javascript
[14]: https://github.com/mooz/js2-mode
[2]: https://github.com/es-shims/es5-shim
[3]: https://babeljs.io
[4]: https://en.wikipedia.org/wiki/Source-to-source_compiler
[5]: https://github.com/google/traceur-compiler
[6]: https://github.com/strongloop-community/babel-example
[7]: https://babeljs.io/docs/usage/api/#options
[8]: https://github.com/tc39/ecmascript-asyncawait
[9]: https://facebook.github.io/react/docs/jsx-in-depth.html
