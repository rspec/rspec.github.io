---
title: RSpec 2.99 and 3.0 beta2 have been released!
author: Myron Marston
---

The RSpec team has released 3.0.0.beta2 and 2.99.0.beta2.

This is a huge release that includes tons of new features.
I plan to do a full blog post listing and giving examples for
all the notable new 3.0 features at a later date. For now, I've
just got the full release notes.

Thanks to all the contributors who helped make this release happen!

I also want to thank those of you who have put your projects though
the upgrade process and have been using 3.0.0.beta1--your feedback
has been invaluable.

For more details on the upgrade process, see the [beta1
annoucement](/blog/2013/11/rspec-2-99-and-3-0-betas-have-been-released#the_upgrade_process)
blog post.

This will be the last 2.99/3.0 beta release. Next up are the release
candidates!

## Release Notes

### rspec-core 2.99.0.beta2

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.99.0.beta1...v2.99.0.beta2)

Enhancements:

* Add `is_expected` for one-liners that read well with the
  `expect`-based syntax. `is_expected` is simply defined as
  `expect(subject)` and can be used in an expression like:
  `it { is_expected.to read_well }`. (Myron Marston)
* Backport `skip` from RSpec 3, which acts like `pending` did in RSpec 2
  when not given a block, since the behavior of `pending` is changing in
  RSpec 3. (Xavier Shay)

Deprecations:

* Deprecate inexact `mock_with` config options. RSpec 3 will only support
  the exact symbols `:rspec`, `:mocha`, `:flexmock`, `:rr` or `:nothing`
  (or any module that implements the adapter interface). RSpec 2 did
  fuzzy matching but this will not be supported going forward.
  (Myron Marston)
* Deprecate `show_failures_in_pending_blocks` config option. To achieve
  the same behavior as the option enabled, you can use a custom
  formatter instead. (Xavier Shay)
* Add a deprecation warning for the fact that the behavior of `pending`
  is changing in RSpec 3 -- rather than skipping the example (as it did
  in 2.x when no block was provided), it will run the example and mark
  it as failed if no exception is raised. Use `skip` instead to preserve
  the old behavior. (Xavier Shay)
* Deprecate 's', 'n', 'spec' and 'nested' as aliases for documentation
  formatter. (Jon Rowe)
* Deprecate `RSpec::Core::Reporter#abort` in favor of
  `RSpec::Core::Reporter#finish`. (Jon Rowe)

Bug Fixes:

* Fix failure (undefined method `path`) in end-of-run summary
  when `raise_errors_for_deprecations!` is configured. (Myron Marston)
* Fix issue were overridding spec ordering from the command line wasn't
  fully recognised interally. (Jon Rowe)

### rspec-core 3.0.0.beta2

