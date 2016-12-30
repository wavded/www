---
title: Writing modular Node projects for Express and beyond
date: "2014-10-21T16:49:04-06:00"
strongloopURL: https://strongloop.com/strongblog/modular-node-js-express/
tags: ["express", "nodejs"]

---

I have worked with Express for over four years now and I cannot count how many different ways I have reorganized my code!  Express bills itself as an unopinionated framework.  This is true.  If you search for "express boilerplate" you will find a **lot** of different ways to organize your project.

In my experience, there isn't "one best way" to structure a project.  If you are looking for that, you probably won't find it. That's not to say there aren't things that work better than others.

In this article, I propose a minimal and flexible pattern that I think works well for projects that are larger or have the potential for growth.  The original ideas stem from earlier work done by [TJ Holowaychuk](http://vimeo.com/56166857).  As you read through the explanation and implementation, note the discussion really has little to do with Express directly and applies to any large Node project.

## Modularizing the code base
It's hard to anticipate how a code base will grow and change.  An application needs the flexibility to adapt and enough isolation between components to enable code reuse and lessen cognitive overhead.

A modular structure understands that you *won't* have complete isolation between the components.  There will be overlap and that's OK and sensible[^1].  A modular structure then:

1. Enables an application to be separated into smaller components.
2. Permits components to have their own dependencies (and tests) that can be updated with minimum to no effects on other components.
3. Allows project-wide dependencies that can be shared (or overwritten) by individual components.
2. Makes requiring components first-class.  In other words, does not use relative `require` statements.
3. Empowers an application to grow (or shrink) without a lot of reshuffling.

The Node mantra of small npm modules is carried over then into small components.

## The minimal modular structure
Here is a base structure that is as minimal and unopinionated as I could make it:

```sh
.
├── lib/
├── bin/
├── package.json
└── index.js
```
	
Let's break down the intent of each item:

1. *bin*: anything that doesn't fit nicely inside of an npm script (e.g. hooks, CI, etc.)
2. *lib*: the components of the application
3.  *package.json*: project-wide dependencies and npm scripts
4. *index.js*: initializes the application

We will touch on each of these pieces as we continue.

## Adding components
A component is any aspect of a project that can stand alone.  For example, one component could be dedicated to scheduling cron tasks, another to sending emails, and another to an export tool.  In terms of data, you could have one component dedicated to all your models or a separate component for each model[^2]. 

We then add our components to the *lib* directory:

```sh
.
└── lib
    ├── app
    │   ├── index.js
    │   └── package.json
    ├── logger
    ├── config
    └── models
```

Each of these components has an entry point (typically *index.js*) and may have its own `package.json` (`npm init -y`) if dependencies or local npm scripts are required.

In this example, my *app* component needs Express, so I `npm install --save express` in that directory.  In the *logger* directory, I install my favorite logging module, configure it how I want and only expose what the other components will need.  The `config` directory, in this case, contains environment-specific project configuration that most other components use.  Of course, these are sample components I typically have, you may have a completely different set.

### Making components first-class
Components should be first-class in your application, meaning they are easily accessible anywhere.  Therefore, you should never have to calculate relative paths to use them:

```js
var logger = require('../../../logger')
```

Herein lies a simple trick that works on UNIX and Windows.  Add a symbolic link to the project's `node_modules` folder[^3].  In UNIX, this is:

```sh
cd {project_root}/node_modules
ln -s ../lib _
```
	
In Windows, it is:

```sh
cd {project_root}/node_modules
mklink /D _ ..\lib
```

In this example, I'm calling the link a minimal  `_` (you can call it whatever).  Now, I can require components like this anywhere in my project:

```js
var log = require('_/logger')
```

### Sharing dependencies

This structure also allows you to share dependencies whenever it makes sense.  For example, say you use `lodash` in a lot of your components.  Just `npm install --save lodash` at the project root and it will be available to all components.

Although you can mix and match whatever makes sense, I typically keep most if not all dependencies local to each component.  This makes it easier and safer to update a component at a time.  It also is easier to break out a module and publish it for reuse in more than one project.

Utility tools that are typically used project-wide, I keep in the project root.  This includes tools like `nodemon` and `eslint`.
	
## Easy setup
The separation of components is nice, but it would be a pain to go into every component and `npm install` when, for instance, another developer is setting up the project.  To streamline this, add a little `preinstall.js` script to the *bin* directory.  This script simply visits every component and runs `npm install`:

```js
var fs = require('fs')
var npm = require('npm')
var path = require('path')

var libDir = path.resolve(__dirname,'../lib/')
var noop = function(){}

npm.load(function () {
  fs.readdirSync(libDir).forEach(function (mod) {
    npm.prefix = path.join(libDir, mod)
    npm.commands.install(noop)
  })
})
```

 Then, add it to your main `package.json` file in the `scripts` section:

```json
{
  "scripts": {
    "preinstall": "node bin/preinstall"
  }
}
```
Now, when we run `npm install` in the project root, all the components' dependencies also get installed[^4].

## Tests

A modular structure allows you to put tests either in each component:

```sh
.
└── lib
    └── app
        ├── test
        ├── package.json
        └── index.js
```

Or in the project root:

```sh
.
├── lib
└── test
    └── app
```

Depending how you have your test runner set up, one may make more sense than another.  You can also do both.  My preference as of late has been keeping tests local to components in order to develop components easier in isolation.

## A starting point

We haven't talked about *index.js* yet.  This one is simple.  It initializes the application.  In this example, the *app* component is the main entry point so *index.js* is simply:

```js
var cfg = require('_/config')
require('_/app').listen(cfg.port)
```

Sometimes, the main app setup isn't just listening on a port -- you may also want to schedule some cron tasks, log that the server has started, etc.  You can do that all in *index.js*.

## A full picture

If you are itching to see a full running example, I have [an Express project up on GitHub](https://github.com/strongloop-community/express-example-modular) demonstrating this modular structure.

[^1]: However, *when* it makes sense, breaking components into their own published packages has the added benefit of reusing code between projects.
[^2]: When working with ODM/ORM tools like Mongoose or Sequelize, I find having one *models* directory works nice.
[^3]: Another technique for making components first class is setting the NODE_PATH environment variable to be the path of the *lib* directory.  I find using symlinks preferable through as you never have to set the path when executing any file or starting your app and it allows you to have a component and an npm package with the same name.  For example, I can have a customized `_/redis` module which depends on the `redis` npm package.
[^4]: Setting up other scripts is trivial.  For updating, just change `npm.commands.install` to `npm.commands.update`.  Want to check if anything is outdated, just switch it to `npm.commands.outdated`.  See [npm API](https://www.npmjs.org/doc/api/npm.html) for more details.
