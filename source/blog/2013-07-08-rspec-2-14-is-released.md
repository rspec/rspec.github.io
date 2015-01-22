---
title: RSpec 2.14 is released!
author: Myron Marston
---

We've just released RSpec 2.14. It will be the last 2.x feature release
and is a recommended upgrade for all users. We're getting started on
RSpec 3.  I'll be blogging about our plans for RSpec 3 next week, so
check back soon :).

Thanks to all the contributors who helped make this RSpec release happen.

## Notable New Features

### Core: Profiler now profiles example groups, too

RSpec has long had the `--profile` option for dumping the top N
slowest examples at the end. In RSpec 2.14, this has been enhanced
so that it prints the groups with the largest mean example time.
For example, here's the output from using `--profile 5` on rspec-core's
suite:

~~~
Top 5 slowest examples (0.38945 seconds, 10.8% of total time):
  RSpec::Core::Formatters::TextMateFormatter produces HTML identical to the one we designed manually
    0.10471 seconds ./spec/rspec/core/formatters/text_mate_formatter_spec.rb:64
  ::DRbCommandLine --drb-port without RSPEC_DRB environment variable set sets the DRb port
    0.07461 seconds ./spec/rspec/core/drb_command_line_spec.rb:39
  RSpec::Core::Runner#run with --drb or -X and a DRb server is running builds a DRbCommandLine and runs the specs
    0.0744 seconds ./spec/rspec/core/runner_spec.rb:47
  command line when a custom order is configured orders the groups and examples by the provided strategy
    0.06924 seconds ./spec/command_line/order_spec.rb:169
  RSpec::Core::ConfigurationOptions#configure sends pattern before files_or_directories_to_run
    0.06649 seconds ./spec/rspec/core/configuration_options_spec.rb:48

Top 5 slowest example groups:
  RSpec::Core::Formatters::HtmlFormatter
    0.05861 seconds average (0.05861 seconds / 1 example) ./spec/rspec/core/formatters/html_formatter_spec.rb:9
  RSpec::Core::Formatters::TextMateFormatter
    0.05713 seconds average (0.1714 seconds / 3 examples) ./spec/rspec/core/formatters/text_mate_formatter_spec.rb:9
  command line
    0.05218 seconds average (0.31307 seconds / 6 examples) ./spec/command_line/order_spec.rb:3
  ::DRbCommandLine
    0.02016 seconds average (0.16127 seconds / 8 examples) ./spec/rspec/core/drb_command_line_spec.rb:4
  RSpec::Core::Runner
    0.01822 seconds average (0.10931 seconds / 6 examples) ./spec/rspec/core/runner_spec.rb:5
~~~

### Core: New `--warnings` flag to enable Ruby's warning mode

You can now pass the `--warnings` or `-w` flag to enable ruby's warning
mode.

### Core: Shared example groups are scoped to the context they are defined in

Before 2.14, shared example groups were stored in a global hash, could
be defined in any context, and could be used from any context. In 2.14,
this has changed: shared example groups are now scoped to the context
they are defined in. That means you can now do this:

~~~ ruby
describe MySinatraApp1 do
  shared_examples_for "error handling" do
    # some examples would go here
  end

  context 'GET to /foo' do
    include_examples "error handling"
  end

  context 'GET to /bar' do
    include_examples "error handling"
  end
end
~~~

~~~ ruby
describe MySinatraApp2 do
  shared_examples_for "error handling" do
    # some different examples would go here
  end

  context 'GET to /foo' do
    include_examples "error handling"
  end

  context 'GET to /bar' do
    include_examples "error handling"
  end
end
~~~

Here there are two different `"error handling"` shared example
groups, each scoped to (and used from) a different example group.
As demonstrated here, shared example groups are available from
the context they are defined in or from any nested context.
In 2.14, shared example groups declared in sibling contexts
are still available to maintain backwards compatibility,
but will print a deprecation warning. In 3.0, you will not
be able to use a shared example group that was defined in
a sibling context.

### Core: Deprecation output now configurable

RSpec 2.14 has deprecated a number of things in preparation for
removal in 3.0. To help reduce the noisiness of the increased
number of deprecations, there's a new option that can direct
deprecation warnings to a file:

~~~ ruby
# spec_helper.rb
RSpec.configure do |rspec|
  rspec.deprecation_stream = 'log/deprecations.log'
  # or
  rspec.deprecation_stream = File.open("/path/to/file", "w")
