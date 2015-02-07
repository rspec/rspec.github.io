---
title: RSpec 3.2 has been released!
author: Myron Marston
---

RSpec 3.2 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3.0 or 3.1, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 915 commits and 278
merged pull requests from over 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Windows CI

RSpec has always supported Windows, but the fact that all the core
maintainers develop on POSIX systems has occasionally made that
difficult. When RSpec 3.1 was released, we unfortunately broke
a couple things on Windows without knowing about it until some
users reported the issues (which were later fixed in 3.1.x patch
releases). We'd like to prevent that from happening again, so
this time around we've put effort into getting Windows CI builds
going on [AppVeyor](http://www.appveyor.com/).

We have passing Windows builds, but there's still more to do here.
If you're an RSpec and Windows user and would like to help us out,
please get in touch!

### Core: Pending Example Output Includes Failure Details

RSpec 3.0 shipped with new semantics for `pending`.  Rather than
skipping the example (now available using `skip`), pending examples
are executed with an expectation that a failure will occur, and, if
there is no failure, they'll fail to notify you that they no longer
need to be marked as `pending`.  This change is quite useful, as it
ensures that every `pending` example needs to be pending.  However,
the formatter output didn't indicate the failure that forced the
example to remain pending, so you had to un-pend the example to see
that detail.

In RSpec 3.2, we've rectified this: `pending` example output now
includes the failure that occurred while executing the example.

### Core: Each Example Now Has a Singleton Group

RSpec has a number of metadata-based features that, before now,
would only apply to example groups, not individual examples:

~~~ ruby
RSpec.configure do |config|
  # 1. Filtered module inclusion: examples in groups tagged with `:uses_time`
  #    will have access to the instance methods of `TimeHelpers`
  config.include TimeHelpers, :uses_time

  # 2. Context hooks: a browser will start before groups tagged
  #    with `:uses_browser` and shutdown afterwards.
  config.before(:context, :uses_browser) { Browser.start }
  config.after( :context, :uses_browser) { Browser.shutdown }
end

# 3. Shared context auto-inclusion: groups tagged with
#    `:uses_redis` will have this context included.
RSpec.shared_context "Uses Redis", :uses_redis do
  let(:redis) { Redis.connect(ENV['REDIS_URL']) }
  before { redis.flushdb }
end
~~~

In each of these cases, individual examples tagged with the
appropriate metadata would not have these constructs applied to them,
which could be easy to forget. That's changing in RSpec 3.2: we now
treat every example as being implicitly part of a singleton example
group of just one example, and that allows us to apply these constructs
to individual examples, and not just groups. If you're familiar with
Ruby's object model, this may sound familiar -- every object in Ruby
has a singleton class that holds custom behavior that applies to that
instance only. This feature was trivially implemented on top of Ruby's
singleton classes.

### Core: Performance Improvements

We put some significant effort into optimizing rspec-core's performance
for RSpec 3.2. Besides some algorithmic changes and numerous micro-optimizations,
we also found ways to greatly reduce the number of object allocations
done by rspec-core. According to [my
benchmarks](https://gist.github.com/myronmarston/5de3daf2cfaf07a73e6b), RSpec 3.2 allocates
~30% fewer objects than RSpec 3.1, all while gaining numerous new features.

In future releases, I'm hoping we can apply similar improvements
to rspec-expectations and rspec-mocks.

### Core: New Sandboxing API

RSpec is tested using RSpec. In rspec-core, many of the specs in our
spec suite define and run example groups and examples to verify the
behavior of how RSpec's various constructs relate when when run in
a real RSpec context. To facilitate this dog-fooding, rspec-core's
spec suite has long used a _sandboxing_ technique. Each spec
is free to mutate configuration and define example groups and examples
without worrying about how that could interfere with the RSpec runner's
internal state.

This sandboxing is obviously useful for RSpec's own internal use, but
it's also useful for testing 3rd party RSpec extensions. We now offer
it as a new public API:

~~~ ruby
# You have to require this file to make this API available...
require 'rspec/core/sandbox'

RSpec.configure do |config|
  config.around do |ex|
    RSpec::Core::Sandbox.sandboxed(&ex)
  end
end
~~~

Thanks to Tyler Ball for [implementing
this](https://github.com/rspec/rspec-core/pull/1808).

### Core: Shared Example Group Improvements

In this release we fixed several long-standing bugs and annoyances
with shared example groups:

* Failures from examples defined in shared groups now include a full
  shared example group inclusion backtrace so you can pinpoint the
  exact inclusion that contains the failure. [#1763](https://github.com/rspec/rspec-core/pull/1763)
* The re-run command printed for a shared example group failure
  should now always work to re-run the failed example (although it
  may run additional examples, too). [#1835](https://github.com/rspec/rspec-core/pull/1835)
* Location filtering applied to a shared example now works properly
  for some odd edge cases where it previously failed. [#1837](https://github.com/rspec/rspec-core/pull/1837)

If you've had issues with shared example groups in the past due to
issues like these, you may want to give them another try.

### Expectations: Chain Shorthand For DSL-Defined Custom Matchers

The custom matcher DSL has a `chain` method that makes it easy to
add fluent interfaces to your matchers:

~~~ ruby
RSpec::Matchers.define :be_bigger_than do |min|
  chain :but_smaller_than do |max|
    @max = max
  end

  match do |value|
    value > min && value < @max
  end
end

# usage:
expect(10).to be_bigger_than(5).but_smaller_than(15)
~~~

As this example shows, the most common use of `chain` it to accept an
additional argument that is used in the `match` logic somehow. Tom
Stuart [suggested and
implemented](https://github.com/rspec/rspec-expectations/pull/644) an
improvement that allows you to shorten the matcher definition to:

~~~ ruby
RSpec::Matchers.define :be_bigger_than do |min|
  chain :but_smaller_than, :max
  match do |value|
    value > min && value < max
  end
end
~~~

The second argument to `chain` -- `:max` -- is used to define a `max`
attribute that gets set to the argument passed to `but_smaller_than`.

Thanks, Tom Stuart!

### Expectations: Output Matchers Can Handle Subprocesses

RSpec 3.0 shipped with a new `output` matcher that allows you to specify
expected output to either `stdout` or `stderr`:

~~~ ruby
expect { print 'foo' }.to output('foo').to_stdout
expect { warn  'foo' }.to output(/foo/).to_stderr
~~~

The mechanism used for these matchers -- temporarily replacing `$stdout`
or `$stderr` with a `StringIO` for the duration of the block -- is pretty simple but does
not work when you spawn subprocesses that output to one of these
streams. For example, this fails:

~~~ ruby
expect { system('echo foo') }.to output("foo\n").to_stdout
~~~

In RSpec 3.2, you can replace `to_stdout` with
`to_stdout_from_any_process` and this expectation will work.

~~~ ruby
expect { system('echo foo') }.to output("foo\n").to_stdout_from_any_process
~~~

This uses an alternate mechanism, where `$stdout` is temporarily
reopened to a temp file, that works with subprocesses. Unfortunately,
it's also much, much slower -- in our
[benchmark](https://github.com/rspec/rspec-expectations/blob/v3.2.0/benchmarks/output_stringio_vs_tempfile.rb),
it's 30 times slower! For this reason, you have to opt-in to it using
`to_std(out|err)_from_any_process` in place of `to_std(out|err)`.

Thanks to Alex Genco for
[implementing](https://github.com/rspec/rspec-expectations/pull/700) this improvement!

### Expectations: DSL-Defined Custom Matchers Can Now Receive Blocks

When defining a custom matcher using the DSL, there are situations
where it would be nice to accept a block:

~~~ ruby
RSpec::Matchers.define :be_sorted_by do |&blk|
  match do |array|
    array.each_cons(2).all? do |a, b|
      (blk.call(a) <=> blk.call(b)) <= 0
    end
  end
end

# intended usage:
expect(users).to be_sorted_by(&:email)
~~~

Unfortunately, Ruby restrictions do not allow us to support this. The
`define` block is executed using `class_exec`, which ensures it is
evaluated in the context of a new matcher class, while also allowing us
to forward arguments from the call site to the `define` block. The block
passed to `class_exec` is the one to be evaluated (in this case, the
`define` block) and there is no way to pass two blocks to `class_exec`.

In prior versions of RSpec, the block passed to `be_sorted_by` would be
silently ignored. In RSpec 3.2, we now issue a warning:

~~~
WARNING: Your `be_sorted_by` custom matcher receives a block argument (`blk`), but
due to limitations in ruby, RSpec cannot provide the block. Instead, use the
`block_arg` method to access the block. Called from path/to/file.rb:line_number.
~~~

...which tells you an alternate way to accomplish this: the new `block_arg`
method, available from within a custom matcher:

~~~ ruby
RSpec::Matchers.define :be_sorted_by do
  match do |array|
    array.each_cons(2).all? do |a, b|
      (block_arg.call(a) <=> block_arg.call(b)) <= 0
    end
  end
end
~~~

Thanks to Mike Dalton for
[implementing](https://github.com/rspec/rspec-expectations/pull/645) this improvement.

### Mocks: `any_args` Works as an Arg Splat

RSpec has had an `any_args` matcher for a long time:

~~~ ruby
expect(test_double).to receive(:message).with(any_args)
~~~

The `any_args` matcher behaves exactly like it reads: it allows any
arguments (including none) to match the message expectation. In RSpec
3.1 and before, `any_args` could only be used as a stand-alone argument
to `with`. In RSpec 3.2, we treat it as an arg splat, so you can now
use it anywhere in an argument list:

~~~ ruby
expect(test_double).to receive(:message).with(1, 2, any_args)
~~~

This would match calls like `test_double.message(1, 2)` or
`test_double.message(1, 2, 3, 4)`.

### Mocks: Mismatched Args Are Now Diffed

A big part of what has made RSpec's failure output so useful is the diff
that you get for failures from particular matchers. However, message
expectation failures have never included a diff. For example, consider
this failing message expectation:

~~~ ruby
test_double = double
expect(test_double).to receive(:foo).with(%w[ 1 2 3 4 ].join("\n"))
test_double.foo(%w[ 1 2 5 4 ].join("\n"))
~~~

In RSpec 3.1 and before, this failed with:

~~~
Failure/Error: test_double.foo(%w[ 1 2 5 4 ].join("\n"))
  Double received :foo with unexpected arguments
    expected: ("1\n2\n3\n4")
         got: ("1\n2\n5\n4")
~~~

RSpec 3.2 now includes diffs in message expectation failures when
appropriate (generally when multi-line strings are involved or when
the pretty-print output of the objects are multi-line). In 3.2, this
fails with:

~~~
Failure/Error: test_double.foo(%w[ 1 2 5 4 ].join("\n"))
  Double received :foo with unexpected arguments
    expected: ("1\n2\n3\n4")
         got: ("1\n2\n5\n4")
  Diff:
  @@ -1,5 +1,5 @@
   1
   2
  -3
  +5
   4
~~~

Thanks to Pete Higgins for [originally suggesting](https://github.com/rspec/rspec-mocks/issues/434)
this feature, and for [extracting our differ](https://github.com/rspec/rspec-support/pull/36)
from rspec-expectation to rspec-support, and thanks to Sam Phippen for
[updating rspec-mocks](https://github.com/rspec/rspec-mocks/pull/751) to use
the newly available differ.

### Mocks: Verifying Doubles Can Be Named

RSpec's `double` has always supported an optional name, which gets
used in message expectation failures. In RSpec 3.0, we added some new
test double types -- `instance_double`, `class_double` and `object_double` --
and in 3.1, we added `instance_spy`, `class_spy` and `object_spy`...but
we forgot to support an optional name for these types.  In RSpec 3.2,
these double types now support an optional name. Just pass a second
argument (after the interface argument, but before any stubs):

~~~ ruby
book_1 = instance_double(Book, "The Brothers Karamozov", author: "Fyodor Dostoyevsky")
book_2 = instance_double(Book, "Lord of the Rings", author: "J.R.R. Tolkien")
~~~

Thanks to Cezary Baginski for [implementing](https://github.com/rspec/rspec-mocks/pull/826) this.

### Rails: Instance Doubles Support Dynamic Column Methods Defined by ActiveRecord

ActiveRecord defines a number of methods on your model
class based on the column schema of the underlying table. This happens
dynamically the first time you call one of these methods. Unfortunately,
this led to confusing behavior when using an ActiveRecord-based `instance_double`: since
`User.method_defined?(:email)` returned `false` until a column method
was called for the first time, `instance_double(User)` would initially
not allow `email` to be stubbed until the column methods had been
dynamically defined.

We [documented this
issue](https://relishapp.com/rspec/rspec-mocks/v/3-1/docs/verifying-doubles/dynamic-classes)
but it was still a source of frequent confusion with users. In RSpec
3.2, we've addressed this -- we now force the model to define the
column methods when an ActiveRecord-based `instance_double` is created
so that the verified double works as expected.

Thanks to Jon Rowe for
[implementing](https://github.com/rspec/rspec-rails/pull/1238) this improvement!

### Rails: Support Ruby 2.2 with Rails 3.2 and 4.x

Ruby 2.2 was released in December, and while most Ruby 2.1 code bases
work just fine on 2.2, there were a few changes the Rails core team
had to make to Rails to support 2.2. Likewise, Aaron Kromer has updated
rspec-rails to support [Rails
3.2](https://github.com/rspec/rspec-rails/pull/1277) and [Rails
4.x](https://github.com/rspec/rspec-rails/pull/1264).

### Rails: New Generator for ActionMailer Previews

ActionMailer previews were one of the [new
features](http://guides.rubyonrails.org/4_1_release_notes.html#action-mailer-previews) in Rails 4.1.
By default, Rails generates the preview classes in your `test`
directory. Since RSpec projects use `spec` instead of `test`,
this didn't integrate well with rspec-rails.

In 3.2, rspec-rails now ships with a generator that will put
ActionMailer preview classes in your `spec` directory, providing
the same functionality that Rails already provides to Test::Unit and
Minitest users.

Thanks to Takashi Nakagawa for the [initial
implementation](https://github.com/rspec/rspec-rails/pull/1185)
and to Aaron Kromer for [further
improvements](https://github.com/rspec/rspec-rails/pull/1236).

## Stats

### Combined: 

* **Total Commits**: 915
* **Merged pull requests**: 278
* **54 contributors**: Aaron Kromer, Akos Vandra, Alex Chaffee, Alex Genco, Alexey Fedorov, Andy Waite, Arlandis Lawrence, Avner Cohen, Ben Moss, Ben Snape, Benjamin Fleischer, Brian Kane, Cezary Baginski, ChaYoung You, Christian Nelson, Dennis Ideler, Durran Jordan, Elena Sharma, Elia Schito, Eliot Sykes, Fumiaki MATSUSHIMA, Griffin Smith, Guido Günther, Jim Kingdon, Jon Rowe, Jonathan, Jonathan Rochkind, Jori Hardman, Kevin Mook, Max Lincoln, Melanie Gilman, Michael Stock, Mike Dalton, Myron Marston, Peter Rhoades, Piotr Jakubowski, Postmodern, Rebecca Skinner, Ryan Fitzgerald, Sam Phippen, Scott Archer, Siva Gollapalli, Takashi Nakagawa, Thaddee Tyl, Thales Oliveira, Tim Wade, Tom Schady, Tom Stuart, Tony Novak, Xavier Shay, Yorick Peterse, Yuji Nakayama, dB, tyler-ball

### rspec-core: 

* **Total Commits**: 364
* **Merged pull requests**: 89
* **23 contributors**: Aaron Kromer, Akos Vandra, Alex Chaffee, Alexey Fedorov, Arlandis Lawrence, Ben Moss, Ben Snape, Cezary Baginski, ChaYoung You, Christian Nelson, Durran Jordan, Fumiaki MATSUSHIMA, Guido Günther, Jim Kingdon, Jon Rowe, Jonathan Rochkind, Kevin Mook, Max Lincoln, Mike Dalton, Myron Marston, Sam Phippen, Tom Schady, tyler-ball

### rspec-expectations: 

* **Total Commits**: 123
* **Merged pull requests**: 45
* **14 contributors**: Aaron Kromer, Alex Genco, Alexey Fedorov, Avner Cohen, Ben Moss, Elia Schito, Jon Rowe, Jonathan, Jori Hardman, Mike Dalton, Myron Marston, Postmodern, Siva Gollapalli, Tom Stuart

### rspec-mocks: 

* **Total Commits**: 180
* **Merged pull requests**: 61
* **17 contributors**: Aaron Kromer, Andy Waite, Ben Moss, Cezary Baginski, Jon Rowe, Melanie Gilman, Myron Marston, Piotr Jakubowski, Ryan Fitzgerald, Sam Phippen, Siva Gollapalli, Tim Wade, Tom Schady, Tony Novak, Xavier Shay, Yorick Peterse, dB

### rspec-rails: 

* **Total Commits**: 136
* **Merged pull requests**: 42
* **17 contributors**: Aaron Kromer, Ben Moss, Brian Kane, Dennis Ideler, Elena Sharma, Eliot Sykes, Griffin Smith, Jon Rowe, Michael Stock, Myron Marston, Peter Rhoades, Rebecca Skinner, Sam Phippen, Takashi Nakagawa, Thaddee Tyl, Thales Oliveira, Yuji Nakayama

### rspec-support: 

* **Total Commits**: 112
* **Merged pull requests**: 41
* **10 contributors**: Aaron Kromer, Alex Genco, Alexey Fedorov, Ben Moss, Benjamin Fleischer, Jon Rowe, Myron Marston, Sam Phippen, Scott Archer, Yorick Peterse

## Docs

### API Docs

* [rspec-core](/documentation/3.2/rspec-core/)
* [rspec-expectations](/documentation/3.2/rspec-expectations/)
* [rspec-mocks](/documentation/3.2/rspec-mocks/)
* [rspec-rails](/documentation/3.2/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core-3.2.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.1.7...v3.2.0)

Enhancements:

* Improve the `inspect` output of example groups. (Mike Dalton, #1687)
* When rake task fails, only output the command if `verbose` flag is
  set. (Ben Snape, #1704)
* Add `RSpec.clear_examples` as a clear way to reset examples in between
  spec runs, whilst retaining user configuration.  (Alexey Fedorov, #1706)
* Reduce string allocations when defining and running examples by 70%
  and 50% respectively. (Myron Marston, #1738)
* Removed dependency on pathname from stdlib. (Sam Phippen, #1703)
* Improve the message presented when a user hits Ctrl-C.
  (Alex Chaffee #1717, #1742)
* Improve shared example group inclusion backtrace displayed
  in failed example output so that it works for all methods
  of including shared example groups and shows all inclusion
  locations. (Myron Marston, #1763)
* Issue seed notification at start (as well as the end) of the reporter
  run. (Arlandis Word, #1761)
* Improve the documentation of around hooks. (Jim Kingdon, #1772)
* Support prepending of modules into example groups from config and allow
  filtering based on metadata. (Arlandis Word, #1806)
* Emit warnings when `:suite` hooks are registered on an example group
  (where it has always been ignored) or are registered with metadata
  (which has always been ignored). (Myron Marston, #1805)
* Provide a friendly error message when users call RSpec example group
  APIs (e.g. `context`, `describe`, `it`, `let`, `before`, etc) from
  within an example where those APIs are unavailable. (Myron Marston, #1819)
* Provide a friendly error message when users call RSpec example
  APIs (e.g. `expect`, `double`, `stub_const`, etc) from
  within an example group where those APIs are unavailable.
  (Myron Marston, #1819)
* Add new `RSpec::Core::Sandbox.sandboxed { }` API that facilitates
  testing RSpec with RSpec, allowing you to define example groups
  and example from within an example without affecting the global
  `RSpec.world` state. (Tyler Ball, 1808)
* Apply line-number filters only to the files they are scoped to,
  allowing you to mix filtered and unfiltered files. (Myron Marston, #1839)
* When dumping pending examples, include the failure details so that you
  don't have to un-pend the example to see it. (Myron Marston, #1844)
* Make `-I` option support multiple values when separated by
  `File::PATH_SEPARATOR`, such as `rspec -I foo:bar`. This matches
  the behavior of Ruby's `-I` option. (Fumiaki Matsushima, #1855).

Bug Fixes:

* When assigning generated example descriptions, surface errors
  raised by `matcher.description` in the example description.
  (Myron Marston, #1771)
* Don't consider expectations from `after` hooks when generating
  example descriptions. (Myron Marston, #1771)
* Don't apply metadata-filtered config hooks to examples in groups
  with matching metadata when those examples override the parent
  metadata value to not match. (Myron Marston, #1796)
* Fix `config.expect_with :minitest` so that `skip` uses RSpec's
  implementation rather than Minitest's. (Jonathan Rochkind, #1822)
* Fix `NameError` caused when duplicate example group aliases are defined and
  the DSL is not globally exposed. (Aaron Kromer, #1825)
* When a shared example defined in an external file fails, use the host
  example group (from a loaded spec file) for the re-run command to
  ensure the command will actually work. (Myron Marston, #1835)
* Fix location filtering to work properly for examples defined in
  a nested example group within a shared example group defined in
  an external file. (Bradley Schaefer, Xavier Shay, Myron Marston, #1837)
* When a pending example fails (as expected) due to a mock expectation,
  set `RSpec::Core::Example::ExecutionResult#pending_exception` --
  previously it was not being set but should have been. (Myron Marston, #1844)
* Fix rake task to work when `rspec-core` is installed in a directory
  containing a space. (Guido Günther, #1845)
* Fix regression in 3.1 that caused `describe Regexp` to raise errors.
  (Durran Jordan, #1853)
* Fix regression in 3.x that caused the profile information to be printed
  after the summary. (Max Lincoln, #1857)
* Apply `--seed` before loading `--require` files so that required files
  can access the provided seed. (Myron Marston, #1745)
* Handle `RSpec::Core::Formatters::DeprecationFormatter::FileStream` being
  reopened with an IO stream, which sometimes happens with spring.
  (Kevin Mook, #1757)


### rspec-expectations-3.2.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.1.2...v3.2.0)

Enhancements:

* Add `block_arg` method to custom matcher API, which allows you to
  access the block passed to a custom matcher, if there is one.
  (Mike Dalton, #645)
* Provide more detail in failure message of `yield_control` matcher.
  (Jon Rowe, #650)
* Add a shorthand syntax for `chain` in the matcher DSL which assigns values
  for use elsewhere, for example `chain :and_smaller_than, :small_value`
  creates an `attr_reader` for `small_value` (Tom Stuart, #644)
* Provide a more helpful deprecation message when using the `should` syntax.
  (Elia Schito, #663)
* Provide more detail in the `have_attributes` matcher failure message.
  (Jon Rowe,  #668)
* Make the `have_attributes` matcher diffable.
  (Jon Rowe, Alexey Fedorov, #668)
* Add `output(...).to_std(out|err)_from_any_process` as alternatives
  to `output(...).to_std(out|err)`. The latter doesn't work when a sub
  process writes to the named stream but is much faster.
  (Alex Genco, #700)
* Improve compound matchers (created by `and` and `or`) so that diffs
  are included in failures when one or more of their matchers
  are diffable. (Alexey Fedorov, #713)

Bug Fixes:

* Avoid calling `private_methods` from the `be` predicate matcher on
  the target object if the object publicly responds to the predicate
  method. This avoids a possible error that can occur if the object
  raises errors from `private_methods` (which can happen with celluloid
  objects). (@chapmajs, #670)
* Make `yield_control` (with no modifier) default to
  `at_least(:once)` rather than raising a confusing error
  when multiple yields are encountered.
  (Myron Marston, #675)
* Fix "instance variable @color not initialized" warning when using
  rspec-expectations outside of an rspec-core context. (Myron Marston, #689)
* Fix `start_with` and `end_with` to work properly when checking a
  string against an array of strings. (Myron Marston, #690)
* Don't use internally delegated matchers when generating descriptions
  for examples without doc strings. (Myron Marston, #692)


### rspec-mocks-3.2.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.1.3...v3.2.0)

Enhancements:

* Treat `any_args` as an arg splat, allowing it to match an arbitrary
  number of args at any point in an arg list. (Myron Marston, #786)
* Print diffs when arguments in mock expectations are mismatched.
  (Sam Phippen, #751)
* Support names for verified doubles (`instance_double`, `instance_spy`,
  `class_double`, `class_spy`, `object_double`, `object_spy`). (Cezary
  Baginski, #826)
* Make `array_including` and `hash_including` argument matchers composable.
  (Sam Phippen, #819)
* Make `allow_any_instance_of(...).to receive(...).and_wrap_original`
  work. (Ryan Fitzgerald, #869)

Bug Fixes:

* Provide a clear error when users wrongly combine `no_args` with
  additional arguments (e.g. `expect().to receive().with(no_args, 1)`).
  (Myron Marston, #786)
* Provide a clear error when users wrongly use `any_args` multiple times in the
  same argument list (e.g. `expect().to receive().with(any_args, 1, any_args)`.
  (Myron Marston, #786)
* Prevent the error generator from using user object #description methods.
  See [#685](https://github.com/rspec/rspec-mocks/issues/685).
  (Sam Phippen, #751)
* Make verified doubles declared as `(instance|class)_double(SomeConst)`
  work properly when `SomeConst` has previously been stubbed.
  `(instance|class)_double("SomeClass")` already worked properly.
  (Myron Marston, #824)
* Add a matcher description for `receive`, `receive_messages` and
  `receive_message_chain`. (Myron Marston, #828)
* Validate invocation args for null object verified doubles.
  (Myron Marston, #829)
* Fix `RSpec::Mocks::Constant.original` when called with an invalid
  constant to return an object indicating the constant name is invalid,
  rather than blowing up. (Myron Marston, #833)
* Make `extend RSpec::Mocks::ExampleMethods` on any object work properly
  to add the rspec-mocks API to that object. Previously, `expect` would
  be undefined. (Myron Marston, #846)
* Fix `require 'rspec/mocks/standalone'` so that it only affects `main`
  and not every object. It's really only intended to be used in a REPL
  like IRB, but some gems have loaded it, thinking it needs to be loaded
  when using rspec-mocks outside the context of rspec-core.
  (Myron Marston, #846)
* Prevent message expectations from being modified by customization methods
  (e.g. `with`) after they have been invoked. (Sam Phippen and Melanie Gilman, #837)
* Handle cases where a method stub cannot be removed due to something
  external to RSpec monkeying with the method definition. This can
  happen, for example, when you `file.reopen(io)` after previously
  stubbing a method on the `file` object. (Myron Marston, #853)
* Provide a clear error when received message args are mutated before
  a `have_received(...).with(...)` expectation. (Myron Marston, #868)


### rspec-rails-3.2.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.1.0...v3.2.0)

Enhancements:

* Include generator for `ActionMailer` mailer previews (Takashi Nakagawa, #1185)
* Configure the `ActionMailer` preview path via a Railtie (Aaron Kromer, #1236)
* Show all RSpec generators when running `rails generate` (Eliot Sykes, #1248)
* Support Ruby 2.2 with Rails 3.2 and 4.x (Aaron Kromer, #1264, #1277)
* Improve `instance_double` to support verifying dynamic column methods defined
  by `ActiveRecord` (Jon Rowe, #1238)
* Mirror the use of Ruby 1.9 hash syntax for the `type` tags in the spec
  generators on Rails 4. (Michael Stock, #1292)

Bug Fixes:

* Fix `rspec:feature` generator to use `RSpec` namespace preventing errors when
  monkey-patching is disabled. (Rebecca Skinner, #1231)
* Fix `NoMethodError` caused by calling `RSpec.feature` when Capybara is not
  available or the Capybara version is < 2.4.0. (Aaron Kromer, #1261)
* Fix `ArgumentError` when using an anonymous controller which inherits an
  outer group's anonymous controller. (Yuji Nakayama, #1260)
* Fix "Test is not a class (TypeError)" error when using a custom `Test` class
  in Rails 4.1 and 4.2. (Aaron Kromer, #1295)


### rspec-support-3.2.0
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.1.2...v3.2.0)

Enhancements:

* Add extra Ruby type detection. (Jon Rowe, #133)
* Make differ instance re-usable. (Alexey Fedorov, #160)

Bug Fixes:

* Do not consider `[]` and `{}` to match when performing fuzzy matching.
  (Myron Marston, #157)
