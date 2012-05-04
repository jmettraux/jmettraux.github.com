---
layout: post
title: rufus-scheduler 2.0.12 released
comments: "https://github.com/jmettraux/jmettraux.github.com/commit/e86a097fcaff49f55ff36d4258832261ca50573a#comments"
---

rufus-scheduler is a thread-based scheduler written in Ruby. It lets you write code like:

{% highlight ruby linenos %}
require 'rufus-scheduler'

s = Rufus::Scheduler.start_new

s.every '10m' do
  puts 'open the window for the cat'
end

s.at '2012-01-01 12:00' do
  puts 'reminder: wife's birthday'
end

s.cron '0 22 * * 1-5' do
  puts 'activate the security system'
end

s.join # in case of stand-alone script...
{% endhighlight %}

The main addition brought by this release is the :mutex attribute when scheduling blocks of code. I was seeing people misusing :blocking => true to exclude block execution overlapping. It works but the scheduler is blocked as well, and crons might get skipped:

{% highlight ruby linenos %}
s.every '10m', :blocking => true do
  puts 'doing this...'
  sleep 60 * 60 # 1 hour
  puts 'done.'
end

# if the scheduler is in the blocking task above, crons will get skipped...
s.at '2012-01-01 12:00' do
  puts 'do that.'
end
{% endhighlight %}

My advice was to use mutexes instead:

{% highlight ruby linenos %}
$m = Mutex.new

s.every '10m' do
  $m.synchronize do
    puts 'doing this...'
    sleep 60 * 60 # 1 hour
    puts 'done.'
  end
end

# if the scheduler is in the blocking task above, crons will get skipped...
s.at '2012-01-01 12:00' do
  $m.synchronize do
    puts 'do that.'
  end
end
{% endhighlight %}

For those of you who use such mutexes and are OK with them wrapping the whole block, rufus-scheduler 2.0.12 introduces the :mutex attribute:

{% highlight ruby linenos %}
s.every '10m', :mutex => 'my_mutex_name' do
  puts 'doing this...'
  sleep 60 * 60 # 1 hour
  puts 'done.'
end

# if the scheduler is in the blocking task above, crons will get skipped...
s.at '2012-01-01 12:00', :mutex => 'my_mutex_name'  do
  puts 'do that.'
end
{% endhighlight %}

Where rufus-scheduler receives a mutex name and manages it for you.

When one wants more control over the granularity, it's OK to do:

{% highlight ruby linenos %}
$m = Mutex.new

s.every '10m', :mutex => $m do
  puts 'doing this...'
  sleep 60 * 60 # 1 hour
  puts 'done.'
end

# if the scheduler is in the blocking task above, crons will get skipped...
s.at '2012-01-01 12:00' do
  puts 'do that'
  $m.synchronize do
    puts 'and that.'
  end
end
{% endhighlight %}

Remember that rufus-scheduler is not a cron replacement. Many thanks to all the people who complained or helped in the development of this piece of software over the years.

* source: [https://github.com/jmettraux/rufus-scheduler](https://github.com/jmettraux/rufus-scheduler)
* issues: [https://github.com/jmettraux/rufus-scheduler/issues](https://github.com/jmettraux/rufus-scheduler/issues)
* mailing list: [http://groups.google.com/group/rufus-ruby](http://groups.google.com/group/rufus-ruby)
* irc: freenode #ruote

