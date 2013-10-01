---
layout: post
title: rufus-scheduler 3.0
comments: "https://github.com/jmettraux/jmettraux.github.com/issues/7"
---

I've just released [rufus-scheduler](https://github.com/jmettraux/rufus-scheduler) 3.0.

Rufus-scheduler was started around 2006 and slowly grew into its 2.x version. Many people helped along the way (see [credits.txt](https://github.com/jmettraux/rufus-scheduler/blob/master/CREDITS.txt)). The gem proved useful.

Rufus-scheduler 3.0 is an almost complete rewrite. I needed a more stable ground to go on maintaining it.

Here are the most notable changes:

* ```scheduler.every('100') {``` will schedule every **100** seconds (previously, it would have been 0.1s). This aligns rufus-scheduler on Ruby's ```sleep(100)```
* The scheduler isn't catching the whole of Exception anymore, only **StandardError**
* The error_handler is **#on_error** (instead of #on_exception), by default it now prints the details of the error to $stderr (used to be $stdout)
* Rufus::Scheduler::TimeOutError renamed to Rufus::Scheduler::**TimeoutError**
* Introduction of **interval** jobs. Whereas "every" jobs are like "every 10 minutes, do this", interval jobs are like "do that, then wait for 10 minutes, then do that again, and so on" (do, sleep, rewind)
* Introduction of a **:lockfile** => true/filename mechanism to prevent multiple schedulers from executing
* **discard_past** is the new behaviour, if your host somehow goes to sleep, when life comes back, rufus will only trigger once then discarding potential triggers "in the past"
* Introduction of Scheduler #on_pre_trigger and #on_post_trigger **callback** points
* Single scheduler implementation, no more EventMachine-based scheduler

The [readme](https://github.com/jmettraux/rufus-scheduler/blob/master/README.md) should detail all the levers and gauges of the tool.

If you experience troubles with the migration to 3.0 (maybe a loose gemspec mentioning 'rufus-scheduler' and no version), report issues via [GitHub](https://github.com/jmettraux/rufus-scheduler/issues)

If you need help, request it via [StackOverflow](http://stackoverflow.com/questions/ask?tags=rufus-scheduler+ruby). The old mailing list is, well, "deprecated". Do not ask for help or report issues via Twitter.

[https://github.com/jmettraux/rufus-scheduler](https://github.com/jmettraux/rufus-scheduler)

Many thanks to all who helped.

