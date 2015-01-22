---
title: RSpec 2.99 and 3.0 betas have been released!
author: Myron Marston
---

The RSpec team has just released RSpec 3.0.0.beta1 -- the first RSpec 3 pre-release!
Along with that, we've released 2.99.0.beta1, which is intended to help with
the upgrade process.

I'd like to thank all the contributors, and especially the core team
([Andy](https://twitter.com/alindeman), [Bradley](https://twitter.com/soulcutter),
[Jon](https://twitter.com/JonRowe), [Sam](https://twitter.com/samphippen) and
[Xavier](https://twitter.com/xshay)) for making this release happen.

I don't have the energy right now to write up a full "What's new in RSpec 3"
blog post, but we've mostly been making changes according to what
we [previously announced for RSpec 3](/n/dev-blog/2013/07/the-plan-for-rspec-3).
The detailed release notes are below to fill you in on the details for
these releases. We'll be following up with other blog posts in the
future discussing the new features in depth.

## The Upgrade Process

RSpec 3 includes many breaking changes, but our hope is to make this
the smoothest major-version gem upgrade you've ever done. To assist
with that process, we've been developing RSpec 2.99 in tandem with
RSpec 3.  Every time we make a breaking change in the master branch
for 3.0, we've been adding a corresponding deprecation to 2.99.  This
isn't just for APIs that have been removed; it's also for slight changes
in edge-case semantics (in order to make RSpec more consistent) that
some projects may rely on. Rather than just giving you a generic
upgrade document that describes _all_ of the breaking changes
(including many that affect very few users!), RSpec 2.99 gives you
a detailed upgrade checklist.

In addition, [Yuji Nakayama](https://twitter.com/nkym37) has been developing
[transpec](https://github.com/yujinakayama/transpec) -- an absolutely amazing
tool that can automatically upgrade most RSpec suites. I've tried it on a
couple projects and I've been _amazed_ at how well it works.

Here's the general approach I recommend for upgrading a project to RSpec 3:

1. Ensure your test suite is already green on whatever RSpec 2.x version
   you're already using.
2. Install RSpec 2.99.0.beta1 (or whatever the latest 2.99 release is
   when you go through this process).
3. Run your test suite and ensure it's still green. (It should be, but
   we may have made a mistake -- if it breaks anything, please report
   a bug!). Now would be a good time to commit.
4. You'll notice a bunch of deprecation warnings printed off at the
   end of the spec run. These may be truncated since we don't to
   spam you with the same deprecation warning over and over again. To
   get the full list of deprecations, you can pipe them into a file
   by setting the `config.deprecation_stream = 'rspec.log'` option.
5. If you want to understand all of what is being deprecated, it's a
   good idea to read through the deprecation messages.  In some cases,
   you have choices -- such as continuing to use the `have` collection
   cardinality matchers via the extracted
   [rspec-collection_matchers](https://github.com/rspec/rspec-collection_matchers)
   gem, or by rewriting the expectation expression to something like
   `expect(list.size).to eq(3)`.
6. `gem install transpec` (Note that this need not go into your
   `Gemfile`: you run `transpec` as a standalone executable
    outside the context of your bundle).
7. Run transpec on your project. Check `transpec --help` or
   [the README](https://github.com/yujinakayama/transpec#transpec)
   for a full list of options.
8. Run the test suite (it should still be green but it's always good to check!)
   and commit.
9. If there are any remaining deprecation warnings (transpec doesn't quite handle
   all of the warnings you may get), deal with them.
9. Once you've got a deprecation-free test suite running against RSpec 2.99,
   you're ready to upgrade to RSpec 3. Install RSpec 3.0.0.beta1
   (or whatever the latest 3.x release is when you go through this process).
10. Run your test suite. It should still be green. If anything fails, please
    open a Github issue -- we consider it a bug[^foot_1]!
11. Commit and enjoy using the latest RSpec release!

## What's Next

While we've made significant progress on RSpec 3, we're not done yet.
We have more to do. (We haven't gotten to everything we've planned.)
We take [SemVer](http://semver.org/) seriously, and this is the first
opportunity we've had in years to clean out old cruft, so we want to
take full advantage of it :). We hope to release an RC in the next
few months, with a final release shortly after that.

## Release Notes

### rspec-core 2.99.0.beta1

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.14.7...v2.99.0.beta1)

Enhancements:

* Block-based DSL methods that run in the context of an example
  (`it`, `before(:each)`, `after(:each)`, `let` and `subject`)
  now yield the example as a block argument. (David Chelimsky)
* Warn when the name of more than one example group is submitted to
  `include_examples` and it's aliases. (David Chelimsky)
* Add `expose_current_running_example_as` config option for
  use during the upgrade process when external gems use the
  deprecated `RSpec::Core::ExampleGroup#example` and
  `RSpec::Core::ExampleGroup#running_example` methods. (Myron Marston)
* Limit spamminess of deprecation messages. (Bradley Schaefer, Loren Segal)
* Add `config.raise_errors_for_deprecations!` option, which turns
  deprecations warnings into errors to surface the full backtrace
  of the call site. (Myron Marston)

Deprecations:

* Deprecate `RSpec::Core::ExampleGroup#example` and
  `RSpec::Core::ExampleGroup#running_example` methods. If you need
  access to the example (e.g. to get its metadata), use a block argument
  instead. (David Chelimsky)
* Deprecate use of `autotest/rspec2` in favour of `rspec-autotest`. (Jon Rowe)
* Deprecate RSpec's built-in debugger support. Use a CLI option like
  `-rruby-debug` (for the ruby-debug gem) or `-rdebugger` (for the
  debugger gem) instead. (Myron Marston)
* Deprecate `config.treat_symbols_as_metadata_keys_with_true_values = false`.
  RSpec 3 will not support having this option set to `false`. (Myron Marston)
* Deprecate accessing a `let` or `subject` declaration in
  a `after(:all)` hook. (Myron Marston, Jon Rowe)
* Deprecate built-in `its` usage in favor of `rspec-its` gem due to planned
  removal in RSpec 3. (Peter Alfvin)
* Deprecate `RSpec::Core::PendingExampleFixedError` in favor of
  `RSpec::Core::Pending::PendingExampleFixedError`. (Myron Marston)
* Deprecate `RSpec::Core::Configuration#out` and
  `RSpec::Core::Configuration#output` in favor of
  `RSpec::Core::Configuration#output_stream`. (Myron Marston)
* Each of the following are deprecated in favor of
  `register_ordering(:global)` (Myron Marston):
  * `RSpec::Core::Configuration#order_examples`
  * `RSpec::Core::Configuration#order_groups`
  * `RSpec::Core::Configuration#order_groups_and_examples`
* These are deprecated with no replacement because in RSpec 3
  ordering is a property of individual example groups rather than
  just a global property of the entire test suite (Myron Marston):
  * `RSpec::Core::Configuration#order`
  * `RSpec::Core::Configuration#randomize?`
  * `--order default` is deprecated in favor of `--order defined`

### rspec-core 3.0.0.beta1

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.99.0.beta1...v3.0.0.beta1)

Breaking Changes:

* Remove explicit support for 1.8.6. (Jon Rowe)
* Remove `RSpec::Core::ExampleGroup#example` and
  `RSpec::Core::ExampleGroup#running_example` methods. If you need
  access to the example (e.g. to get its metadata), use a block arg
  instead. (David Chelimsky)
* Remove `TextMateFormatter`, it has been moved to `rspec-tmbundle`.
  (Aaron Kromer)
* Remove RCov integration. (Jon Rowe)
* Remove deprecated support for RSpec 1 constructs (Myron Marston):
  * The `Spec` and `Rspec` constants (rather than `RSpec`).
  * `Spec::Runner.configure` rather than `RSpec.configure`.
  * `Rake::SpecTask` rather than `RSpec::Core::RakeTask`.
* Remove deprecated support for `share_as`. (Myron Marston)
* Remove `--debug` option (and corresponding option on
  `RSpec::Core::Configuration`). Instead, use `-r<debugger gem name>` to
  load whichever debugger gem you wish to use (e.g. `ruby-debug`,
  `debugger`, or `pry`). (Myron Marston)
* Extract Autotest support to a seperate gem. (Jon Rowe)
* Raise an error when a `let` or `subject` declaration is
  accessed in a `before(:all)` or `after(:all)` hook. (Myron Marston)
* Extract `its` support to a separate gem. (Peter Alfvin)
* Disallow use of a shared example group from sibling contexts, making them
  fully isolated. 2.14 and 2.99 allowed this but printed a deprecation warning.
  (Jon Rowe)
* Remove `RSpec::Core::Configuration#output` and
  `RSpec::Core::Configuration#out` aliases of
  `RSpec::Core::Configuration#output_stream`. (Myron Marston)

Enhancements:

* Replace unmaintained syntax gem with coderay gem. (Xavier Shay)
* Times in profile output are now bold instead of `failure_color`.
  (Matthew Boedicker)
* Add `--no-fail-fast` command line option. (Gonzalo Rodríguez-Baltanás Díaz)
* Runner now considers the local system ip address when running under Drb.
  (Adrian CB)
* JsonFormatter now includes `--profile` information. (Alex / @MasterLambaster)
* Always treat symbols passed as metadata args as hash
  keys with true values. RSpec 2 supported this with the
  `treat_symbols_as_metadata_keys_with_true_values` but
  now this behavior is always enabled. (Myron Marston)
* Add `--dry-run` option, which prints the formatter output
  of your suite without running any examples or hooks.
  (Thomas Stratmann, Myron Marston)
* Document the configuration options and default values in the `spec_helper.rb`
  file that is generated by RSpec. (Parker Selbert)
* Give generated example group classes a friendly name derived
  from the docstring, rather than something like "Nested_2".
  (Myron Marston)
* Avoid affecting randomization of user code when shuffling
  examples so that users can count on their own seeds
  working. (Travis Herrick)

Deprecations:

* `treat_symbols_as_metadata_keys_with_true_values` is deprecated and no
  longer has an affect now that the behavior it enabled is always
  enabled. (Myron Marston)

### rspec-mocks 2.99.0.beta1

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.14.4...v2.99.0.beta1)

Deprecations:

* Expecting to use lambdas or other strong arity implementations for stub
  methods with mis-matched arity is deprecated and support for them will be
  removed in 3.0. Either provide the right amount of arguments or use a weak
  arity implementation (methods with splats or procs). (Jon Rowe)
* Using the same test double instance in multiple examples is deprecated. Test
  doubles are only meant to live for one example. The mocks and stubs have
  always been reset between examples; however, in 2.x the `as_null_object`
  state was not reset and some users relied on this to have a null object
  double that is used for many examples. This behavior will be removed in 3.0.
  (Myron Marston)
* Print a detailed warning when an `any_instance` implementation block is used
  when the new `yield_receiver_to_any_instance_implementation_blocks` config
  option is not explicitly set, as RSpec 3.0 will default to enabling this new
  feature. (Sam Phippen)

Enhancements:

* Add a config option to yield the receiver to `any_instance` implementation
  blocks. (Sam Phippen)

### rspec-mocks 3.0.0.beta1
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.99.0.beta1...v3.0.0.beta1)

Breaking Changes:

* Raise an explicit error if `should_not_receive(...).and_return` is used. (Sam
  Phippen)
* Remove 1.8.6 workarounds. (Jon Rowe)
* Remove `stub!` and `unstub!`. (Sam Phippen)
* Remove `mock(name, methods)` and `stub(name, methods)`, leaving
  `double(name, methods)` for creating test doubles. (Sam Phippen, Michi Huber)
* Remove `any_number_of_times` since `should_receive(:msg).any_number_of_times`
  is really a stub in a mock's clothing. (Sam Phippen)
* Remove support for re-using the same null-object test double in multiple
  examples.  Test doubles are designed to only live for one example.
  (Myron Marston)
* Make `at_least(0)` raise an error. (Sam Phippen)
* Remove support for `require 'spec/mocks'` which had been kept
  in place for backwards compatibility with RSpec 1. (Myron Marston)
* Blocks provided to `with` are always used as implementation. (Xavier Shay)
* The config option (added in 2.99) to yield the receiver to
  `any_instance` implementation blocks now defaults to "on". (Sam Phippen)

Enhancements:

* Allow the `have_received` matcher to use a block to set further expectations
  on arguments. (Tim Cowlishaw)
* Provide `instance_double` and `class_double` to create verifying doubles,
  ported from `rspec-fire`. (Xavier Shay)
* `as_null_object` on a verifying double only responds to defined methods.
  (Xavier Shay)
* Provide `object_double` to create verified doubles of specific object
  instances. (Xavier Shay)
* Provide `verify_partial_doubles` configuration that provides `object_double`
  like verification behaviour on partial mocks. (Xavier Shay)
* Improved performance of double creation, particularly those with many
  attributes. (Xavier Shay)
* Default value of `transfer_nested_constants` option for constant stubbing can
  be configured. (Xavier Shay)
* Messages can be allowed or expected on in bulk via
  `receive_messages(:message => :value)`. (Jon Rowe)
* `allow(Klass.any_instance)` and `expect(Klass.any_instance)` now print a
  warning. This is usually a mistake, and users usually want
  `allow_any_instance_of` or `expect_any_instance_of` instead. (Sam Phippen)
* `instance_double` and `class_double` raise `ArgumentError` if the underlying
  module is loaded and the arity of the method being invoked does not match the
  arity of the method as it is actually implemented. (Andy Lindeman)
* Spies can now check their invocation ordering is correct. (Jon Rowe)

Deprecations:

* Using the old `:should` syntax without explicitly configuring it
  is deprecated. It will continue to work but will emit a deprecation
  warning in RSpec 3 if you do not explicitly enable it. (Sam Phippen)

Bug Fixes:

* Fix `and_call_original` to handle a complex edge case involving
  singleton class ancestors. (Marc-André Lafortune, Myron Marston)
* When generating an error message for unexpected arguments,
  use `#inspect` rather than `#description` if `#description`
  returns `nil` or `''` so that you still get a useful message.
  (Nick DeLuca)

### rspec-expectations 2.99.0.beta1

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.14.4...v2.99.0.beta1)

Deprecations:

* Deprecate `have`, `have_at_least` and `have_at_most`. You can continue using those
  matchers through https://github.com/rspec/rspec-collection_matchers, or
  you can rewrite your expectations with something like
  `expect(your_object.size).to eq(num)`. (Hugo Baraúna)
* Deprecate `be_xyz` predicate matcher when `xyz?` is a private method.
  (Jon Rowe)
* Deprecate `be_true`/`be_false` in favour of `be_truthy`/`be_falsey`
  (for Ruby's conditional semantics) or `be true`/`be false`
  (for exact equality). (Sam Phippen)
* Deprecate calling helper methods from a custom matcher with the wrong
  scope. (Myron Marston)
  * `def self.foo` / `extend Helper` can be used to add macro methods
    (e.g. methods that call the custom matcher DSL methods), but should
    not be used to define helper methods called from within the DSL
    blocks.
  * `def foo` / `include Helper` is the opposite: it's for helper methods
    callable from within a DSL block, but not for defining macros.
  * RSpec 2.x allowed helper methods defined either way to be used for
    either purpose, but RSpec 3.0 will not.

### rspec-expectations 3.0.0.beta1

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.beta1...v3.0.0.beta1)

Breaking Changes:

* Remove explicit support for 1.8.6. (Jon Rowe)
* Remove the deprecated `be_close` matcher, preferring `be_within` instead.
  (Sam Phippen)
* Rename `be_true` and `be_false` to `be_truthy` and `be_falsey`. (Sam Phippen)
* Make `expect { }.to_not raise_error(SomeSpecificClass, message)`,
       `expect { }.to_not raise_error(SomeSpecificClass)` and
       `expect { }.to_not raise_error(message)` invalid, since they are prone
  to hiding failures. Instead, use `expect { }.to_not raise_error` (with no
  args). (Sam Phippen)
* Within `RSpec::Matchers.define` blocks, helper methods made available
  either via `def self.helper` or `extend HelperModule` are no longer
  available to the `match` block (or any of the others). Instead
  `include` your helper module and define the helper method as an
  instance method. (Myron Marston)

Enhancements:

* Support `do..end` style block with `raise_error` matcher. (Yuji Nakayama)
* Rewrote custom matcher DSL to simplify its implementation and solve a
  few issues. (Myron Marston)
* Allow early `return` from within custom matcher DSL blocks. (Myron
  Marston)
* The custom matcher DSL's `chain` can now accept a block. (Myron
  Marston)
* Support setting an expectation on a `raise_error` matcher via a chained
  `with_message` method call. (Sam Phippen)

Bug Fixes:

* Allow `include` and `match` matchers to be used from within a
  DSL-defined custom matcher's `match` block. (Myron Marston)

Deprecations:

 * Using the old `:should` syntax without explicitly configuring it is deprecated.
   It will continue to work but will emit a deprecation warning in RSpec 3 if
   you do not explicitly enable it. (Sam Phippen)

### rspec-rails 2.99.0.beta1

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.14.0...v2.99.0.beta1)

Deprecations:

* Deprecates autotest integration in favor of the `rspec-autotest` gem. (Andy
  Lindeman)

Enhancements:

* Supports Rails 4.1 and Minitest 5. (Patrick Van Stee)

Bug Fixes:

* Fixes "warning: instance variable @orig\_routes not initialized" raised by
  controller specs when `--warnings` are enabled. (Andy Lindeman)
* Where possible, check against the version of ActiveRecord, rather than
  Rails. It is possible to use some of rspec-rails without all of Rails.
  (Darryl Pogue)
* Explicitly depends on `activemodel`. This allows libraries that do not bring
  in all of `rails` to use `rspec-rails`. (John Firebaugh)

### rspec-rails 3.0.0.beta1

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.99.0.beta1...v3.0.0.beta1)

Breaking Changes:

* Extracts `autotest` and `autotest-rails` support to `rspec-autotest` gem.
  (Andy Lindeman)

[^foot_1]: There is one caveat to that, though: we only consider it a bug to the extent that your test suite uses the RSpec APIs as they are documented. The dynamic nature of Ruby makes it possible to use RSpec in ways that we can't support.