end
~~~

Normally, deprecation warnings get printed to `stderr`. When
you configure this, it'll send deprecation warnings to the
configured file instead, and at the end of the spec run
it will print out a message like:

~~~
2 deprecations logged to log/deprecations.log
~~~

### Mocks: New message expectation syntax

In RSpec 2.11, we added a [new syntax to
rspec-expectations](http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax)
that removes a reliance on monkey-patching, avoiding certain
kinds of problems related to proxy objects. In RSpec 2.14,
we've extended that same syntax to rspec-mocks:

~~~ ruby
mailer = double("Mailer")

# old syntax:
mailer.stub(:deliver_welcome_email)
mailer.should_receive(:deliver_welcome_email).with(an_instance_of(User))

# new syntax
allow(mailer).to receive(:deliver_welcome_email)
expect(mailer).to receive(:deliver_welcome_email).with(an_instance_of(User))
~~~

For more details, read Sam Phippen's [announcement blog
post](http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/)
from the 2.14.0.rc1 release.

### Mocks: Spies

Joe Ferris from Thoughtbot implemented this new feature. Traditionally,
rspec-mocks has required that you set a message expectation before
the message is received:

~~~ ruby
mailer = double("Mailer")
expect(mailer).to receive(:deliver_welcome_email).with(an_instance_of(User))
UserCreationService.new(mailer).create_user(params)
~~~

In some situations, this ordering feels backwards (particularly if you
try to organize your tests using an arrange/act/assert pattern). Spies
allow you to assert that a message was received after the fact:

~~~ ruby
mailer = double("Mailer", deliver_welcome_email: nil)
UserCreationService.new(mailer).create_user(params)
expect(mailer).to have_received(:deliver_welcome_email).with(an_instance_of(User))
~~~

Note that you first have to stub the message you will later expect
so that rspec-mocks can spy on it. (There's no feasible performant
way for rspec-mocks to automatically spy on all method calls).
Alternately, you can create your test double as a null object,
(using `double().as_null_object`) which has the effect of
auto-spying on all messages sent to that object:

~~~ ruby
mailer = double("Mailer").as_null_object
UserCreationService.new(mailer).create_user(params)
expect(mailer).to have_received(:deliver_welcome_email).with(an_instance_of(User))
~~~

## Docs

### RDoc

