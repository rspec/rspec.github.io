---
title: RSpec's New Expectation Syntax
author: Myron Marston
---

RSpec has featured a readable english-like syntax for setting
expectations for a long time:

~~~ ruby
foo.should eq(bar)
foo.should_not eq(bar)
~~~

RSpec 2.11 will include a new variant to this syntax:

~~~ ruby
expect(foo).to eq(bar)
expect(foo).not_to eq(bar)
~~~

There are a few things motivating this new syntax, and I wanted
to blog about it to spread awareness.

## Delegation Issues

Between `method_missing`, `BasicObject` and the standard library's
`delegate`, ruby has very rich tools for building delegate or proxy
objects. Unfortunately, RSpec's `should` syntax, as elegantly as it
reads, is prone to producing weird, confusing failures when testing
delegate/proxy objects.

Consider a simple proxy object that subclasses `BasicObject`:

~~~ ruby
# fuzzy_proxy.rb
class FuzzyProxy < BasicObject
  def initialize(target)
    @target = target
  end

  def fuzzy?
    true
  end

  def method_missing(*args, &block)
    @target.__send__(*args, &block)
  end
end
~~~

Simple enough; it defines a `#fuzzy?` predicate, and delegates all
other method calls to the target object.

Here's a simple spec to test its fuzziness:

~~~ ruby
# fuzzy_proxy_spec.rb
describe FuzzyProxy do
  it 'is fuzzy' do
    instance = FuzzyProxy.new(:some_object)
    instance.should be_fuzzy
  end
end
~~~

Surprisingly, this fails:

~~~
  1) FuzzyProxy is a fuzzy proxy
     Failure/Error: instance.should be_fuzzy
     NoMethodError:
       undefined method `fuzzy?' for :some_object:Symbol
     # ./fuzzy_proxy.rb:11:in `method_missing'
     # ./fuzzy_proxy_spec.rb:6:in `block (2 levels) in <top (required)>'

Finished in 0.01152 seconds
1 example, 1 failure
~~~

The problem is that rspec-expectations defines `should` on `Kernel`,
and `BasicObject` does not include `Kernel`...so `instance.should`
triggers `method_missing` and gets delegated to the target object.
The result is actually `:some_object.should be_fuzzy` which is
clearly false (or rather, a `NoMethodError`).

It gets even more confusing when using `delegate` in the standard
library. It [selectively
includes](https://github.com/ruby/ruby/blob/v1_9_3_194/lib/delegate.rb#L43-50)
some of `Kernel`'s methods...which means that if rspec-expectations gets
loaded before `delegate`, `should` will work properly on delegate
objects, but if `delegate` is loaded first, it will proxy the `should`
calls just like in our `FuzzyProxy` example above.

The underlying problem is RSpec's `should` syntax: for `should` to
work properly, it must be defined on every object in the system...
but RSpec does not own every object in the system and cannot ensure
that it always works consistently. As we've seen, it doesn't work
as RSpec expects on proxy objects. Note that this isn't just a
problem with RSpec; it's a problem with minitest/spec's `must_xxx`
syntax as well.

The solution we came up with is the new `expect` syntax:

~~~ ruby
# fuzzy_proxy_spec.rb
describe FuzzyProxy do
  it 'is fuzzy' do
    instance = FuzzyProxy.new(:some_object)
    expect(instance).to be_fuzzy
  end
end
~~~

This does not rely on any methods being present on all objects
in the system, and thus avoids the underlying problem altogether.

## (Almost) All Matchers Are Supported

The new `expect` syntax looks different from the old
`should` syntax, but under the covers, it's essentially
the same. You pass a matcher to the `#to` method, and
it fails the example if it does not match.

All matchers are supported, with an important exception:
the `expect` syntax does not directly support the operator
matchers.

~~~ ruby
# rather than:
foo.should == bar

# ...use:
expect(foo).to eq(bar)
~~~

While operator matchers are intuitive to use, they require
special handling in RSpec for them to work right, due to Ruby's
precedence rules. Furthermore, `should ==` generates a ruby
warning[^foot_1], and people have been occasionally surprised by
the fact that `should !=` does not work as they might expect[^foot_2].

The new syntax affords us the chance to make a clean
break from the inconsistencies of the operator matchers
without the risk of breaking existing test suites, so
we decided not to support operator matchers with
the new syntax. Here's a listing of each of the old
operator matchers (used with `should`), and their `expect` equivalent:

~~~ ruby
foo.should == bar
expect(foo).to eq(bar)

"a string".should_not =~ /a regex/
expect("a string").not_to match(/a regex/)

[1, 2, 3].should =~ [2, 1, 3]
expect([1, 2, 3]).to match_array([2, 1, 3])
~~~

You may have noticed I didn't list the comparison matchers
(e.g. `x.should < 10`)--that's because they work but have
never been recommended. Who says "x should less than 10"?
They were always intended to be used with `be`, which
both reads better and continues to work:

~~~ ruby
foo.should be < 10
foo.should be <= 10
foo.should be > 10
foo.should be >= 10
expect(foo).to be < 10
expect(foo).to be <= 10
expect(foo).to be > 10
expect(foo).to be >= 10
~~~

## Unification of Block vs. Value Syntaxes

`expect` has actually been available in RSpec for a long
time[^foot_3] in a limited form, as a more-readable alternative
for block expectations:

~~~ ruby
# rather than:
lambda { do_something }.should raise_error(SomeError)

# ...you can do:
expect { something }.to raise_error(SomeError)
~~~

Before RSpec 2.11, `expect` would not accept any normal arguments,
and could not be used for value expectations. With the changes
in 2.11, it's nice to have the unity of the same syntax for both
kinds of expectations.

## Configuration Options

By default, both the `should` and `expect` syntaxes are
available. However, if you want to use only one syntax
or the other, you can configure RSpec:

~~~ ruby
# spec_helper.rb
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    # Disable the `expect` sytax...
    c.syntax = :should

    # ...or disable the `should` syntax...
    c.syntax = :expect

    # ...or explicitly enable both
    c.syntax = [:should, :expect]
  end
end
~~~

For example, if you're starting a new project, and you want
to ensure only `expect` is used for consistency, you can disable
`should` entirely. When one of the syntaxes is disabled, the
corresponding method will simply be undefined.

In the future, we plan to change the defaults so that only
`expect` is available unless you explicitly enable `should`.
We may do this as soon as RSpec 3.0, but we want to give
users plenty of time to get acquianted with it.

Let us know what you think!

[^foot_1]: As [Mislav reports](https://mislav.net/2011/06/ruby-verbose-mode/), when warnings are turned on, you can get a "Useless use of == in void context" warning.

[^foot_2]: On ruby 1.8, `x.should != y` is syntactic sugar for `!(x.should == y)` and RSpec has no way to distinguish `should ==` from `should !=`. On 1.9, we can distinguish between them (since `!=` can now be defined as a separate method), but it would be confusing to support it on 1.9 but not on 1.8, so we [decided to just raise an error instead](https://github.com/rspec/rspec-expectations/issues/33).

[^foot_3]: It was originally added [over 3 years ago!](https://github.com/dchelimsky/rspec/commit/7e4f872b4becbd41588da95c0e5d954a6e770293)
