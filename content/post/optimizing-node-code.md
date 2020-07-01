---
title: Profiling slow code in Node.js
date: '2019-06-01'
ibmURL: ''
tags:
  - performance
  - optimization
  - nodejs
---

Let's set the scene. An alert comes in, and it looks like CPU usage is high for one of your Node applications. The support team just received a call from one of your clients. You restart the application to hopefully get clients back up and running but sure enough, the CPU is climbing again. Looks like someone or something stumbled into a _hot path_, a highly trafficked path, in the code. What do you do? Why is it slow?

Take a deep breath, you can do this. Node has some built-in tools at your disposal.

> Avoiding heavy CPU usage is important for servers due to Node's single-threaded nature. Time spent on the CPU takes time away from servicing other requests. If your application is slow to respond and the CPU runs consistently higher for the process, profiling your application will help find bottlenecks. Result? Your program is back to a speedy state.

In this article, we'll focus on debugging applications in a remote environment (such as a staging or production server). However, these concepts also work in a local environment.

# Profiling using the --inspect flag.

First, start the application with the `--inspect` flag:

```sh
node --inspect myapp.js
```

This enables remote debugging by opening up a debugging port bound to `127.0.0.1:9229` on the remote server[^1].

Then, on your local machine, tunnel to the debugger using SSH:

```sh
ssh -N -L 9229:localhost:9229 name-or-ip-of-remote-server
```

We use an [SSH tunnel][1] because we bound our debugger to `127.0.0.1` (localhost) on the remote server. This security measure limits the scope of who can access the debugging port to those with access to the remote server itself.

Now, we are ready to start inspecting. Launch Google Chrome and head to `chrome://inspect/#devices` and click on `Open dedicated DevTools for Node`. You should see a screen like this:

{{< figure src="/_media/profiling-1.png" title="Figure A" >}}

Ensure you have `localhost:9229` listed; if not, click `Add connection` to add it. Then, head to the `Profiler` tab.

{{< figure src="/_media/profiling-2.png" title="Figure B" >}}

Here, select your application under `Select JavaScript VM instance` and click `Start` to begin profiling. While profiling, your application may take a slight performance hit - so keep that in mind. After some time, click `Stop` to finish profiling and look at the output.

Now, analyze the output using the Chrome Developer Tools, inspect the code and even test changes without starting the server.

# Profiling using inspector module.

Using the `--inspect` flag requires you to restart your application to enable or run your applications with the flag already enabled, awaiting an issue. But there is another way you can approach the problem: use the built-in [`inspector`][3] package.

Let's look at a module to include in your application that runs a profiler for the provided `seconds` when triggered. This technique won't expose a debugging port; instead it uses the [DevTools Protocol][2] directly:

```js
// runProfiler.js
const inspector = require('inspector')
const util = require('util')
module.exports = runProfiler

let session = new inspector.Session()
session.connect()

let post = util.promisify(session.post.bind(session))
let delay = ms => new Promise(res => setTimeout(res, ms))
let profilerRunning = false

async function runProfiler(seconds) {
  if (profilerRunning) {
    throw new Error('Profiler already running, try again later')
  }
  profilerRunning = true
  let profile

  try {
    await post('Profiler.enable')
    await post('Profiler.start')
    await delay(seconds * 1000)
    profile = (await post('Profiler.stop')).profile
  } catch (er) {
    console.error('Profiler error:', er)
  } finally {
    await post('Profiler.disable')
    profilerRunning = false
  }

  return profile
}
```

Since this is a programmatic API, you can trigger it however and whenever you'd like. Let's look at a couple examples. The first is sending the process a signal. Here we use the `SIGUSR2` signal to profile 30 seconds of data and write the profile to the current working directory of the application.

```js
const runProfiler = require('./runProfiler')
const fs = require('fs')
const util = require('util')

let writeFile = util.promisify(fs.writeFile)

process.on('SIGUSR2', async () => {
  try {
    let profile = await runProfiler(30)
    let fn = `./profile_${Date.now()}.cpuprofile`
    await writeFile(fn, JSON.stringify(profile))
    console.error('Profile written to', fn)
  } catch (er) {
    console.error('Profiler error:', er)
  }
})
```

If you are running a web server (like Express), you can expose a private endpoint to take a profile as well. This will download a 30-second profile when accessing the endpoint.

```js
const runProfiler = require('./runProfiler')

// Express route. Make sure to lock this down from public access!
app.get('/_profile', async (req, res) => {
  try {
    let profile = await runProfiler(30)
    res.attachment(`profile_${Date.now()}.cpuprofile`)
    res.send(profile)
  } catch (er) {
    res.status(500).send(er.message)
  }
})
```

Once you have your `.cpuprofile` file, load that up inside the Chrome Developer Tools for Node by clicking the `Load` button on the `Profiler` tab (see **Figure B** above).

## Inspecting using the inspector module

The inspector package allows you to programmatically start up and shut down a debugging port as well. Here is a module that essentially toggles on and off `--inspect` flag when sent a `SIGUSR2` signal:

```js
const inspector = require('inspector')
let inspectorRunning = false

async function toggleInspector() {
  if (inspectorRunning) {
    inspector.close()
    console.log('Inspector closed')
    return
  }
  inspector.open()
  inspectorRunning = true
  console.log('Inspector running on 127.0.0.1:9229')
}

process.on('SIGUSR2', toggleInspector)
```

[1]: https://en.wikipedia.org/wiki/Tunneling_protocol
[2]: https://chromedevtools.github.io/devtools-protocol/v8/Profiler
[3]: https://nodejs.org/dist/latest/docs/api/inspector.html

# Other options

We looked at two build-in methods for profiling applications in Node: the `--inspect` flag and the `inspector` module. There are some other alternatives you may interested in:

- [Built-in V8 profiler](https://nodejs.org/en/docs/guides/simple-profiling/)
- [Flame graphs with perf](https://nodejs.org/en/docs/guides/diagnostics-flamegraph/)

Let's set a new scene: the alert comes in but now you have a plan to diagnose the unexpected CPU load. By using valuable profile information, you are already on your way to understanding the problem better to make a fix.

[^1]: If you need another address, you can use `--inspect=[host:port]`. Do not use `0.0.0.0` as a host though, as it could expose your debugger to the Internet.