* [http://rubydoc.info/gems/rspec-core](http://rubydoc.info/gems/rspec-core)
* [http://rubydoc.info/gems/rspec-expectations](http://rubydoc.info/gems/rspec-expectations)
* [http://rubydoc.info/gems/rspec-mocks](http://rubydoc.info/gems/rspec-mocks)
* [http://rubydoc.info/gems/rspec-rails](http://rubydoc.info/gems/rspec-rails)

### Cucumber Features

* [http://relishapp.com/rspec/rspec-core](http://relishapp.com/rspec/rspec-core)
* [http://relishapp.com/rspec/rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [http://relishapp.com/rspec/rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [http://relishapp.com/rspec/rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core 2.14.0

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.13.0...v2.14.0)

Enhancements:

* Improved Windows detection inside Git Bash, for better `--color` handling.
* Add profiling of the slowest example groups to `--profile` option.
  The output is sorted by the slowest average example groups.
* Don't show slow examples if there's a failure and both `--fail-fast`
  and `--profile` options are used (Paweł Gościcki).
* Rather than always adding `spec` to the load path, add the configured
  `--default-path` to the load path (which defaults to `spec`). This
  better supports folks who choose to put their specs in a different
  directory (John Feminella).
* Add some logic to test time duration precision. Make it a
  function of time, dropping precision as the time increases. (Aaron Kromer)
* Add new `backtrace_inclusion_patterns` config option. Backtrace lines
  that match one of these patterns will _always_ be included in the
  backtrace, even if they match an exclusion pattern, too (Sam Phippen).
* Support ERB trim mode using the `-` when parsing `.rspec` as ERB
  (Gabor Garami).
* Give a better error message when let and subject are called without a block.
  (Sam Phippen).
* List the precedence of `.rspec-local` in the configuration documentation
  (Sam Phippen)
* Support `{a,b}` shell expansion syntax in `--pattern` option
  (Konstantin Haase).
* Add cucumber documentation for --require command line option
  (Bradley Schaefer)
* Expose configruation options via config:
  * `config.libs` returns the libs configured to be added onto the load path
  * `full_backtrace?` returns the state of the backtrace cleaner
  * `debug?` returns true when the debugger is loaded
  * `line_numbers` returns the line numbers we are filtering by (if any)
  * `full_description` returns the RegExp used to filter descriptions
  (Jon Rowe)
* Add setters for RSpec.world and RSpec.configuration (Alex Soulim)
* Configure ruby's warning behaviour with `--warnings` (Jon Rowe)
* Fix an obscure issue on old versions of `1.8.7` where `Time.dup` wouldn't
  allow access to `Time.now` (Jon Rowe)
* Make `shared_examples_for` context aware, so that keys may be safely reused
  in multiple contexts without colliding. (Jon Rowe)
* Add a configurable `deprecation_stream` (Jon Rowe)
* Publish deprecations through a formatter (David Chelimsky)
* Apply focus to examples defined with `fit` (equivalent of
  `it "description", focus: true`) (Michael de Silva)

Bug fixes:

* Make JSON formatter behave the same when it comes to `--profile` as
  the text formatter (Paweł Gościcki).
* Fix named subjects so that if an inner group defines a method that
  overrides the named method, `subject` still retains the originally
  declared value (Myron Marston).
* Fix random ordering so that it does not cause `rand` in examples in
  nested sibling contexts to return the same value (Max Shytikov).
* Use the new `backtrace_inclusion_patterns` config option to ensure
  that folks who develop code in a directory matching one of the default
  exclusion patterns (e.g. `gems`) still get the normal backtrace
  filtering (Sam Phippen).
* Fix ordering of `before` hooks so that `before` hooks declared in
  `RSpec.configure` run before `before` hooks declared in a shared
  context (Michi Huber and Tejas Dinkar).
* Fix `Example#full_description` so that it gets filled in by the last
  matcher description (as `Example#description` already did) when no
  doc string has been provided (David Chelimsky).
* Fix the memoized methods (`let` and `subject`) leaking `define_method`
  as a `public` method. (Thomas Holmes and Jon Rowe) (#873)
* Fix warnings coming from the test suite. (Pete Higgins)
* Ensure methods defined by `let` take precedence over others
  when there is a name collision (e.g. from an included module).
  (Jon Rowe, Andy Lindeman and Myron Marston)

Deprecations

* Deprecate `Configuration#backtrace_clean_patterns` in favor of
  `Configuration#backtrace_exclusion_patterns` for greater consistency
  and symmetry with new `backtrace_inclusion_patterns` config option
  (Sam Phippen).
* Deprecate `Configuration#requires=` in favor of using ruby's
  `require`. Requires specified by the command line can still be
  accessed by the `Configuration#require` reader. (Bradley Schaefer)
* Deprecate calling `SharedExampleGroups` defined across sibling contexts
  (Jon Rowe)

### rspec-expectations 2.14.0

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.13.0...v2.14.0)

Enhancements:

* Enhance `yield_control` so that you can specify an exact or relative
  number of times: `expect { }.to yield_control.exactly(3).times`,
  `expect { }.to yield_control.at_least(2).times`, etc (Bartek
  Borkowski).
* Make the differ that is used when an expectation fails better handle arrays
  by splitting each element of the array onto its own line. (Sam Phippen)
* Accept duck-typed strings that respond to `:to_str` as expectation messages.
  (Toby Ovod-Everett)

Bug fixes:

* Fix differ to not raise errors when dealing with differently-encoded
  strings (Jon Rowe).
* Fix `expect(something).to be_within(x).percent_of(y)` where x and y are both
  integers (Sam Phippen).
* Fix `have` matcher to handle the fact that on ruby 2.0,
  `Enumerator#size` may return nil (Kenta Murata).
* Fix `expect { raise s }.to raise_error(s)` where s is an error instance
  on ruby 2.0 (Sam Phippen).
* Fix `expect(object).to raise_error` passing. This now warns the user and
  fails the spec (tomykaira).
* Values that are not matchers use `#inspect`, rather than `#description` for
  documentation output (Andy Lindeman, Sam Phippen).
* Make `expect(a).to be_within(x).percent_of(y)` work with negative y
  (Katsuhiko Nishimra).
* Make the `be_predicate` matcher work as expected used with `expect{...}.to
  change...`  (Sam Phippen).

Deprecations

* Deprecate `expect { }.not_to raise_error(SpecificErrorClass)` or
  `expect { }.not_to raise_error("some specific message")`. Using
  these was prone to hiding failures as they would allow _any other
  error_ to pass. (Sam Phippen and David Chelimsky)

### rspec-mocks 2.14.0

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.13.0...v2.14.0)

Enhancements:

* Refactor internals so that the mock proxy methods and state are held
  outside of the mocked object rather than inside it. This paves the way
  for future syntax enhancements and removes the need for some hacky
  work arounds for `any_instance` dup'ing and `YAML` serialization,
  among other things. Note that the code now relies upon `__id__`
  returning a unique, consistent value for any object you want to
  mock or stub (Myron Marston).
* Add support for test spies. This allows you to verify a message
  was received afterwards using the `have_received` matcher.
  Note that you must first stub the method or use a null double.
  (Joe Ferris and Joël Quenneville)
* Make `at_least` and `at_most` style receive expectations print that they were
  expecting at least or at most some number of calls, rather than just the
  number of calls given in the expectation (Sam Phippen)
* Make `with` style receive expectations print the args they were expecting, and
  the args that they got (Sam Phippen)
* Fix some warnings seen under ruby 2.0.0p0 (Sam Phippen).
* Add a new `:expect` syntax for message expectations
  (Myron Marston and Sam Phippen).
* Document test spies in the readme. (Adarsh Pandit)
* Add an `array_including` matcher. (Sam Phippen)
* Add a syntax-agnostic API for mocking or stubbing a method. This is
  intended for use by libraries such as rspec-rails that need to mock
  or stub a method, and work regardless of the syntax the user has
  configured (Paul Annesley, Myron Marston and Sam Phippen).

Bug Fixes:

* Fix `any_instance` so that a frozen object can be `dup`'d when methods
  have been stubbed on that type using `any_instance` (Jon Rowe).
* Fix `and_call_original` so that it properly raises an `ArgumentError`
  when the wrong number of args are passed (Jon Rowe).
* Fix `double` on 1.9.2 so you can wrap them in an Array
  using `Array(my_double)` (Jon Rowe).
* Fix `stub_const` and `hide_const` to handle constants that redefine `send`
  (Sam Phippen).
* Fix `Marshal.dump` extension so that it correctly handles nil.
  (Luke Imhoff, Jon Rowe)
* Fix isolation of `allow_message_expectations_on_nil` (Jon Rowe)
* Use inspect to format actual arguments on expectations in failure messages (#280, Ben Langfeld)
* Protect against improperly initialised test doubles (#293) (Joseph Shraibman and Jon Rowe)
* Fix `double` so that it sets up passed stubs correctly regardless of
  the configured syntax (Paul Annesley).
* Allow a block implementation to be used in combination with
  `and_yield`, `and_raise`, `and_return` or `and_throw`. This got fixed
  in 2.13.1 but failed to get merged into master for the 2.14.0.rc1
  release (Myron Marston).
* `Marshal.dump` does not unnecessarily duplicate objects when rspec-mocks has
  not been fully initialized. This could cause errors when using `spork` or
  similar preloading gems (Andy Lindeman).

Deprecations:

* Deprecate `stub` and `mock` as aliases for `double`. `double` is the
  best term for creating a test double, and it reduces confusion to
  have only one term (Michi Huber).
* Deprecate `stub!` and `unstub!` in favor of `stub` and `unstub`
  (Jon Rowe).
* Deprecate `at_least(0).times` and `any_number_of_times` (Michi Huber).

### rspec-rails 2.14.0

Enhancements:

* Preliminarily support Rails 4.1 by updating adapters to support Minitest 5.0.
  (Andy Lindeman)

Bug fixes:

* Rake tasks do not define methods that might interact with other libraries.
  (Fujimura Daisuke)
* Reverts fix for out-of-order `let` definitions in controller specs after the
  issue was fixed upstream in rspec-core. (Andy Lindeman)
* Fixes deprecation warning when using `expect(Model).to have(n).records` with
  Rails 4. (Andy Lindeman)
* `rake stats` runs correctly when spec files exist at the top level of the
  spec/ directory. (Benjamin Fleischer)

