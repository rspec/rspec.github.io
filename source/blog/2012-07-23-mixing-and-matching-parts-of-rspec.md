---
title: Mixing and Matching Parts of RSpec
author: Myron Marston
---

RSpec was split into three subprojects for the last major release
(2.0):

* rspec-core: The test runner and main DSL (`describe`, `it`, `before`,
  `after`, `let`, `shared_examples`, etc).
* rspec-expectations: Provides a readable syntax for specifying the
  expected outcomes of your tests using matchers.
* rspec-mocks: RSpec's test-double framework.

One of the cool things about this is that it allows you to mix and
match parts of RSpec with other testing libraries. Unfortunately, even
though RSpec 2 has been out for over 18 months, there's not a lot of
good information out there about how to do that.

I want to correct that by showing a few examples of the possibilities.

All of the examples below have some setup/configuration code at the top
that you would probably want to extract into `test_helper.rb` or
`spec_helper.rb` in a real project.

I made a [github
project](https://github.com/myronmarston/mix_and_match_rspec) with
all these examples, so check that out if you want some code you can
play with.

## Using rspec-core with another assertion library

If you like RSpec's test runner, but don't like the syntax and
failure output provided by rspec-expectations, you can use the
assertions from the standard library provided by
[MiniTest](http://ruby-doc.org/stdlib-1.9.3/libdoc/minitest/unit/rdoc/MiniTest/Assertions.html):

~~~ ruby
# rspec_and_minitest_assertions.rb
require 'set'

RSpec.configure do |rspec|
  rspec.expect_with :stdlib
end

describe Set do
  specify "a passing example" do
    set = Set.new
    set << 3 << 4
    assert_include set, 3
  end

  specify "a failing example" do
    set = Set.new
    set << 3 << 4
    assert_include set, 5
  end
end
~~~

The output:

~~~
$ rspec rspec_and_minitest_assertions.rb 
.F

Failures:

  1) Set a failing example
     Failure/Error: assert_include set, 5
     MiniTest::Assertion:
       Expected #<Set: {3, 4}> to include 5.
     # ./rspec_and_minitest_assertions.rb:17:in `block (2 levels) in <top (required)>'

Finished in 0.00093 seconds
2 examples, 1 failure

Failed examples:

rspec ./rspec_and_minitest_assertions.rb:14 # Set a failing example
~~~

[Wrong](https://github.com/sconover/wrong/) is an interesting
alternative that uses a single method (`assert` with a block) to
provide detailed failure output:

~~~ ruby
# rspec_and_wrong.rb
require 'set'
require 'wrong'

RSpec.configure do |rspec|
  rspec.expect_with Wrong
end

describe Set do
  specify "a passing example" do
    set = Set.new
    set << 3 << 4
    assert { set.include?(3) }
  end

  specify "a failing example" do
    set = Set.new
    set << 3 << 4
    assert { set.include?(5) }
  end
end
~~~

The output:

~~~
$ rspec rspec_and_wrong.rb
.F

Failures:

  1) Set a failing example
     Failure/Error: assert { set.include?(5) }
     Wrong::Assert::AssertionFailedError:
       Expected set.include?(5), but
           set is #<Set: {3, 4}>
     # ./rspec_and_wrong.rb:18:in `block (2 levels) in <top (required)>'

Finished in 0.04012 seconds
2 examples, 1 failure

Failed examples:

rspec ./rspec_and_wrong.rb:15 # Set a failing example
~~~

As demonstrated by these examples, you simply configure `expect_with` to
use an alternate library. You can specify `:stdlib`, `:rspec` (to be
explicit about using rspec-expectations) or any module; the module will
be mixed in to the example context.

## Using minitest and rspec-expectations

If you like running your tests with MiniTest but prefer
the syntax and failure output of rspec-expectations, you
can combine them:

~~~ ruby
# minitest_and_rspec_expectations.rb
require 'minitest/autorun'
require 'rspec/expectations'
require 'set'

RSpec::Matchers.configuration.syntax = :expect

module MiniTest
  remove_const :Assertion # so we can re-assign it w/o a ruby warning

  # So expectation failures are considered failures, not errors.
  Assertion = RSpec::Expectations::ExpectationNotMetError

  class Unit::TestCase
    include RSpec::Matchers

    # So each use of `expect` is counted as an assertion...
    def expect(*a, &b)
      assert(true)
      super
    end
  end
end

class TestSet < MiniTest::Unit::TestCase
  def test_passing_expectation
    set = Set.new
    set << 3 << 4
    expect(set).to include(3)
  end

  def test_failing_expectation
    set = Set.new
    set << 3 << 4
    expect(set).to include(5)
  end
end
~~~

The output:

~~~
$ ruby minitest_and_rspec_expectations.rb
Run options: --seed 12759

# Running tests:

.F

Finished tests in 0.001991s, 1004.5203 tests/s, 1004.5203 assertions/s.

  1) Failure:
test_failing_expectation(TestSet)
[/Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-expectations-2.11.1/lib/rspec/expectations/handler.rb:17]:
expected #<Set: {3, 4}> to include 5

2 tests, 2 assertions, 1 failures, 0 errors, 0 skips
~~~

Let's take the integration code bit-by-bit:

* `RSpec::Matchers.configuration.syntax = :expect` configures the
  desired rspec-expectations syntax to just the [new expect
  syntax](/blog/2012/06/rspecs-new-expectation-syntax). By
  default, both the old `should` and the new `expect` syntaxes
  are available.
