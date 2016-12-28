---
commentURL: ""
date: 2014-01-14T15:00:53-06:00
strongloopURL: "https://strongloop.com/strongblog/template-systems-in-node/"
tags: ["nodejs","templates","javascript"]
title: "Template systems in Node"
---

Regardless of your background in web development, you’ve likely used a [web template system](http://en.wikipedia.org/wiki/Web_template_system) (engine). The goal of a template system is to process templates (usually in combination with a set of input data) to form finalized web pages.

```sh
template(data) => final HTML
```

Although some engines are designed specifically for HTML output, many can be used to generate any type of a text output.

Node has a [rich ecosystem](https://npmjs.org/search?q=template) of template systems available. Since it is server-side JavaScript, many of these engines are built to work both on the client and server. The benefit: template reuse in your web applications.

> All the template systems mentioned in this article work both client and server side.

In this article, rather than boring you with a module by module synopsis (hint: we’d be here for a while), we will zoom out and look at the types of systems that are available and why you might choose one style over another depending on your needs.
<span id="more-11237"></span>

## Types of Template Systems

Node’s web template systems can be divided into four general approaches. They are:

1.  Embedded JavaScript
2.  Custom Domain Specific Languages (DSLs)
3.  Logic-less
4.  Programmatic

## Embedded JavaScript

Like the style of PHP, JSP, or ERB templates? Prefer working with vanilla JavaScript? If so, take a look at embedded JavaScript. At the core, these engines allow JavaScript code to be evaluated within a template. The most notable is [EJS](https://github.com/visionmedia/ejs), which looks a lot like PHP or JSP (except it uses JavaScript, of course):

```jsp
<% if (loggedIn) { %>
<a href="/account"><%= firstName %> <%= lastName %></a>
<% } else { %>
<a href="/login">Log In</a>
<% } %>
<ul>
  <% records.forEach(function (record, index) { %>
    <li><%=index%>: <%= record.title %></li>
  <% } %>
</ul>
```

In addition to embedded JavaScript, EJS templates include extras like partials and filters. One notable usage of EJS templates is the [npmjs site](https://npmjs.org/) ([GitHub](https://github.com/isaacs/npm-www)).

If you only need interpolation and evaluation in your templates (no extras like partials, filters, etc), check out the micro-templating provided in [Underscore](http://underscorejs.org/#template)/[Lo-Dash](http://lodash.com/docs#template). There also are [embedded CoffeeScript templates](https://github.com/sstephenson/eco).

## Custom Markup Languages

Writing vanilla JavaScript templates can get verbose and ugly with `<% } %>` code sitting all over the place. Here is where the world of custom [DSL](http://en.wikipedia.org/wiki/Domain-specific_language)s comes in. These languages vary widely on syntax. However, you’ll typically end up with cleaner templates and some extra goodies like mixins, filters, and inheritance. Let’s look at a couple examples.

[doT](http://olado.github.io/doT/) takes a minimalistic approach (it’s also built for speed):

```jsp
{{? it.loggedIn }}
  <a href="/account">{{= it.firstName }} {{= it.lastName }}</a>
{{??}}
  <a href="/login">Log In</a>
{{?}}
<ul>
  {{~ it.records :record:index }}
    <li>{{= index}}: {{= record.title }}</li>
  {{~}}
</ul>
```

To contrast, here is Jade’s indentation-based style:

```jade
if loggedIn
  a(href="/account") #{firstName} #{lastName}
else
  a(href="/login") Log In
ul
  each record in records
    li #{index}: #{record.title}
```

Many DSLs are implemented in multiple languages (e.g. Jade and [Haml](https://github.com/creationix/haml-js)). For instance, a PHP backend could share templates with Node backend. DSLs can be helpful for designers who work with templates because it doesn’t require them to learn a full-fledged language.

Some other notable libraries include [Swig](http://paularmstrong.github.io/swig/) and [Nunjucks](http://jlongster.github.io/nunjucks/).

## Logic-less

Logic-less templates, a concept popularized by [Mustache](http://mustache.github.io/), essentially prevent _any_ data massaging in the template itself. Although there are "logical" constructs provided (like if/then and iteration), any finessing of the data happens _outside_ the template. Why? The goal is to [separate concerns](http://stackoverflow.com/questions/3896730/whats-the-advantage-of-logic-less-template-such-as-mustache) by preventing business logic from creeping into your views.

Let’s take a peak at [Mustache](https://github.com/janl/mustache.js):

```html
{{#loggedIn}}
  <a href="/account">{{firstName}} {{lastName}}</a>
{{/loggedIn}}
{{^loggedIn}}
  <a href="/login">Log In</a>
{{/loggedIn}}
<ul>
  {{#records}}
    <li>{{title}}</li>
  {{/records}}
</ul>
```

Other popular template engines in this vein include [Handlebars](http://handlebarsjs.com/) and [Dust](http://linkedin.github.io/dustjs/); both add helpers to the base Mustache syntax. The Mustache parser, in particular, has been implemented for a [lot of languages](http://mustache.github.io/).

## Programmatic templates

The last style we will explore is programmatic. Unlike the previous styles, which add custom syntax to HTML, these modules augment plain HTML and/or build it from scratch with data. For example, [hyperglue](https://github.com/substack/hyperglue) processes plain HTML, like:

```html
<a></a>
<ul>
  <li></li>
</ul>
```

Then, by writing the following JavaScript code (using CSS selector syntax), it returns a populated HTML fragment:

```js
var fragment = hyperglue(html, {
  a: {
    href: loggedIn ? "/account" : "/login",
    _text: loggedIn ? firstName + ' ' + lastName : "Login"
  },
  'ul li': records.map(function (record, index) {
      return { li: { _text: index + ': ' + record.title } }
  })
})
console.log(fragment.innerHTML)
```

To expound more on this concept, check out [@substack’s article](http://substack.net/shared_rendering_in_node_and_the_browser). Other programmatic examples include [domjs](https://github.com/medikoo/domjs) and [Plates](https://github.com/flatiron/plates).

## Wrapping up

In this article, we looked at the types of template systems available for Node. In closing, here are some suggestions:

1.  If you are newer to Node template engines, start with something familiar to previous platforms you’ve used (in many cases this will be EJS). Then, branch out.
2.  Stuck in one style or one engine? Be brave, try another style. Learn its strengths and weaknesses.
3.  Need more help choosing a module for that next project? Garann Mean has setup a [great site](http://garann.github.io/template-chooser/) to help you.

Happy templating!
