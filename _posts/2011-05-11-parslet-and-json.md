---
layout: post
title: parslet and json
---

[Parslet](https://github.com/kschiess/parslet) is a small Ruby library for
constructing parsers based on [Parsing Expression
Grammars](http://en.wikipedia.org/wiki/Parsing_expression_grammar) (PEG).
It's written by [Kaspar Schiess](http://blog.absurd.li/) and various
[contributors](http://kschiess.github.com/parslet/contribute.html).

This blog post introduces Parslet with a parser example. Since JSON has very
easy to grasp [railroad diagrams](http://json.org/) for its syntax, it might make for a good example.

Please note that the JSON parser here won't compete for speed with available libraries. No benchmarks here.

Our goal is to take as input JSON strings and output the resulting value.

For the impatient, the end result is at [https://gist.github.com/966020](https://gist.github.com/966020)

How is an array encoded in JSON ?

<img src="http://json.org/array.gif" style="margin: 15px 0 15px 0; border: 0;" />

How would that look in our parser ?

{% highlight ruby linenos %}
class Parser < Parslet::Parser

  rule(:spaces) { match('\s').repeat(1) }
    # at least 1 space character (space, tab, new line, carriage return)

  rule(:spaces?) { spaces.maybe }
    # a bunch of spaces or not

  rule(:comma) { spaces? >> str(',') >> spaces? }
    # a comma surrounded by optional spaces

  rule(:array) {
    str('[') >> spaces? >>
    (value >> (comma >> value).repeat).maybe.as(:array) >>
    spaces? >> str(']')
  }
end
{% endhighlight %}

What is this value thing ?

<img src="http://json.org/value.gif" style="margin: 15px 0 15px 0; border: 0;" />

string or number or object or ...

{% highlight ruby linenos %}
rule(:value) {
  string | number |
  object | array |
  str('true').as(:true) | str('false').as(:false) |
  str('null').as(:null)
}
{% endhighlight %}

All is good, a few parsing rules laters, we have a complete JSON parser, but wait, what does it output ?

{% highlight ruby linenos %}
p MyJson::Parser.new.parse(%{
  [ 1, 2, 3, null,
    "asdfasdf asdfds", { "a": -1.2 }, { "b": true, "c": false },
    0.1e24, true, false, [ 1 ] ]
})
# => {:array=>[{:number=>"1"@5}, {:number=>"2"@8}, {:number=>"3"@11}, {:null=>"null"@14}, {:string=>"asdfasdf asdfds"@25}, {:object=>{:entry=>{:val=>{:number=>"-1.2"@50}, :key=>{:string=>"a"@46}}}}, {:object=>[{:entry=>{:val=>{:true=>"true"@65}, :key=>{:string=>"b"@61}}}, {:entry=>{:val=>{:false=>"false"@76}, :key=>{:string=>"c"@72}}}]}, {:number=>"0.1e24"@89}, {:true=>"true"@97}, {:false=>"false"@103}, {:array=>{:number=>"1"@112}}]}
{% endhighlight %}

Oh well, that is not exactly what we want as final result. Parslet calls the output of its parser a "intermediate tree". It separates <a href="http://kschiess.github.com/parslet/parser.html">parsing</a> from <a href="http://kschiess.github.com/parslet/transform.html">transformation</a>.

We need a transformer and it looks like :

{% highlight ruby linenos %}
class Transformer < Parslet::Transform

  class Entry < Struct.new(:key, :val); end

  rule(:array => subtree(:ar)) {
    ar.is_a?(Array) ? ar : [ ar ]
  }
  rule(:object => subtree(:ob)) {
    (ob.is_a?(Array) ? ob : [ ob ]).inject({}) { |h, e| h[e.key] = e.val; h }
  }

  rule(:entry => { :key => simple(:ke), :val => simple(:va) }) {
    Entry.new(ke, va)
  }

  rule(:string => simple(:st)) {
    st.to_s
  }
  rule(:number => simple(:nb)) {
    nb.match(/[eE\.]/) ? Float(nb) : Integer(nb)
  }

  rule(:null => simple(:nu)) { nil }
  rule(:true => simple(:tr)) { true }
  rule(:false => simple(:fa)) { false }
end
{% endhighlight %}

Patterns in the intermediate tree are indentified and replaced, producing a final output (or yet another intermediate result, it's up to you).

The complete parser (and transformer and small test) is at <a href="https://gist.github.com/966020">https://gist.github.com/966020</a>

There isn't much more I could say. Ah yes, about testing. Kaspar explains it in the <a href="http://kschiess.github.com/parslet/tricks.html">tricks</a>, you can directly test parsing rules individually :

{% highlight ruby linenos %}
class MyJsonTest < Test::Unit::TestCase
  def parser
    MyJson::Parser.new
  end
  def test_parser_number_integer
    assert_equal 1, parser.number("1")
  end
  def test_parser_number_float
    assert_equal 1.0, parser.number("1.0")
  end
  def test_parser_number_not_a_number
    assert_raise Parslet::ParseFailed do
      parser.number("whatever")
    end
  end
end
{% endhighlight %}

...

Happy parsing (and transforming) !

* the json parser : [https://gist.github.com/966020](https://gist.github.com/966020)

* documentation : [http://kschiess.github.com/parslet/](http://kschiess.github.com/parslet/)
* source code : [https://github.com/kschiess/parslet](https://github.com/kschiess/parslet)
* mailing list : [ruby.parslet@librelist.com](http://librelist.com/browser/ruby.parslet/)
* irc : freenode.net #parslet

No animals got benchmarked during the making of this blog post.

