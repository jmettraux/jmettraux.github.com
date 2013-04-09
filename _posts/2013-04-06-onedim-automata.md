---
layout: post
title: onedim cellular automata
comments: "https://github.com/jmettraux/jmettraux.github.com/issues/6"
---

"There are a bunch of small worlds, from above, they look like circles, from a level point of view, they look somehow like [ 0 1 0 0 1 0 1 0 ]"

I started my mini-talk at [Hiroshima.rb #31](http://hiroshimarb.github.io/blog/2013/04/06/hiroshimarb-31/) by writing 0s and 1s on the whiteboard.

I'm reading [Complexity, a guided tour](http://www.amazon.com/Complexity-Guided-Tour-Melanie-Mitchell/dp/0199798109) by [Melanie Mitchell](http://web.cecs.pdx.edu/~mm/) and it features those one dimensional cellular automata, of [Wolfram fame](http://mathworld.wolfram.com/Rule110.html). I first read about them a while ago, in another excellent book [Le Peuple des Connecteurs](http://www.amazon.fr/Le-peuple-connecteurs-n%C3%A9tudient-travaillent/dp/2849410381) (sorry, french).

Since it's a Ruby meetup, I went on and implemented a tool for running those rules in Ruby. It's called OneDim, it's there, [archived](https://github.com/jmettraux/onedim) in GitHub.

<img src="images/2013-04-06-output.png" />

I wanted to show how I went from the initial problem, and helped by test-driven development, I iterated to a solution. Doing it with [Conway's game of life](http://en.wikipedia.org/wiki/Conway's_Game_of_Life) is a [favourite of Rubyists](http://www.rubyinside.com/screencast-coding-conways-game-of-life-in-ruby-the-tdd-way-with-rspec-5564.html). It's simpler with one-dimension cellular automata.

Live coding is a bit difficult, instead of inflicting pain on the audience at each keystroke, I simply iterated over the git history of the project. I used a small [gmo](https://github.com/jmettraux/onedim/blob/master/misc/gmo) script to do the navigation, "gmo next" to move to the next commit. (Warning: gmo does reset --hard when switching commits).

<img src="images/2013-04-06-gmo.png" />

That's all.

