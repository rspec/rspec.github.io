---
title: How the RSpec 3.0 composable matchers work
author: Sam Phippen
---

##Warmup: the `===` protocol

In Ruby, a number of objects implement the `===` protocol. Some of the objects
that implement this protocol include:

* all class objects
* lambdas
* regexes
* ranges

Conceptually, this protocol represents a "match", but can be thought of as
categorising instances of objects. That is, the object that implements the
`===` declares whether or not it belongs in the same category as the other
object.  For example, `Array === []` returns `true`. This is because an empty
array is an instance of the array class. `Array === {}` returns false because
a hash is not an array. For regexes, `===` returns true if the passed string
matches the regex, and false if it does not.

The `===` method is used in Ruby case statements to decide if a branch should
be taken. For example

```Ruby
case 3
when (1...18)
  puts "hello"
end
```

will print hello, because `(1...18) === 3` returns `true`.

The new RSpec matchers make heavy use of `===` internally, if you'd like to get
more of an understanding of `===`, I'd heavily suggest you pop open IRB and
play around with it a little before moving on.

## RSpec matchers

In an RSpec expectation expression like `expect(object_1).to eq(object_2)`
there are two primary objects at play, the **target** and the **matcher**. The
**target** object is created by "expect" and exposes `to` (and `to_not`) which
takes the matcher is is responsible for invoking `matches?` on it.

It's possible to see this happening in an IRB session, e.g:

```Ruby
>> require "rspec/expectations"
=> true
>> extend(RSpec::Matchers)
=> main
>> expect(3).to Object.new
NoMethodError: undefined method `matches?' for #<Object:0x007fa20d1f4e68>
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:50:in `block in handle_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:27:in `with_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:48:in `handle_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/expectation_target.rb:54:in `to'
    from (irb):4
    from /Users/sam/.rubies/ruby-2.1.5/bin/irb:11:in `<main>'
>>
```

In this session, we extend the RSpec DSL into the main object and then call
`expect(3).to Object.new`. This blows up because our new object does not
implement the `matches?` method.

In RSpec expectations matchers implement `matches?` to provide assertions for
your test suite, some of these are complex but they can also be quite simple.
For example, here's the logic of `matches?` for the `eq` matcher:

```ruby
def matches?(actual)
  actual == expected
end
```

## Composable RSpec matchers

A composable RSpec matcher is one which expects other RSpec matchers for it's
arguments. These are higher order matchers (as opposed to more primitive
matchers such as `be_predicate` or `be > x`) such as `include`, `start_with`
and `match`. Let's take a look at the `match` matcher as a place to start.

In RSpec 2.xx the match matcher was mostly used to match regexes, and its
`matches?` definition looked thus:

```ruby
def matches?(expected, actual)
  actual.match expected
end
```

The new definition of this matcher's `matches?` method is thus:

```ruby
def matches?(expected, actual)
  return true if values_match?(expected, actual)
  return false unless can_safely_call_match?(expected, actual)
  actual.match(expected)
end
```

The key difference is that call to `values_match?` which leverages `===`
(the core implementation of the new matching protocol in RSpec) to check if
the "values match" and accepts matcher. The list of matchers which now use
this approach are (as of RSpec expectations 3.3.0, not including mocks):

* `change`
* `contain_exactly`
* `have_attributes`
* `include`
* `match`
* `output`
* `raise_error`
* `start_with`
* `end_with`
* `throw_symbol`
* `yield_control`
* `yield_successive_args`
* `yield_with_args`
* `yield_with_no_args`

Let's take a look at what `values_match?` does.

`values_match?` is the RSpec match definition that allows matchers, and other objects, to compose.
The implementation looks like this:

```ruby
def self.values_match?(expected, actual)
  if Hash === actual
    return hashes_match?(expected, actual) if Hash === expected
  elsif Array === expected && Enumerable === actual && !(Struct === actual)
    return arrays_match?(expected, actual.to_a)
  end

  return true if expected == actual

  begin
    expected === actual
  rescue ArgumentError
    # Some objects, like 0-arg lambdas on 1.9+, raise
    # ArgumentError for `expected === actual`.
    false
  end
end
```

The first thing to note is the special casing for Hashes and Arrays. Basically,
what those methods do is recursively apply `values_match?` to each of the
elements in the various collection types as you'd expect. Arrays by scanning
elements and hashes by matching keys and values.

The next thing the method does is to return `true` if `expected == actual`,
note not `expected === actual` but `==` because `/foo/ === /foo/` returns
`false` as does `MyClass === MyClass` -- so we have to check normal equality
as well and not rely solely on `===`. We can demonstrate this is back in our
IRB session:

```ruby
>> expect(/foo/).to match(/foo/)
=> true
```

What we've done here is constructed a both a target and match matcher with the value /foo/.
When the match matcher hits `values_match?` it sees that /foo/ is not an array or a hash, and so
checks `expected == actual`, which in this case is `/foo/ == /foo/`, which is true.

The next line checks `expected === actual`. This is where the power of RSpec's new composability
really kicks in. The reason for this is that the `BaseMatcher` class includes a module called
`Composable`. The composable matcher defines `===` on matchers thusly:

```rspec
def ===(value)
  matches?(value)
end
```

This means that `expected` in the expression `expected === actual` can be
another RSpec matcher, a regex, or any other object that responds to `===`.
This means, for example, that one can trivially match a lambda by doing
`expect(obj).to match(lambda { |actual| ... })`. Given that all built in RSpec
matchers implement `===` we are able to compose them arbitrarily with other
"matching" values in the Ruby system.

An example is matching nesting hashes like so:

```rspec
expect({:data => {... complex hash ...}).to include(:data => a_hash_including(:response => "success"))
```

The reason we're able to pass the `a_hash_including` matcher inside the
`include` matcher is that `values_match?` will call `===` on the inner
`a_hash_including` matcher, which will invoke its `matches?` method, which
will allow it to match the complex inner hash.

##Conclusions

The old RSpec match protocol used to be a lot easier to understand. Each of the
matchers held their own matching logic, which was pretty simple. It did mean
that you could not use RSpec matchers in a highly composable way though.
For example: performing nested inclusion matches would require multiple
expectation expressions.

To understand the new RSpec match protocol you have to understand the one core
piece of matching logic, the `===` method. Once you understand that this method
is at the core of all matches, it becomes a lot easier to reason about what's
going on. All matches now look like a 'tree'. At the root of the tree we use the
`matches?` method to descend through potentially complex branches of matching
objects using the `===` protocol. At the bottom level we end up using either
`===` or `==` to actually get the boolean values that determine the match.
These values then propagate back up until we are able to determine the result of
the expectation.

I hope this has helped you understand a little better how RSpec performs
matches. Feel free to reach out to me on twitter
[@samphippen](http://twitter.com/samphippen) with any questions you might have.
