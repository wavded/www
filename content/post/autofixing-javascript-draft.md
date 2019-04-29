---
commentURL: ''
date: 2019-04-20T21:00:53.000Z
ibmURL: >-
  https://developer.ibm.com/node/2016/07/27/auto-fixing-formatting-your-javascript-with-eslint/
tags:
  - linting
  - javascript
  - nodejs
title: Auto-fixing & formatting your JavaScript with ESLint
draft: true
---

When it comes to analyzing JavaScript program errors, [ESLint][2] is one of the best [linting][1] tools available. ESLint provides checks for a large set of potential errors and style violations. Its pluggable architecture also enables anyone to write their own rules and custom configurations.

One of my favorite features is the [ability to auto-fix][3] using the `--fix` flag. Integrating auto-fix provides constant feedback by cleaning up mistakes and keeping code clean before you check it in to a repository. This saves time for you and your team when reviewing code by ensuring that the code contributed doesn't require little clean ups.

I like to do this cleanup right away whenever I save a file in my editor. It provides a quick feedback loop and persists the fixed changes to disk. In this article, I am going to show you how to do that as well for some popular editors.

{{< figure src="/_media/autofix-2.gif" >}}

> Note: This is not a tutorial on how to use ESLint, I assume you already are familiar with the tool. If you need help getting started with ESLint, check out the [Getting Started guide][12] first before continuing.

# Installing ESLint

You can install ESLint locally for a given project (inside `node_modules`) or globally for all projects. We will use a local ESLint install for this tutorial, but most of these will work for a global install as well.

```sh
npm install eslint --dev
```

# VS Code

For VS Code, install the [ESLint][10] package. Then, to format on save, go to global settings and search for `ESLint` and turn on the `ESLint: Auto Fix On Save` option.

# Atom

For Atom, install the [`linter-eslint`][7] package and any dependencies. Then, go to the plug-in settings and check `Fix errors on save`.

# Sublime Text

For Sublime, using Package Control, install the [ESLint-Formatter][9] package. Then, to format on save, add the following to the `Preferences -> Package Settings -> ESLint-Formatter -> Settings -- User` file:

```json
{
  "format_on_save": true
}
```

# Vim/NeoVim

For Vim users, add the [`ale`][4] package using your preferred packaging tool like [`vim-plug`][5] or [`Vundle`][6] to your `$MYVIMRC`:

```vim
" vim-plug
Plug w0rp/ale
" Vundle
Plugin w0rp/ale
```

Then, enable auto-fix on save by setting the following configuration:

```vim
let g:ale_fixers = {}
let g:ale_fixers.javascript = ['eslint']
let g:ale_fix_on_save = 1
```

# Other editors

If your editor is not represented above, there may be an [integration already][11] or a way to use the [`eslint` command][3] directly to achieve a similar effect.

For example, the Vim plug-in will run something like the following:

```sh
eslint -c <path-to-config> --fix <path-to-current-file>
```

Then, reload the file in the buffer.

Happy auto-formatting!

[1]: https://en.wikipedia.org/wiki/Lint_%28software%29
[2]: http://eslint.org/
[3]: https://eslint.org/docs/user-guide/command-line-interface#fixing-problems
[4]: https://github.com/ruanyl/vim-fixmyjs
[5]: https://github.com/junegunn/vim-plug
[6]: https://github.com/VundleVim/Vundle.vim
[7]: https://github.com/AtomLinter/linter-eslint
[8]: http://eslint.org/docs/user-guide/command-line-interface
[9]: https://packagecontrol.io/packages/ESLint-Formatter
[10]: https://github.com/Microsoft/vscode-eslint
[11]: https://eslint.org/docs/user-guide/integrations
[12]: https://eslint.org/docs/user-guide/getting-started