[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Make `mock_with` option more strict. Strings are no longer supported
  (e.g. `mock_with "mocha"`) -- use a symbol instead. Also, unrecognized
  values will now result in an error rather than falling back to the
  null mocking adapter. If you want to use the null mocking adapter,
  use `mock_with :nothing` (as has been documented for a long time).
  (Myron Marston)
* Remove support for overriding RSpec's built-in `:if` and `:unless`
  filters. (Ashish Dixit)
* Custom formatters are now required to call
  `RSpec::Core::Formatters.register(formatter_class, *notifications)`
  where `notifications` is the list of events the formatter wishes to
  be notified about. Notifications are handled by methods matching the
  names on formatters. This allows us to add or remove notifications
  without breaking existing formatters. (Jon Rowe)
* Change arguments passed to formatters. Rather than passing multiple
  arguments (which limits are ability to add additional arguments as
  doing so would break existing formatters), we now pass a notification
  value object that exposes the same data via attributes. This will
  allow us to add new bits of data to a notification event without
  breaking existing formattesr. (Jon Rowe)
* Remove support for deprecated `:alias` option for
  `RSpec.configuration.add_setting`. (Myron Marston)
* Remove support for deprecated `RSpec.configuration.requires = [...]`.
  (Myron Marston)
* Remove support for deprecated `--formatter` CLI option. (Myron Marston)
* Remove support for deprecated `--configure` CLI option. (Myron Marston)
* Remove support for deprecated `RSpec::Core::RakeTask#spec_opts=`.
  (Myron Marston)
* An example group level `pending` block or `:pending` metadata now executes
  the example and cause a failure if it passes, otherwise it will be pending if
  it fails. The old "never run" behaviour is still used for `xexample`, `xit`,
  and `xspecify`, or via a new `skip` method or `:skip` metadata option.
  (Xavier Shay)
* After calling `pending` inside an example, the remainder of the example will
  now be run. If it passes a failure is raised, otherwise the example is marked
  pending. The old "never run" behaviour is provided a by a new `skip` method.
  (Xavier Shay)
* Pending blocks inside an example have been removed as a feature with no
  direct replacement. Use `skip` or `pending` without a block. (Xavier Shay)
* Pending statement is no longer allowed in `before(:all)` hooks. Use `skip`
  instead.  (Xavier Shay)
* Remove `show_failures_in_pending_blocks` configuration option. (Xavier Shay)
* Remove support for specifying the documentation formatter using
  's', 'n', 'spec' or 'nested'. (Jon Rowe)

Enhancements:

* Add example run time to JSON formatter output. (Karthik Kastury)
* Add more suggested settings to the files generated by
  `rspec --init`. (Myron Marston)
* Add `config.alias_example_group_to`, which can be used to define a
  new method that defines an example group with the provided metadata.
  (Michi Huber)
* Add `xdescribe` and `xcontext` as shortcuts to make an example group
  pending. (Myron Marston)
* Add `fdescribe` and `fcontext` as shortcuts to focus an example group.
  (Myron Marston)
* Don't autorun specs via `#at_exit` by default. `require 'rspec/autorun'`
  is only needed when running specs via `ruby`, as it always has been.
  Running specs via `rake` or `rspec` are both unaffected. (Ben Hoskings)
* Add `expose_dsl_globally` config option, defaulting to true. When disabled
  it will remove the monkey patches rspec-core adds to `main` and `Module`
  (e.g. `describe`, `shared_examples_for`, etc).  (Jon Rowe)
* Expose RSpec DSL entry point methods (`describe`,
  `shared_examples_for`, etc) on the `RSpec` constant. Intended for use
  when `expose_dsl_globally` is set to `false`. (Jon Rowe)
* For consistency, expose all example group aliases (including
  `context`) on the `RSpec` constant. If `expose_dsl_globally` is set to
  `true`, also expose them on `main` and `Module`. Historically, only `describe`
  was exposed. (Jon Rowe, Michi Huber)

Bug Fixes:

* Fix failure (undefined method `path`) in end-of-run summary
  when `raise_errors_for_deprecations!` is configured. (Myron Marston)
* Issue error when attempting to use -i or --I on command line,
  too close to -I to be considered short hand for --init. (Jon Rowe)
* Prevent adding formatters to an output target if the same
  formatter has already been added to that output. (Alex Peattie)
* Allow a matcher-generated example description to be used when
  the example is pending. (Myron Marston)
* Ensure the configured `failure_exit_code` is used by the rake
  task when there is a failure. (Jon Rowe)
* Restore behaviour whereby system exclusion filters take priority over working
  directory (was broken in beta1). (Jon Rowe)
* Prevent RSpec mangling file names that have substrings containing `line_number`
  or `default_path`. (Matijs van Zuijlen)

### rspec-expectations 2.99.0.beta2

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.beta1...v2.99.0.beta2)

Deprecations:

* Deprecate chaining `by`, `by_at_least`, `by_at_most` or `to` off of
  `expect { }.not_to change { }`. The docs have always said these are
  not supported for the negative form but now they explicitly raise
  errors in RSpec 3. (Myron Marston)
* Change the semantics of `expect { }.not_to change { x }.from(y)`.
  In RSpec 2.x, this expectation would only fail if `x` started with
  the value of `y` and changed. If it started with a different value
  and changed, it would pass. In RSpec 3, it will pass only if the
  value starts at `y` and it does not change. (Myron Marston)
