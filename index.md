---
layout: top
title: jmettraux.github.com
---

## misc

[@jmettraux](http://twitter.com/jmettraux),
[github](http://github.com/jmettraux)

## open source projects ##

[rufus-scheduler](https://github.com/jmettraux/rufus-scheduler),
[ruote](https://github.com/jmettraux/ruote)

## posts ##

{% for post in site.posts %}
{{ post.date | date_to_s }} [{{ post.title }}]({{ post.url }})
{% endfor %}

