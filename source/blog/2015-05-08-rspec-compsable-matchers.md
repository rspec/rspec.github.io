---
title: How RSpec 3.0 composable matchers work
author: Sam Phippen
---

##Warmup: the `===` protocol

In Ruby, a number of objects implement the `===` protocol. Some of the objects
that implement this protocol include:

* all class objects
* lambdas
* regexes
* ranges

Conceptually, this protocol represents a "match". That is, the object that
implements the `===` declares whether or not it "matches" the other object.
For example, `Array === []` returns `true`. This is because an empty array is a
subclass of the array class. `Array === {}` returns false because a hash is not
a subclass of array. For regexes, `===` returns true if the passed string
matches the regex, and false if it does not.

The `===` method is used in Ruby case statements to decide if a branch should
be taken. For example

```
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
**target** object is created by "expect" and basically wraps the passed object
to it in a class called `ExpectationTarget`. The primary methods on the
`ExpectationTarget` that users see are `to` and `not_to`/`to_not`. Let's focus
on `to`.

The `to` method is basically responsible for invoking the `matches?` method on the
passed matcher. It's possible to see this happening quite easily in an IRB session.

```
>> require "rspec/expectations"
=> true
>> o = Object.new
=> #<Object:0x007fa20d221490>
>> o.extend(RSpec::Matchers)
=> #<Object:0x007fa20d221490>
>> o.expect(3).to Object.new
NoMethodError: undefined method `matches?' for #<Object:0x007fa20d1f4e68>
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:50:in `block in handle_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:27:in `with_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/handler.rb:48:in `handle_matcher'
    from /Users/sam/.gem/ruby/2.1.5/gems/rspec-expectations-3.2.1/lib/rspec/expectations/expectation_target.rb:54:in `to'
    from (irb):4
    from /Users/sam/.rubies/ruby-2.1.5/bin/irb:11:in `<main>'
>>
```

In this session, we extend the RSpec DSL on to a blank object and then call
`o.expect(3).to Object.new`. This blows up because our new object does not implement
the `matches?` method.

In RSpec expectations, most matchers inherit from a class called `BaseMatcher`
which causes `matches?` to delegate to a method called `match`. Some matchers have
a very simple definition of `match`. For example, here's the definition of `match`
for the `eq` matcher:

```ruby
def match(expected, actual)
  actual == expected
end
```

Some matchers, however, have a more complicated match protocol. This more complicated
protocol is called the **composable** matcher protocol, which is what we'll discuss next.

## Composable RSpec matchers

A composable RSpec matcher is one which expects other RSpec matchers for some/all of it's
arguments. The `match` matcher is perhaps an obvious place to start. In RSpec 2.xx the match
matcher was really only used match regexes, and its match definition looked thus:

```ruby
def match(expected, actual)
  actual.match expected
end
```

Now obviously, one could extend the capabilites by providing other objects that provided a
definition of match, but that's besides the point.

The new definition of the match matcher's match method is thus:

```ruby
def match(expected, actual)
  return true if values_match?(expected, actual)
  return false unless can_safely_call_match?(expected, actual)
  actual.match(expected)
end
```

The key important difference is that call to `values_match?` which is the core implementation
of the new matching protocol in RSpec. The list of matchers which now reference the values_match?
method are (as of RSpec expectations 3.3.0 development, not including mocks):

* `change`
* `contain_exactly`
* `have_attributes`
* `include`
* `match`
* `output`
* `raise_error`
* `start_or_end_with`
* `throw_symbol`
* `yield`

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

The next thing the method does is return `true` if expected === actual. An easy
way to demonstrate this is back in our IRB session:

```
>> o.expect(3).to o.match(3)
=> true
```

What we've done here is we've constructed a both a target and match matcher with the value 3.
When the match matcher hits `values_match?` it sees that 3 is not an array or a hash, and so
checks `expected == actual`, which in this case is `3 == 3`, which is true.

The next line checks `expected === actual`. This is where the power of RSpec's new composability
really kicks in. The reason for this is that the `BaseMatcher` class includes a module called
`Composable`. The composable matcher defines `===` on matchers thusly:

```rspec
def ===(value)
  matches?(value)
end
```

This means that `expected` in the expression `expected === actual` can be another RSpec matcher,
a regex, or any other object that responds to `===`. This means, for example, that one can trivially
match a lambda by doing `expect(obj).to match(lambda { |actual| ... })`. Given that all RSpec matchers
implement `===` we are able to compose them arbitrarily with other "matching" values in the Ruby system.

An example I've given in the past is matching nesting hashes like so:

```
expect({:data => {... complex hash ...}).to include(:data => a_hash_including(:response => "success"))
```

The reason we're able to pass the `a_hash_including` matcher inside the
`include` matcher is that `values_match?` will dilligently call `===` on the
inner, `a_hash_including` matcher, which will invoke its `matches?` method, which
will allow it to match the complex inner hash.


##Conclusions

The old RSpec match protocol used to be a lot easier to understand. Each of the
matchers held their own matching logic, which was universally pretty simple. It
did mean, however, that one could not use RSpec matchers in a highly composable
way. For example: performing nested inclusion matches would require multiple
expectation expressions.

I think the new RSpec match protocol is a lot "simpler". There is one core
piece of matching logic, the `values_match?` method. Once you understand that
this method is at the core of all matches, it becomes a lot easier to reason
about what's going on.  All matches now look like a 'tree'. At the root of the
tree we use the `matches?` method to descend through a potentially complex tree
of matching objects using the `===` protocol. At the bottom level we end up using
either `===` or `==` to actually get the boolean values that determine the match.
These values then propogate back up until we are able to determine the result of
the expectation.

I hope this has helped you understand a little better how RSpec performs
matches. Feel free to reach out to me on twitter
[@samphippen](http://twitter.com/samphippen) with any questions you might have.
