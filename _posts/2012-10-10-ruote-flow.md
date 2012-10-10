---
layout: post
title: the flow in ruote
#comments: "https://github.com/jmettraux/jmettraux.github.com/commit/82a31687f1dd60938a9cbb2142e74179f7494c12"
---

This post attempts to explain how things flow in ruote. It starts by defining a few terms then goes on describing how ruote workflows execute.


# "definition" vs "execution"

Please distinguish "definition" from "execution", thinking about "definition time" and "execution time" does help.

Following in that way think of "workflow definition" vs "workflow execution".

Sometimes "workflow execution" gets shortened to "workflow" or "execution", while "workflow definition" is shortened to "definition".

Throughout the ruote documentation, "workflow instance" and "workflow definition" were used as well as "process instance" and "process definition". Lately, I think that "worflow execution" and "workflow definition" are better.

"process" is nice, especially when your workflows are real "business processes". But ruote is described as a "workflow engine", taken its distance from "business process management suites". I think one can build a business process engine on top of ruote, but that requires some work.

"process" is nice too when ruote is considered as an operating system for business processes. You have multiple processes running in your ruote and you can cancel them, pause them, ... But that is confusing when ruote is used in sytem operations context, where "process" is meant for real, operating system processes.

So "workflow definition" and "workflow execution" are simple and distinctive.


# workflow, definition, execution, tree

Ruote is a workflow engine. It takes as input a **workflow definition** and interprets it from root to leaves and back to root.

A workflow definition is a tree, each node represents an expression.

Here is a workflow definition (expressed in radial):

```
  define name: my_flow
    alice
    bob
```

Here is the corresponding workflow \[definition\] tree:

```
  [ 'define', { 'name' => 'my_flow' }, [
    [ 'alice', {}, [] ],
    [ 'bob', {}, [] ]
  ] ]
```

It's important to distinguish between the \[workflow definition\] tree and the **\[workflow\] execution tree**.

The workflow definition tree is the low-level (JSON) representation of a workflow definition.

The workflow execution tree is the current state of a workflow execution.

The workflow execution tree grows from root to leaves and then shrinks back.

A running workflow has a workflow execution tree. A terminated workflow has seen its execution tree grow from one root to multiple nodes and then shrink back to its root and terminate (the root being removed).

The execution tree grows in the **apply** direction and shrinks in the **reply** direction.

Instantiating a workflow is applying its root node. A workflow terminates when its root gets replied to.

The workflow execution tree is a tree of **expressions**. Those expressions are instances of the nodes of the workflow definition tree.

'apply' is named 'launch' when applying a root expression (thus creating a new execution tree). 'launch' is also used when applying the root expression of a subprocess. In this document, 'apply' only will be used.


# messages

Before looking at an example of a workflow execution tree growth and evanescence, one has to peek at how things flow.

In ruote, expressions communicate by emitting messages on a bus shared by workers. The bus implementation depends on the storage variant used. In its simplest form, it may be thought of as a queue.

Ruote workers pick messages on the queue and process them. Launching a workflow is putting a "apply this definition tree" message in the queue. A worker will (hopefully) pick the message, instantiate the root expression and give it the message. Workers pick messages, instantiate or locate (re-hydrate) the target expression and hand it the message.

When an expression gets applied, what happens next depends on the expression implementation. A sequence expression will apply the first of its children expressions, while a "concurrence" expression will apply all of its children. And "apply" here, means putting a message in the queue that says "apply that sub execution tree".

Thus,

```
  concurrence
    sequence
      alice
      bob
    charly
```

when the concurrence is applied, it will emit two messages: "apply sequence(alice; bob)" and "apply charly".

The ruote flow is the flow of these messages.


# an example flow

Here is a workflow definition tree (in its radial representation):

```
  define name: 'myflow'
    concurrence
      sequence
        alice
        bob
      charly
```

Alice, bob and charly will be interpreted as participant expressions.

The execution will begin with five expressions being created in a row. When the flow reaches alice and charly, the execution tree will look like:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence
        * expression: alice
      * expression: charly
```

There are two leaf expressions, alice and charly.

When the participant implementation behind alice replies, the alice participant expression replies to its parent expression, the sequence, which will apply its next child:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence
        * expression: bob
      * expression: charly
```

Meanwhile, the participant implementation behind charly replies and the charly participant expression replies to its parent, the concurrence. The concurrence expression, by default, only replies to its parent expression when all the children in the concurrence have replied. In our case, having charly's answer, it will now wait for the sequence's answer.

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence
        * expression: bob
```

As bob replies, the reply will cascade back to the sequence, which will reply to its parent since it has no more children to apply. The parent concurrence, having received the reply of all its children, will reply to the parent expression. That parent happen to be the root. The root has no parent to reply to. The workflow execution terminates.


# apply and reply

There are two directions: apply and reply.

```
  * expression: define name: 'myflow'   apply    ^
    * expression: concurrence             |      |
      * expression: sequence              |      |
        * expression: bob                 |      |
      * expression: charly                v    reply