* Deprecate `matcher == value` as an alias for `matcher.matches?(value)`,
  in favor of `matcher === value`. (Myron Marston)
* Deprecate `RSpec::Matchers::OperatorMatcher` in favor of
  `RSpec::Matchers::BuiltIn::OperatorMatcher`. (Myron Marston)
* Deprecate auto-integration with Test::Unit and minitest.
  Instead, include `RSpec::Matchers` in the appropriate test case
  base class yourself. (Myron Marston)
* Deprecate treating `#expected` on a DSL-generated custom matcher
  as an array when only 1 argument is passed to the matcher method.
  In RSpec 3 it will be the single value in order to make diffs
  work properly. (Jon Rowe)

### rspec-expectations 3.0.0.beta2

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Remove deprecated support for accessing the `RSpec` constant using
  `Rspec` or `Spec`. (Myron Marston)
* Remove deprecated `RSpec::Expectations.differ=`. (Myron Marston)
* Remove support for deprecated `expect(...).should`. (Myron Marston)
* Explicitly disallow `expect { }.not_to change { }` with `by`,
  `by_at_least`, `by_at_most` or `to`. These have never been supported
  but did not raise explicit errors. (Myron Marston)
* Provide `===` rather than `==` as an alias of `matches?` for
  all matchers.  The semantics of `===` are closer to an RSpec
  matcher than `==`. (Myron Marston)
* Remove deprecated `RSpec::Matchers::OperatorMatcher` constant.
  (Myron Marston)
* Make `RSpec::Expectations::ExpectationNotMetError` subclass
  `Exception` rather than `StandardError` so they can bypass
  a bare `rescue` in end-user code (e.g. when an expectation is
  set from within a rspec-mocks stub implementation). (Myron Marston)
* Remove Test::Unit and Minitest 4.x integration. (Myron Marston)

Enhancements:

* Simplify the failure message of the `be` matcher when matching against:
  `true`, `false` and `nil`. (Sam Phippen)
* Update matcher protocol and custom matcher DSL to better align
  with the newer `expect` syntax. If you want your matchers to
  maintain compatibility with multiple versions of RSpec, you can
  alias the new names to the old. (Myron Marston)
    * `failure_message_for_should` => `failure_message`
    * `failure_message_for_should_not` => `failure_message_when_negated`
    * `match_for_should` => `match`
    * `match_for_should_not` => `match_when_negated`
* Improve generated descriptions from `change` matcher. (Myron Marston)
* Add support for compound matcher expressions using `and` and `or`.
  Simply chain them off of any existing matcher to create an expression
  like `expect(alphabet).to start_with("a").and end_with("z")`.
  (Eloy Espinaco)
* Add `contain_exactly` as a less ambiguous version of `match_array`.
  Note that it expects the expected array to be splatted as
  individual args: `expect(array).to contain_exactly(1, 2)` is
  the same as `expect(array).to match_array([1, 2])`. (Myron Marston)
* Update `contain_exactly`/`match_array` so that it can match against
  other non-array collections (such as a `Set`). (Myron Marston)
* Update built-in matchers so that they can accept matchers as arguments
  to allow you to compose matchers in arbitrary ways. (Myron Marston)
* Add `RSpec::Matchers::Composable` mixin that can be used to make
  a custom matcher composable as well. Note that custom matchers
  defined via `RSpec::Matchers.define` already have this. (Myron
  Marston)
* Define noun-phrase aliases for built-in matchers, which can be
  used when creating composed matcher expressions that read better
  and provide better failure messages. (Myron Marston)
* Add `RSpec::Machers.alias_matcher` so users can define their own
  matcher aliases. The `description` of the matcher will reflect the
  alternate matcher name. (Myron Marston)
* Add explicit `be_between` matcher. `be_between` has worked for a
  long time as a dynamic predicate matcher, but the failure message
  was suboptimal. The new matcher provides a much better failure
  message. (Erik Michaels-Ober)