* MiniTest treats `MiniTest::Assertion` exceptions differently
  from other errors, counting them as test failures rather
  than errors in the output. We re-assign the constant to
  `RSpec::Expectations::ExpectationNotMetError` in order to
  have our expectation failures counted as failures, not errors.
* MiniTest's output includes a count of the total number of assertions and
  the number of assertions per second. We add a call to `assert(true)`
  every time `expect` is called so the counts are correct.
* Finally, we include `RSpec::Matchers` into the test context
  to make `expect` and the matchers available.

For other test runners, you could probably get by with just
mixing `RSpec::Matchers` into your test context--most of the
rest of this is MiniTest-specific.

## Using minitest and rspec-mocks

MiniTest features a mock object framework, that, in [the words of the
README](https://github.com/seattlerb/minitest/blob/master/lib/minitest/mock.rb),
"is a beautifully tiny mock (and stub) object framework". It is indeed
beautiful and tiny. However, rspec-mocks has many more features, and
if you like those features, you can easily use it with MiniTest:

~~~ ruby
# minitest_and_rspec_mocks.rb
require 'minitest/autorun'
require 'rspec/mocks'

MiniTest::Unit::TestCase.add_setup_hook do |test_case|
  RSpec::Mocks.setup(test_case)
end

MiniTest::Unit::TestCase.add_teardown_hook do |test_case|
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end

class TestSet < MiniTest::Unit::TestCase
  def test_passing_mock
    foo = mock
    foo.should_receive(:bar)
    foo.bar
  end

  def test_failing_mock
    foo = mock
    foo.should_receive(:bar)
  end

  def test_stub_real_object
    Object.stub(foo: "bar")
    assert_equal "bar", Object.foo
  end
end
~~~

The output:

~~~
$ ruby minitest_and_rspec_mocks.rb 
Run options: --seed 27480

# Running tests:

..E

Finished tests in 0.002546s, 1178.3189 tests/s, 392.7730 assertions/s.

  1) Error:
test_failing_mock(TestSet):
RSpec::Mocks::MockExpectationError: (Mock).bar(any args)
    expected: 1 time
    received: 0 times
    minitest_and_rspec_mocks.rb:25:in `test_failing_mock'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/error_generator.rb:87:in `__raise'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/error_generator.rb:46:in `raise_expectation_error'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/message_expectation.rb:259:in `generate_error'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/message_expectation.rb:215:in `verify_messages_received'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/method_double.rb:117:in `block in verify'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/method_double.rb:117:in `each'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/method_double.rb:117:in `verify'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/proxy.rb:96:in `block in verify'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/proxy.rb:96:in `each'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/proxy.rb:96:in `verify'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/methods.rb:116:in `rspec_verify'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/space.rb:11:in `block in verify_all'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/space.rb:10:in `each'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks/space.rb:10:in `verify_all'
    /Users/myron/.rvm/gems/ruby-1.9.3-p194/gems/rspec-mocks-2.11.1/lib/rspec/mocks.rb:19:in `verify'
    minitest_and_rspec_mocks.rb:10:in `block in <main>'

3 tests, 1 assertions, 0 failures, 1 errors, 0 skips
~~~

The integration here is a little more manual, but it's not bad:

* Call `RSpec::Mocks.setup(test)` before each test or example to ensure
  things are setup properly.
* Call `RSpec::Mocks.verify` after each test or example so that mock
  expectations are checked.
* Call `RSpec::Mocks.teardown` at the very end to ensure that any
  modifications to real objects (for a stub, for example) are cleaned
  up. Note: this _must_ be called after every test (even failing ones)
  to prevent stubs from "leaking" outside of a given test. That's why
  I put this in the `ensure` clause above.

## Using rspec-core with another mocking library

RSpec can easily be used with an alternate mocking library.
In fact, many RSpec users prefer
[Mocha](http://gofreerange.com/mocha/docs/) to rspec-mocks,
and the two can integrate just fine:

~~~ ruby
# rspec_and_mocha.rb
RSpec.configure do |rspec|
  rspec.mock_with :mocha
end

describe "RSpec and Mocha" do
  specify "a passing mock" do
    foo = mock
    foo.expects(:bar)
    foo.bar
  end

  specify "a failing mock" do
    foo = mock
    foo.expects(:bar)
  end

  specify "stubbing a real object" do
    foo = Object.new
    foo.stubs(bar: 3)
    expect(foo.bar).to eq(3)
  end
end
~~~

The output:

~~~
rspec rspec_and_mocha.rb 
.F.

Failures:

  1) RSpec and Mocha a failing mock
     Failure/Error: foo.expects(:bar)
     Mocha::ExpectationError:
       not all expectations were satisfied
       unsatisfied expectations:
       - expected exactly once, not yet invoked: #<Mock:0x7fcc01844840>.bar(any_parameters)
     # ./rspec_and_mocha.rb:14:in `block (2 levels) in <top (required)>'

Finished in 0.00388 seconds
3 examples, 1 failure

Failed examples:

rspec ./rspec_and_mocha.rb:12 # RSpec and Mocha a failing mock
~~~

You can similarly configure `mock_with :flexmock` or
`mock_with :rr` to use one of those mocking libraries.  I didn't
include those examples here because they're configured in the
exact same way, but [the github
repo](https://github.com/myronmarston/mix_and_match_rspec) containing
all the examples in this blog post has examples for them, too.

## Conclusion

It takes some extra leg work, but most of ruby's testing tools
can integrate with each other without any problems, so don't
feel constrained to use all of MiniTest or all of RSpec if
there's parts you love and parts you dislike. Use a testing
stack that best meets your needs.

