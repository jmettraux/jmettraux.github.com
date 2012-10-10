---
layout: top
title: jmettraux.github.com
---

## misc

[@jmettraux](http://twitter.com/jmettraux),
[github](http://github.com/jmettraux),
[speakerdeck](https://speakerdeck.com/u/jmettraux)

## open source projects ##

[rufus-scheduler](https://github.com/jmettraux/rufus-scheduler),
[ruote](https://github.com/jmettraux/ruote)

## posts ##

{% for post in site.posts %}
  {{ post.date | date: '%Y-%m-%d' }}  [{{ post.title }}]({{ post.url }})
{% endfor %}

[old blog](http://jmettraux.wordpress.com)

## test ##

```
  nada
    nada
```

```ruby
  1 + 2 + *%w[ 1 2 3 ].collect(&:to_i)
    #
    # good fun
```