* Enhance the `be_between` matcher to allow for `inclusive` or `exclusive`
  comparison (e.g. inclusive of min/max or exclusive of min/max).
  (Pedro Gimenez)
* Make failure message for `not_to be #{operator}` less confusing by
  only saying it's confusing when comparison operators are used.
  (Prathamesh Sonpatki)
* Improve failure message of `eq` matcher when `Time` or `DateTime`
  objects are used so that the full sub-second precision is included.
  (Thomas Holmes, Jeff Wallace)
* Add `output` matcher for expecting that a block outputs `to_stdout`
  or `to_stderr`. (Luca Pette, Matthias Günther)
* Forward a provided block on to the `has_xyz?` method call when
  the `have_xyz` matcher is used. (Damian Galarza)
* Provide integration with Minitest 5.x. Require
  `rspec/expectations/minitest_integration` after loading minitest
  to use rspec-expectations with minitest. (Myron Marston)

Bug Fixes:

* Fix wrong matcher descriptions with falsey expected value (yujinakayama)
* Fix `expect { }.not_to change { }.from(x)` so that the matcher only
  passes if the starting value is `x`. (Tyler Rick, Myron Marston)
* Fix hash diffing, so that it colorizes properly and doesn't consider trailing
  commas when performing the diff. (Jared Norman)
* Fix built-in matchers to fail normally rather than raising
  `ArgumentError` when given an object of the wrong type to match
  against, so that they work well in composite matcher expressions like
  `expect([1.51, "foo"]).to include(a_string_matching(/foo/), a_value_within(0.1).of(1.5))`.
  (Myron Marston)

Deprecations:

* Retain support for RSpec 2 matcher protocol (e.g. for matchers
  in 3rd party extension gems like `shoulda`), but it will print
  a deprecation warning. (Myron Marston)

### rspec-mocks 2.99.0.beta2

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.99.0.beta1...v2.99.0.beta2)

Deprecations:

* Deprecate `RSpec::Mocks::Mock` in favor of `RSpec::Mocks::Double`.
  (Myron Marston)
* Deprecate the `host` argument of `RSpec::Mocks.setup`. Instead
  `RSpec::Mocks::ExampleMethods` should be included directly in the scope where
  RSpec's mocking capabilities are used. (Sam Phippen)
* Deprecate using any of rspec-mocks' features outside the per-test
  lifecycle (e.g. from a `before(:all)` hook). (Myron Marston)
* Deprecate re-using a test double in another example. (Myron Marston)
* Deprecate `and_return { value }` and `and_return` without arguments. (Yuji Nakayama)

### rspec-mocks 3.0.0.beta2

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Rename `RSpec::Mocks::Mock` to `RSpec::Mocks::Double`. (Myron Marston)
* Change how to integrate rspec-mocks in other test frameworks. You now
  need to include `RSpec::Mocks::ExampleMethods` in your test context.
  (Myron Marston)
* Prevent RSpec mocks' doubles and partial doubles from being used outside of
  the per-test lifecycle (e.g. from a `before(:all)` hook). (Sam Phippen)
* Remove the `host` argument of `RSpec::Mocks.setup`. Instead
  `RSpec::Mocks::ExampleMethods` should be included directly in the scope where
  RSpec's mocking capabilities are used. (Sam Phippen)
* Make test doubles raise errors if you attempt to use them after they
  get reset, to help surface issues when you accidentally retain
  references to test doubles and attempt to reuse them in another
  example. (Myron Marston)
* Remove support for `and_return { value }` and `and_return` without arguments. (Yuji Nakayama)

Enhancements:

* Add `receive_message_chain` which provides the functionality of the old
  `stub_chain` for the new allow/expect syntax. Use it like so: `allow(...).to
  receive_message_chain(:foo, :bar, :bazz)`. (Sam Phippen).
* Change argument matchers to use `===` as their primary matching
  protocol, since their semantics mirror that of a case or rescue statement
  (which uses `===` for matching). (Myron Marston)
