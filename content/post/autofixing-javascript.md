---
commentURL: ''
date: 2016-08-27T21:00:53.000Z
strongloopURL: >-
  https://strongloop.com/strongblog/auto-fixing-formatting-your-javascript-with-eslint/
tags:
  - linting
  - javascript
  - nodejs
title: Auto-fixing & formatting your JavaScript with ESLint
---

[Linting][1] is the process of running a program that will analyze your code for potential errors. A lint program does this by using a set of rules applied to your code to determine if any violations have occurred.

When it comes to analyzing JavaScript program errors, [ESLint][2] is the best linting tool available today. Not only does it include a large set of rules for potential errors and style violations. It is also pluggable which enables anyone to write their own rules and custom configurations.

However, my favorite feature is the [ability to auto-fix][3] using the `-fix` flag. Integrating auto-fix provides constant feedback by cleaning up mistakes and keeping code clean before you check it in to a repository. If you are involved in an open source project, it also saves time by ensuring that the code you contribute doesn't require clean up or other work from other contributors.

I like to do this cleanup by saving a file in my editor as it provides a quick feedback loop and persists the fixed changes to disk. In this article, I am going to show you how to do that for a few popular editors. Here is the endgame:

{{< figure src="/_media/autofix.gif" >}}

# Installing ESLint

You an install ESLint locally for a given project or globally for all projects on a system. We will focus on using a global ESLint for this tutorial, but note that many of these plug-ins support a local install as well.

First, install ESLint globally:

```sh
npm install -g eslint
```

# Vim/Nvim

For Vim users, just add the [`fixmyjs`][4] package using your preferred packaging tool like [`vim-plug`][5] or [`Vundle`][6]:

```vim
" Plug
Plug ruanyl/vim-fixmyjs
" Vundle
Plugin ruanyl/vim-fixmyjs
```

# Sublime Text

For Sublime, using Package Control, install the ESLint-Formatter package. Then, to format on save, add the following to the Preferences -> Package Settings -> ESLint-Formatter -> Settings -- User file:

```json
{
  "format_on_save": true
}
```

# Atom

For Atom, install the [`linter-eslint`][7] package. Then, configure it like this:

{{< figure src="/_media/atom-autofix-config.png" >}}

> Note that this assumes your global Node installation is at `/usr/local` which is typical, but not always the case. Run `npm get prefix` and paste that value into this field if ESLint cannot be found.

# Other editors

If your editor is not represented above, there may be a plug-in or a way to use the [`eslint` command][3] directly to achieve a similar effect.

For example, the Vim plug-in will run the following:

```sh
eslint -c <path-to-config> --fix <path-to-current-file>
```

Then, reload the file in the buffer.

Happy auto-formatting!

[1]: https://en.wikipedia.org/wiki/Lint_%28software%29
[2]: http://eslint.org/
[3]: http://eslint.org/docs/user-guide/command-line-interface
[4]: https://github.com/ruanyl/vim-fixmyjs
[5]: https://github.com/junegunn/vim-plug
[6]: https://github.com/VundleVim/Vundle.vim
[7]: https://github.com/AtomLinter/linter-eslint
[8]: http://eslint.org/docs/user-guide/command-line-interface
