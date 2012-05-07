---
layout: post
title: fear of a new line
comments: "https://github.com/jmettraux/jmettraux.github.com/commit/4b7dadbc8e5ae563fcb9b84efd4088ab03ca49c1#comments"
---

A friend made me a compliment the other day, describing my code as "clean". I was fortunate to discover he referred both to its immediate appearance and to its structure.

This post details the "style" as in "Ruby style guide" I'm following/expressing. Writing a blog post about the rest, the patterns, the design essence, this is too much for a blog post and, well, I still have much to learn.

This post is split in three parts: "context", "conduct" and "content". The tools I use and how I hold them is "context", "conduct" is about the general rules I follow regarding style as a programmer, and "content" refers to the syntax rules.

This writing is not about convincing someone that my style is better. It's mostly a justification. It comes as a snapshot, May 2012, and it will probably look a bit different in a year or two.

I cannot use this style in every project I'm on. When joining a project I follow the style already in place. When starting a new project it's mostly the style of the house (official or implied). My open source projects is where this style blooms.


## context ##

I'm one of those "UNIX is my IDE" bums, I'm using [Vim](http://vim.org), [iTerm2](http://iterm2.com/) and a browser.

<img src="images/2012-05-07-screenshot.png" style="width: 100%" />

Left is for output and documentation; right is for input.

Whatever the screen estate, I work on code in 80 columns. I avoid line wrapping, I'm not afraid of starting new lines and I don't do vertical alignment, except for indentation.


## conduct ##

I try to be consistent and readable, whatever the style guide.

Consistent in following my style rules or the style rules given for the project all the time.

I [re-]read my code a lot, so I have a direct interest in it being readable. Most of the time, my eyes fly, scan, forgetting the syntax and trying to feed the bigger picture upstream.

Scanning stops on:

{% highlight ruby linenos %}
[ 'alpha', 'bravo', 'charly'].each do |name|
  update(name,3, 'new batch')
end
{% endhighlight %}

Why the space after `[` and not before `]`? Why the lack of space before `3`?

This code was not re-read, it was carelessly committed. In what other, less obvious, ways could it be inconsistent?

There is also that boy-scout rule that says I'm supposed to leave the place cleaner than I found it. I would thus have to rewrite to

{% highlight ruby linenos %}
[ 'alpha', 'bravo', 'charly' ].each do |name|
  update(name, 3, 'new batch')
end
{% endhighlight %}

or

{% highlight ruby linenos %}
['alpha', 'bravo', 'charly'].each do |name|
  update(name, 3, 'new batch')
end
{% endhighlight %}

depending on the style guide of the place.

Beware: the boy-scout rule does not say "Hey, let me reformat all of your code base following my style!"


## content ##

I found that the [Github styleguide for Ruby](https://github.com/styleguide/ruby) is a solid foundation. To spare me some typing I'll list zones with differences, anything not covered here follows the Github styleguide.

{% highlight ruby linenos %}
# Use soft-tabs with a two space indent.

# Keep lines shorter than 80 characters.

# Never leave trailing whitespace.
{% endhighlight %}

I love those three rules, very easy to follow.

{% highlight ruby linenos %}
# Use spaces around operators, after commas, colons and semicolons,
# around { and before }.

# Use spaces after [ and before ] if they're enclosing the elements of
# an array. No spaces if it's an index.

a = [ 'alpha', 'bravo', 'charly' ]
h = { 'a' => 2, 'c' => 3 }
puts a[1]
puts h['a']

sum = 1 + 2
a, b = 1, 2
1 > 2 ? true : false; puts 'Hi'
[ 1, 2, 3 ].each { |e| puts e }
some(arg).other
[ 1, 2, 3 ].length
{% endhighlight %}

When square brackets are involved I like to distinguish immediately indexes from arrays. Arrays get as much aeration as hashes.

{% highlight ruby linenos %}
# Indent when inside of case

case
  when song.name == 'Misty'
    puts 'Not again!'
  when song.duration > 120
    puts 'Too long!'
  when Time.now.hour > 21
    puts "It's too late"
  else
    song.play
end
{% endhighlight %}

I like when the case and its end are alone on their vertical.

{% highlight ruby linenos %}
# No over indentation (and no fear of the new line)

kind = case year
  when 1850..1889 then 'Blues'
  when 1890..1909 then 'Ragtime'
  when 1910..1929 then 'New Orleans Jazz'
  when 1930..1939 then 'Swing'
  when 1940..1950 then 'Bebop'
  else 'Jazz'
end

category = if post.year > 2011
  'modern'
elsif %w[ car bike ].include?(post.tag)
  'motorsports'
else
  post.category
end

def that_long_method_with_many_args(
  number_of_people,
  captain_age,
  seat_count,
  location=nil)

  # method body...
end
{% endhighlight %}

I don't like hitting space too much, and I don't like feeding complex vertical alignement rules to my editor.

{% highlight ruby linenos %}
# Use empty lines between defs and to break up a method into logical
# paragraphs.

class Something

  def some_method

    data = initialize(options)
    data.manipulate!

    data.result
  end

  def some_method

    result
  end
end
{% endhighlight %}

Music isn't only sounds, it's also the silence between the sounds. Those blank lines help me distinguish class and method signatures from the rest. Those signatures are so important.

{% highlight ruby linenos %}
# When a method has multiple lines and an implicit return, separate the return
# from the rest of the body with an empty line

class Cart

  def total

    items = fetch_items
    prices = fetch_prices

    items.inject(0) { |i, t| t + i.count * prices[i.id] }
  end

  def empty!

    delete_items
    cancel_session
  end
end
{% endhighlight %}

That single line is a return at the end of `total` is a return. `empty!` on the other hand isn't supposed to return anything, so I do not emphasize the implicit return.

{% highlight ruby linenos %}
# Make sure there is an empty line after a class, module or method definition
#
# (I spend a lot of time considering method signatures, I don't want the first
# line of the body to interfere)

# public, protected and private are indented as much as the def
# in the class body, there is one empty before and after those keywords

class Cart

  def empty!

    # ...
  end

  protected

  def fetch_items

    # ...
  end
end
{% endhighlight %}

The keyword applies not just for the method that follows.

{% highlight ruby linenos %}
# favour method-wide rescue blocks

def total

  items = fetch_items
  prices = fetch_prices

  items.inject(0) { |i, t| t + i.count * prices[i.id] }

rescue MyError => me
  # ...
ensure
  # ...
end

# The space after the implicit return line is here to separate that return
# from the rescue signature
{% endhighlight %}

An influence from [http://exceptionalruby.com/](http://exceptionalruby.com/), it makes for shorter, well decoupled, methods.

{% highlight ruby linenos %}
# Use %w[] (not %w{}, it's about arrays after all)

a = %w[ alpha bravo charly ]
{% endhighlight %}

Square brackets, with spaces, are for arrays.

{% highlight ruby linenos %}
#1 + 2 + 3 # this is commented out code

# this is a comment
{% endhighlight %}

I see nothing wrong with some commented out code. It's useful when detailing a design decision (the failed solution is commented out).

Note the mandatory space between the # and the text in the comment, no space for commented out code.

{% highlight ruby linenos %}
#
# I go for a blank comment line on top of class comments
#
class Car

  #--
  # Hide comments from rdoc and co
  #++

  # No blank comment line on top of method comments
  #
  # A blank comment line before the method signature
  #
  def plus(x)

    @local + x
  end

  # Another method.
  #
  def difference(i)

    x = @val - plus(i)
      # I like trailing "post comments" for one-liners

    y = compute_this_value
    z = compute_that_value + compute_that_diff
      #
      # sometimes I use such "down flags" for post comments of blocks of code

    x + y + z
  end
end
{% endhighlight %}

I have co-workers that dislike the last two kind of comments, but I find, that if you step back one pace, they look good and fit their explanative, post, purpose.

Stepping back one pace, always a good technique.

{% highlight ruby linenos %}
def dance_to(tune)

  if tune.fast?
    change_shoes
  end
  if tune.fashionable? && @dance_floor.crowded? && Hour.now > 1900
    change_dress
  end

  # ...
end
{% endhighlight %}

Speaking of stepping back one pace, the change_shoes could have become a one liner, but I prefer to make it a regular `if` like the change_dress that follows. Those two ifs are about pre-dance adjustments, so I format them the same.

I try to format functionally similar statements in the same way.


## conclusion ##

So this is my style. There are many blank lines and spaces in it, but I use them to make it easier for my eyes to separate code blocks and signatures.

I care about the code I write and thus re-read it a lot, therefore I'm strict with my formatting and its consistency.

I'm not on a crusade against fellow programmers who have a different sense of consistency. I know they can teach me a lot.

&nbsp;

_(many thanks to [Justin Gaylor](http://www.justingaylor.com) for all his help correcting and editing this post)_