* Add `RSpec::Mocks.with_temporary_scope`, which allows you to create
  temporary rspec-mocks scopes in arbitrary places (such as a
  `before(:all)` hook). (Myron Marston)
* Support keyword arguments when checking arity with verifying doubles.
  (Xavier Shay)

Bug Fixes:

* Fix regression in 3.0.0.beta1 that caused `double("string_name" => :value)`
  to stop working. (Xavier Shay)
* Fix the way rspec-mocks and rspec-core interact so that if users
  define a `let` with the same name as one of the methods
  from `RSpec::Mocks::ArgumentMatchers`, the user's `let` takes
  precedence. (Michi Huber, Myron Marston)
* Fix verified doubles so that their methods match the visibility
  (public, protected or private) of the interface they verify
  against. (Myron Marston)
* Fix verified null object doubles so that they do not wrongly
  report that they respond to anything. They only respond to methods
  available on the interface they verify against. (Myron Marston)
* Fix deprecation warning for use of old `:should` syntax w/o explicit
  config so that it no longer is silenced by an extension gem such
  as rspec-rails when it calls `config.add_stub_and_should_receive_to`.
  (Sam Phippen)
* Fix `expect` syntax so that it does not wrongly emit a "You're
  overriding a previous implementation for this stub" warning when
  you are not actually doing that. (Myron Marston)
* Fix `any_instance.unstub` when used on sub classes for whom the super
  class has had `any_instance.stub` invoked on. (Jon Rowe)
* Fix regression in `stub_chain`/`receive_message_chain` that caused
  it to raise an `ArgumentError` when passing args to the stubbed
  methods. (Sam Phippen)
* Correct stub of undefined parent modules all the way down when stubbing a
  nested constant. (Xavier Shay)
* Raise `VerifyingDoubleNotDefinedError` when a constant is not defined for
  a verifying class double. (Maurício Linhares)
* Remove `Double#to_str`, which caused confusing `raise some_double`
  behavior. (Maurício Linhares)

### rspec-rails 2.99.0.beta2

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.99.0.beta1...v2.99.0.beta2)

Deprecations:

* Deprecates the `--webrat` option to the scaffold and request spec generator (Andy Lindeman)
* Deprecates the use of `Capybara::DSL` (e.g., `visit`) in controller specs.
  It is more appropriate to use capybara in feature specs (`spec/features`)
  instead. (Andy Lindeman)

Bug Fixes:

* Use `__send__` rather than `send` to prevent naming collisions (Bradley Schaefer)
* Supports Rails 4.1. (Andy Lindeman)
* Loads ActiveSupport properly to support changes in Rails 4.1. (Andy Lindeman)
* Anonymous controllers inherit from `ActionController::Base` if `ApplicationController`
  is not present. (Jon Rowe)

### rspec-rails 3.0.0.beta2

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Removes the `--webrat` option for the request spec generator (Andy Lindeman)
* Methods from `Capybara::DSL` (e.g., `visit`) are no longer available in
  controller specs. It is more appropriate to use capybara in feature specs
  (`spec/features`) instead. (Andy Lindeman)
* `infer_base_class_for_anonymous_controllers` is
  enabled by default. (Thomas Holmes)
* Capybara 2.2.0 or above is required for feature specs. (Andy Lindeman)

Enhancements:

* Improve `be_valid` matcher for non-ActiveModel::Errors implementations (Ben Hamill)

Bug Fixes:

* Use `__send__` rather than `send` to prevent naming collisions (Bradley Schaefer)
* Supports Rails 4.1. (Andy Lindeman)
* Routes are drawn correctly for anonymous controllers with abstract
  parents. (Billy Chan)
* Loads ActiveSupport properly to support changes in Rails 4.1. (Andy Lindeman)
* Anonymous controllers inherit from `ActionController::Base` if `ApplicationController`
  is not present. (Jon Rowe)
* Require `rspec/collection_matchers` when `rspec/rails` is required. (Yuji Nakayama)

