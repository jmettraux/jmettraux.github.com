---
layout: post
title: rufus-scheduler 2.0.18
comments: "https://github.com/jmettraux/jmettraux.github.com/issues/5"
---

This [in-process block scheduling library](https://github.com/jmettraux/rufus-scheduler) just reached version 2.0.18.

Here is the changelog:

    - support for "L" in cron lines (Thanks Andrew Davey)
    - reject invalid weekdays (Thanks pazustep)
    - support for negative time strings (Thanks Danny "northox" Fullerton)

The first two changes are centered around the "cron" feature while the last one is about time strings used in "in" and "every".

The support for L in cron strings is my favourite, it lets you write things like:

{% highlight ruby linenos %}
scheduler.cron '0 22 L * *' do
  # every month on the last day at 22:00
end
{% endhighlight %}

&nbsp;

Thanks to [Andrew](https://github.com/asdavey), [Stig](https://github.com/stigkj), [Marcus](https://github.com/pazustep) and [Danny](https://github.com/northox) for their contributions!

Work on rufus-scheduler 3.0 has started a while back[,](https://github.com/jmettraux/rufus-scheduler/tree/three) it's not here yet, I guess noone really needs it, I still want simpler, easier to maintain code (good for everybody). Maybe in summer...

