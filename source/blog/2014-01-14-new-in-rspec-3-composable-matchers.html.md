---
title: "New in RSpec 3: Composable Matchers"
author: Myron Marston
---

One of RSpec 3's big new features is shipping 3.0.0.beta2: composable
matchers. This feature supports more powerful, less brittle
expectations, and opens up new possibilities.

## An Example

In RSpec 2.x, I've written code like this on many occassions:

~~~ ruby
# background_worker.rb
class BackgroundWorker
  attr_reader :queue

  def initialize
    @queue = []
  end

  def enqueue(job_data)
    queue << job_data.merge(:enqueued_at => Time.now)
  end
end
~~~

~~~ ruby
# background_worker_spec.rb
describe BackgroundWorker do
  it 'puts enqueued jobs onto the queue in order' do
    worker = BackgroundWorker.new
    worker.enqueue(:klass => "Class1", :id => 37)
    worker.enqueue(:klass => "Class2", :id => 42)

    expect(worker.queue.size).to eq(2)
    expect(worker.queue[0]).to include(:klass => "Class1", :id => 37)
    expect(worker.queue[1]).to include(:klass => "Class2", :id => 42)
  end
end
~~~

In RSpec 3, composable matchers allow you to pass matchers as arguments
(or nested within data structures passed as arguments) to other matchers
allowing you to simplify specs like these:

~~~ ruby
# background_worker_spec.rb
describe BackgroundWorker do
  it 'puts enqueued jobs onto the queue in order' do
    worker = BackgroundWorker.new
    worker.enqueue(:klass => "Class1", :id => 37)
    worker.enqueue(:klass => "Class2", :id => 42)

    expect(worker.queue).to match [
      a_hash_including(:klass => "Class1", :id => 37),
      a_hash_including(:klass => "Class2", :id => 42)
    ]
  end
end
~~~

We've made sure the failure messages read well for cases like these,
opting to use the `description` of the provided matcher rather than
the `inspect` output.  For example, if we "break" the implementation
tested by this spec by commenting out the `queue << ...` line, it fails
with:

~~~
1) BackgroundWorker puts enqueued jobs onto the queue in order
   Failure/Error: expect(worker.queue).to match [
     expected [] to match [(a hash including {:klass => "Class1", :id => 37}), (a hash including {:klass => "Class2", :id => 42})]
     Diff:
     @@ -1,3 +1,2 @@
     -[(a hash including {:klass => "Class1", :id => 37}),
     - (a hash including {:klass => "Class2", :id => 42})]
     +[]

   # ./spec/background_worker_spec.rb:19:in `block (2 levels) in <top (required)>'
~~~

## Matcher aliases

As you may have noticed, the example above uses `a_hash_including`
in place of `include`. RSpec 3 provides similar aliases for all of the
built-in matchers that read better grammatically and provide a
better failure message.

For example, compare this expectation and failure message:

~~~
x = "a"
expect { }.to change { x }.from start_with("a")
~~~
~~~
expected result to have changed from start with "a", but did not change
~~~

...to:

~~~ ruby
x = "a"
expect { }.to change { x }.from a_string_starting_with("a")
~~~
~~~
expected result to have changed from a string starting with "a",
but did not change
~~~

While `a_string_starting_with` is more verbose than `start_with`, it
produces a failure message that actually reads well, so you don't trip
over odd grammatical constructs. We've provided one or more similar
aliases for all of RSpec's built-in matchers. We've tried to use
consistent phrasing (generally "a \[type of object\] \[verb\]ing") so
they are easy to guess. You'll see many examples below, and the RSpec
3 docs will have a full list.

There's also a public API that makes it trivial to define your own aliases
(either for RSpec's built in matchers or for a custom matcher). Here's
the bit of code in rspec-expectations that provides the
`a_string_starting_with` alias of `start_with`:

~~~ ruby
RSpec::Matchers.alias_matcher :a_string_starting_with, :start_with
~~~

## Compound Matcher Expressions

[Eloy Espinaco](https://github.com/eloyesp) contributed a new feature
that provides another way of combining matchers: compound `and` and `or`
matcher expressions. For example, rather than writing this:

~~~ ruby
expect(alphabet).to start_with("a")
expect(alphabet).to end_with("z")
~~~

...you can combine these into one expectation:

~~~ ruby
expect(alphabet).to start_with("a").and end_with("z")
~~~

You can do the same with `or`. While less common, this is useful
for expressing one of a valid list of values (e.g. when the exact
value is indeterminite):

~~~ ruby
expect(stoplight.color).to eq("red").or eq("green").or eq("yellow")
~~~

I think this could particularly come in handy for expressing invariants
using Jim Weirich's [rspec-given](https://github.com/jimweirich/rspec-given#invariant).

Compound matcher expressions can also be passed as an argument to
another matcher:

~~~ ruby
expect(["food", "drink"]).to include(
  a_string_starting_with("f").and ending_with("d")
)
~~~

Note: in this example, `ending_with` is another alias for the `end_with`
matcher.

## Which matchers support matcher arguments?

In RSpec 3, we've updated many of the matchers to support receiving
matchers as arguments, but not all of them do. In general, we updated
all of the ones where we felt like it made sense. The ones that do not
support matchers are those that have precise matching semantics that
do not allow for a matcher argument.  For example the `eq` matcher is
documented as passing if and only if `actual == expected`. It doesn't
make sense for `eq` to support receiving a matcher argument[^foot_1].

I've compiled a list below of all the built-in matchers that support
receiving matchers as arguments.

### change

The `by` method of the `change` matcher can receive a matcher:

~~~ ruby
k = 0
expect { k += 1.05 }.to change { k }.by( a_value_within(0.1).of(1.0) )
~~~

You can also pass matchers to `from` or `to`:

~~~ ruby
s = "food"
expect { s = "barn" }.to change { s }.
  from( a_string_matching(/foo/) ).
  to( a_string_matching(/bar/) )
~~~

### contain_exactly

`contain_exactly` is a new alias of `match_array`. The semantics are a bit
more clear than `match_array` (now that `match` can match arrays, too, but
`match` requires the ordering to match whereas `match_array` doesn't). It
also allows you to pass the array elements as individual arguments rather
than being forced to pass a single array argument like `match_array` expects.

~~~ ruby
expect(["barn", 2.45]).to contain_exactly(
  a_value_within(0.1).of(2.5),
  a_string_starting_with("bar")
)

# ...which is the same as:

expect(["barn", 2.45]).to match_array([
  a_value_within(0.1).of(2.5),
  a_string_starting_with("bar")
])
~~~

### include

`include` allows you to match against the elements of a collection,
the keys of a hash, or against a subset of the key/value pairs in a hash:

~~~ ruby
expect(["barn", 2.45]).to include( a_string_starting_with("bar") )

expect(12 => "twelve", 3 => "three").to include( a_value_between(10, 15) )

expect(:a => "food", :b => "good").to include(
  :a => a_string_matching(/foo/)
)
~~~

### match

In addition to matching a string against a regex or another string, `match`
now works against arbitrary array/hash data structures, nested as deeply
as you like. Matchers can be used at any level of that nesting:

~~~ ruby
hash = {
  :a => {
    :b => ["foo", 5],
    :c => { :d => 2.05 }
  }
}

expect(hash).to match(
  :a => {
    :b => a_collection_containing_exactly(
      an_instance_of(Fixnum),
      a_string_starting_with("f")
    ),
    :c => { :d => (a_value < 3) }
  }
)
~~~

### raise_error

`raise_error` can accept a matcher for matching against the exception
class or a matcher to match against the message, or both.

~~~ ruby
RSpec::Matchers.define :an_exception_caused_by do |cause|
  match do |exception|
    cause === exception.cause
  end
end

expect {
  begin
    "foo".gsub # requires 2 args
  rescue ArgumentError
    raise "failed to gsub"
  end
}.to raise_error( an_exception_caused_by(ArgumentError) )

expect {
  raise ArgumentError, "missing :foo arg"
}.to raise_error(ArgumentError, a_string_starting_with("missing"))
~~~

### start_with and end_with

These are pretty self-explanatory:

~~~ ruby
expect(["barn", "food", 2.45]).to start_with(
  a_string_matching("bar"),
  a_string_matching("foo")
)

expect(["barn", "food", 2.45]).to end_with(
  a_string_matching("foo"),
  a_value < 3
)
~~~

### throw_symbol

You can pass a matcher to `throw_symbol` to match against the accompanying argument:

~~~ ruby
expect {
  throw :pi, Math::PI
}.to throw_symbol(:pi, a_value_within(0.01).of(3.14))
~~~

### yield_with_args and yield_successive_args

Matchers can be used to specify the yielded arguments for these matchers:

~~~ ruby
expect { |probe|
  "food".tap(&probe)
}.to yield_with_args( a_string_starting_with("f") )

expect { |probe|
  [1, 2, 3].each(&probe)
}.to yield_successive_args( a_value < 2, 2, a_value > 2 )
~~~

## Conclusion

This is one of the new features of RSpec 3 I'm most excited about and I hope
you can see why. This should help make it easier to avoid writing brittle
specs by enabling you to specify _exactly_ what you expect (and nothing
more).

[^foot_1]: You can, of course pass a matcher to `eq`, but it'll treat it just like any other object: it'll compare it to `actual` using `==`, and, if that returns true (i.e. if it's the same object), the expectation will pass.

