---
layout: post
title: ruote and the :await attribute
---

_tl;dr_<br/>
ruote has got a new "await" attribute (can be placed on any expression) that suspends the application of the expression until a condition (entering or leaving a tag or a participant) realizes. Useful to express acyclic graphs.

&nbsp;

[Ruote](http://ruote.rubyforge.org) is a Ruby workflow engine. It's mostly about orchestrating tasks, routing work among participants. The most interesting questions people come up with are the ones about "how to model that flow in ruote?".

The other day on IRC (freenode #ruote), Typedef asked me how one could model this in ruote:

<img src="images/2012-12-14-abcd.png" align="right" style="margin: 0;" />

"for example if I had a graph like A -> C <- B -> D, where task C depends on A and B, and D depends only on B. I'd like to be able to launch D as soon as B completes without waiting for A, but block C until both A and B complete."

Typedef was asking how he could put the [await](http://ruote.rubyforge.org/exp/await.html) expression to good use for that. I always try to drive people away from [listen](http://ruote.rubyforge.org/exp/listen.html) and [await](http://ruote.rubyforge.org/exp/await.html) unless they are really needed, so I proposed:

<div class="half-code">
{% highlight ruby linenos %}
#
# nice and all, but makes "d"
# an orphan / detached branch
#
sequence do
  concurrence do
    a
    sequence do
      b
      d :forget => true
    end
  end
  c
end
{% endhighlight %}
</div>

The rectangle is the top sequence, when the concurrence is done, C gets applied. The concurrence makes sure A and B are applied in parallel, the inner sequence align D after B and the :forget flag is here to let the B branch reply to the concurrence right after B finishes.

<img src="images/2012-12-14-abc_d.png" align="right" style="margin: 0;" />

But, conceptually, that is more like the graph on the right, where D becomes an orphan and the main flow goes on without waiting for it. It's not explicitely demanded but I think that this piece of flow ends when all its tasks completed (hence the rectangle I draw).

So I went back to the coding board. I wrote the four tasks in a concurrence and told myself: "this is great, the four tasks exist in the same space, when all four of them terminate, the concurrence terminates..."

<div class="half-code">
{% highlight ruby linenos %}
#
# everybody at the same time
#
concurrence do
  a
  b
  c
  d
end
{% endhighlight %}
</div>

I wondered how I could materialize Typedef's arrows. And I realized that he was probably right trying to apply [await](http://ruote.rubyforge.org/exp/await.html), this expression could shine in this scenario.

This "await" expression is a rework of the [listen](http://ruote.rubyforge.org/exp/listen.html) expression. It's meant for waiting for events to happen in other branches of the workflow execution tree.

<div class="half-code-right">
{% highlight ruby linenos %}
#
# works... but never goes out of
# the concurrence because the two
# "await" behave like daemons,
# ready to spin again for each
# tracked event
#
concurrence do
  sequence :tag => 'ab' do
    a
    b :tag => 'b'
  end
  await :left_tag => 'ab' do
    c
  end
  await :left_tag => 'b' do
    d
  end
end
{% endhighlight %}
</div>

There are 3 kind of events "await" can listen to: participant (on apply and on reply), tag (on entering and on leaving) and errors.

The problem with this definition is that it nevers exits, the two await expressions behave like little daemons, wait for the that to be left. That's how "await" (and "listen") are supposed to work, when they have a block they become daemons.

The solution would be to use "await" without a block. It then behaves like a lock, waiting for the event to happen to let the flow resume.

<div class="half-code">
{% highlight ruby linenos %}
#
# what we wanted, but it feels
# clunky
#
concurrence do
  sequence :tag => 'ab' do
    a
    b :tag => 'b'
  end
  sequence do
    await :left_tag => 'ab'
    c
  end
  sequence do
    await :left_tag => 'b'
    d
  end
end
{% endhighlight %}
</div>

But, although it behaves as we wanted, it feels clunky compared to the "daemons" version above.

So I went ahead and added an :await attribute to the ruote expressions. When an expression sports it, it waits for the described event before applying for real (it stays in a paused state until the event occurs).

The resulting process definition looks like:

<div class="half-code-right">
{% highlight ruby linenos %}
#
# xxx
#
concurrence do
  sequence :tag => 'ab' do
    a
    b :tag => 'b'
  end
  sequence :await => 'ab' do
    c
  end
  sequence :await => 'b' do
    d
  end
end
{% endhighlight %}
</div>

