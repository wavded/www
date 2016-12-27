---
date: 2011-08-07T15:00:53-06:00
tags: ["gedit","vim","text-editing"]
title: "My text editor journey (so far)"

---

I used to be a die-hard Windows guy. In fact, in Middle School, I remember advocating (e.g. doing class presentations) that Windows was indeed better than Mac. Kinda funny now since I’d take a Mac over Windows… but ultimately I choose Linux over both. At the moment it is [ArchLinux](http://archlinux.com/). All that to say, things change! Like OSes, I’ve changed my tune with what I use to write code.

## NetBeans

When finally got a _real_ programming job, the IDE I was indoctrinated into was [NetBeans](http://netbeans.org/). I came from an Eclipse world in college so NetBeans wasn’t a far stretch and I kinda liked it better from a GUI perspective. I was the front-end guy and at the time, there wasn’t much good support for JavaScript, CSS, or HTML as web applications were kind of a newer way to work with JAVA. Thankfully, now all those technologies are much better supported in recent versions of NetBeans.

## gedit

[Ruby on Rails](http://rubyonrails.com/) ruined me for Windows because lets be honest, the command line sucks, and many operations required it, plus Ruby windows support is _meh_, so I tried out Linux. Oddly enough, I never continued to dive more into Ruby but I did stick with Linux. I was doing PHP more than JAVA and NetBeans was bulky, simple operations just took long. The overall IDE was sluggish.

Enter gedit: the stock Gnome text editor with a some very powerful features, unlike your stock Windows text editor :). I also was utilizing git more and writing bash scripts so having a terminal window along with my editor was more and more important. Thankfully, gedit had a built-in embedded terminal plugin and some great community plugins enhancing it to include many features TextMate users have come to love. After setting it up, I was far more productive than in NetBeans. What I liked better was:

*   Removal of a lot of cruft.
*   Fast.
*   Embedded Terminal.
*   Great Community Plugins (themes, autocomplete, snippets, quick loading, syntax support, easy to write syntax files)

## vim

So there comes this point when I just really want to switch things up. I knew Vim was really powerful as a text editor but I just didn’t get why. It was the most awkward experience just getting used to it the first time…

> How to I just type something! How do I quit! Nothing is familiar here!

Plus the fact that it was all… well… terminalish. I wanted to use the mouse man! I wanted it to look pretty!

Thankfully there was some help for people like me and the fact that there was a GUI version bundled in (GVim). Getting that setup brought some warm fuzzies but really I had to bite the bullet. This meant I had to remove Gedit (my safe place) and force myself to only use Vim for a couple weeks to give it a fair shot (I highly recommend this). And note, I was not productive like I was before. I had to be OK with being slow and awkward for a while.

I went through `vimtutor` and started watching [video](http://www.derekwyatt.org/vim/vim-tutorial-videos/) [tutorials](http://vimcasts.org/). I even had an iPhone app w/ Vim flashcards to memorize the [key-mappings](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html). I also read a lot of the Vim help (`:h`) which is quite readable and informative.

The result… I absolutely love it and would not go back, why?:

### Modal Editing

Modal editing makes so much sense once you get used to it, you not only get to use your whole keyboard to insert text, you get to use it also to manipulate text. For example. Say you want to select everything within double quotes and replace it. This happens more than you think when dealing with strings. How would you do this normally? Here’s one way:

_Select the text with your mouse, clicking the start and dragging to the end of the text and then hitting delete._ Seems easy enough right but look at what actually is happening from an efficiency standpoint. You remove your hand from the keyboard to grab your mouse, you click and hold the mouse making sure you clicked the right spot and then you drag your mouse making sure you land on the other spot correctly. Then, you remove your hand from the mouse, find home row (or don’t), and type `backspace`.

Or if you are more keyboard savvy, you may do put your cursor on the starting letter, hold down shift and cursor over to the ending word and hit backspace but its awkward and requires many keystrokes. The point is, most editors have only one mode, _insert_, and all your keys are used only for that purpose.

In Vim, you can do this task really easy. In normal mode, if your cursor is anywhere within the quoted string, just type `ci"` which is pneumonic for ‘change inside double quotes’. Vim will delete all everything in the quotes, put you in insert mode, and you can start typing your replacement.

This is just one example of many where time is saved on common tasks because of modal editing.

### Community

Vim has a great community and rich set of plugins. I am not about to write a tutorial so I will stop myself from going into other features I love. If you are interested, feel free to checkout out my vim config. It is mostly setup for JavaScript/CoffeeScript and NodeJS development.

### So Long GUI

I’ve sinced moved out of the GVim and run vim strictly in the terminal in conjunction with [tmux](http://tmux.sourceforge.net/).