```

The apply direction goes from the root to the leaves, from the parent to the child expression.

The reply directions goes back from the leaves to the root, from the child expression to its parent.


# definition tree vs execution tree

Life would be easier if the workflow definition could be thought of as a railroad, static with a few bifurcations and signals and workitems happily travelling on the rails. At each "transition", the workers would consult the workflow definition, the model, and route workitems accordingly. A workflow would be a set of workitems, each located somewhere along the rails of the workflow definition.

Ruote isn't following such a concept. There is no central grid system. Each expression carries a copy of its branch of the workflow definition tree and that is what is used to apply child expressions. Add a link back to the parent expression and the execution tree is complete.

An advantage of this way of doing things is that one can change a workflow execution without affecting other workflow executions issued from the same workflow definition.

It can be thought of as a disadvantage: it would be so much easier if we could change all the workflow execution of class x by simply modifying the workflow definition they all follow, but how to do it when only a handful of those executions need to go the new way?

(one could clone the workflow definition and tell executions a,b and c to follow the clone, but if we're into such iterations, why not simply iterate over a, b, c and change their execution trees like ruote does?)



# cancel

Sometimes, one has a to cancel a workflow execution or part of it (has to cancel a branch in the execution tree).

Cancel is a special message that can be addressed to any expression node in an execution tree. It will start the cancel operations for the branch starting at that node.

For instance, we might want to cancel the execution of the first concurrent branch in our workflow execution:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence    &lt;------- cancel here
        * expression: alice
      * expression: charly
```

What will happen is that the cancel message for that expression will get queued. When its picked up, the expression is located and handed the cancel message. If the expression has not replied (to its parent) meanwhile (ie if the expression is not gone), the expression will start its cancel work.

In our example, the sequence expression will cancel its active child, the alice participant expression. It will do that by placing a cancel message for the alice participant expression on the queue, but right before that, the sequence flags its self with "state: cancelling" (one of the primary benefits of this flag is that further cancel message will get ignored, the cancelling work is already going on).

The cancel messages then cascade to the children. When the cancel message emitted by the sequence expression itself hits the alice participant expression, the execution tree will look like:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence (state: cancelling)
        * expression: alice (state: cancelling)
      * expression: charly
```

The alice participant expression will pass the cancel message to the participant implementation and, hopefully, the reply will come back immediately from the participant implementation. At that point the replies follow their usual path back towards the root.

Our arrows can be seen as:

```
  * expression: define name: 'myflow'    apply  cancel    ^
    * expression: concurrence              |      |       |
      * expression: sequence               |      |       |
        * expression: bob                  |      |       |
      * expression: charly                 v      v     reply
```


### kill

One can choose to "kill" a workflow or a branch of a workflow execution instead of simply cancelling it. It will work the same, except in presence of [on_cancel](http://ruote.rubyforge.org/common_attributes.html#on_cancel) attributes.

The on_cancel attribute when present point to subflows that get executed when the cancel flow hits back their location. When sending a kill message, the cancelling work happens but any on_cancel attribute on the way back gets ignored.


# re_apply

The re_apply feature in ruote is building upon cancel and a small hook in the reply function in expressions.

Re_apply is about replacing a workflow execution branch with a new tree. Replacing, here, means cancelling the current branch, and, upon successful reply after cancel, re-applying the initial tree or a new one.

For example, one could re-apply the sequence above and replace it with a concurrence, going from:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: sequence
        * expression: alice
      * expression: charly
```

to the new execution tree:

```
  * expression: define name: 'myflow'
    * expression: concurrence
      * expression: concurrence
        * expression: alice
        * expression: bob
      * expression: charly
```

This actually happens in three big steps: first the branch gets cancelled and then, when alice replies to the sequence expression, the new tree gets applied in replacement of the initial sequence definition tree.

Here is a tentative representation:

```
  * node0                           * node 0
    * node 1        cancel    ^       * node 1'      apply new tree
      * node 2        |       |         * node 2'           |
        * node 3      |       |           * node 3'         v
          * node 4    v     reply
```


# pausing

The way to pause a workflow is to send it a pause message. Like a cancel message, a pause message can be pointed at any expression in the workflow execution tree. Pointing the pause message at the root expression will make the whole workflow execution pause.

It's important to understand that the pause message, like the cancel message is propagated from an expression to its children. Unlike the cancel message, the leaf expressions will not reply, they'll get stuck, in pause, until a resume message reaches them.

When a participant expression receives a pause message, it will pause itself and then pass the message to the participant implementation. That implementation may or may not care. If the implementation passes the answer (workitem) back to the frozen participant expression, the answer gets frozen (until the participant expression gets resumed).


## breakpoints

Breakpoints are not real IDE breakpoints, but they may feel similar. Breakpoints are pause messages that point at an exception, make it pause, but the pause message/state is not propagated to child expressions. When a child expression replies to a paused parent, the reply will get frozen as well. When the flow resumes, the child reply gets processed.


# attach

TODO


# recap

TODO

