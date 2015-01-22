---
layout: dev_post
title: RSpec 2.99 and 3.0 RC1 have been released!
section: dev-blog
contents_class: medium-wide
---

The RSpec team has released 3.0.0.rc1 and 2.99.0.rc1! Barring
a new major issue being reported, this will be the last prerelease,
and we'll release 2.99.0 and 3.0.0 final in 2 weeks.

If you're upgrading a project from 2.x, check out the [upgrade
instructions](https://relishapp.com/rspec/docs/upgrade).

If you're curious about what's new in RSpec 3, check back
in a few days -- I'll be posting full list of notable changes
in RSpec 3 soon.

Thanks to all the contributors who helped make this release happen!

## Release Notes

### rspec-core 2.99.0.rc1

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.99.0.beta2...v2.99.0.rc1)

Enhancements:

* Add `--deprecation-out` CLI option which directs deprecation warnings
  to the named file. (Myron Marston)
* Backport support for `skip` in metadata to skip execution of an example.
  (Xavier Shay, #1472)
* Add `Pathname` support for setting all output streams. (Aaron Kromer)
* Add `test_unit` and `minitest` expectation frameworks. (Aaron Kromer)

Deprecations:

* Deprecate `RSpec::Core::Pending::PendingDeclaredInExample`, use
  `SkipDeclaredInExample` instead. (Xavier Shay)
* Issue a deprecation when `described_class` is accessed from within
  a nested `describe <SomeClass>` example group, since `described_class`
  will return the innermost described class in RSpec 3 rather than the
  outermost described class, as it behaved in RSpec 2. (Myron Marston)
* Deprecate `RSpec::Core::FilterManager::DEFAULT_EXCLUSIONS`,
  `RSpec::Core::FilterManager::STANDALONE_FILTERS` and use of
  `#empty_without_conditional_filters?` on those filters. (Sergey Pchelincev)
* Deprecate `RSpec::Core::Example#options` in favor of
  `RSpec::Core::Example#metadata`. (Myron Marston)
* Issue warning when passing a symbol or hash to `describe` or `context`
  as the first argument. In RSpec 2.x this would be treated as metadata
  but in RSpec 3 it'll be treated as the described object. To continue
  having it treated as metadata, pass a description before the symbol or
  hash. (Myron Marston)
* Deprecate `RSpec::Core::BaseTextFormatter::VT100_COLORS` and
  `RSpec::Core::BaseTextFormatter::VT100_COLOR_CODES` in favour
  of `RSpec::Core::BaseTextFormatter::ConsoleCodes::VT100_CODES` and
  `RSpec::Core::BaseTextFormatter::ConsoleCodes::VT100_CODE_VALUES`.
  (Jon Rowe)
* Deprecate `RSpec::Core::ExampleGroup.display_name` in favor of
  `RSpec::Core::ExampleGroup.description`. (Myron Marston)
* Deprecate `RSpec::Core::ExampleGroup.describes` in favor of
  `RSpec::Core::ExampleGroup.described_class`. (Myron Marston)
* Deprecate `RSpec::Core::ExampleGroup.alias_example_to` in favor of
  `RSpec::Core::Configuration#alias_example_to`. (Myron Marston)
* Deprecate `RSpec::Core::ExampleGroup.alias_it_behaves_like_to` in favor
  of `RSpec::Core::Configuration#alias_it_behaves_like_to`. (Myron Marston)
* Deprecate `RSpec::Core::ExampleGroup.focused` in favor of
  `RSpec::Core::ExampleGroup.focus`. (Myron Marston)
* Add deprecation warning for `config.filter_run :focused` since
  example aliases `fit` and `focus` will no longer include
  `:focused` metadata but will continue to include `:focus`. (Myron Marston)
* Deprecate filtering by `:line_number` (e.g. `--line-number` from the
  CLI). Use location filtering instead. (Myron Marston)
* Deprecate `--default_path` as an alternative to `--default-path`. (Jon Rowe)
* Deprecate `RSpec::Core::Configuration#warnings` in favor of
  `RSpec::Core::Configuration#warnings?`. (Myron Marston)
* Deprecate `share_examples_for` in favor of `shared_examples_for` or
  just `shared_examples`. (Myron Marston)
* Deprecate `RSpec::Core::CommandLine` in favor of
  `RSpec::Core::Runner`. (Myron Marston)
* Deprecate `#color_enabled`, `#color_enabled=` and `#color?` in favour of
  `#color`, `#color=` and `#color_enabled? output`. (Jon Rowe)
* Deprecate `#filename_pattern` in favour of `#pattern`. (Jon Rowe)
* Deprecate `#backtrace_cleaner` in favour of `#backtrace_formatter`. (Jon Rowe)
* Deprecate mutating `RSpec::Configuration#formatters`. (Jon Rowe)
* Deprecate `stdlib` as an available expectation framework in favour of
  `test_unit` and `minitest`. (Aaron Kromer)

Bug Fixes:

* Issue a warning when you set `config.deprecation_stream` too late for
  it to take effect because the reporter has already been setup. (Myron Marston)
* `skip` with a block should not execute the block. (Xavier Shay)

### rspec-core 3.0.0.rc1

[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.0.0.beta2...v3.0.0.rc1)

Breaking Changes for 3.0.0:

* Change `described_class` so that in a nested group like `describe
  MyClass`, it returns `MyClass` rather than the outer group's described
  class. (Myron Marston)
* Refactor filter manager so that it no longer subclasses Hash and has a
  tighter, more domain-specific interface. (Sergey Pchelincev)
* Remove legacy colours definitions from `BaseTextFormatter`. (Jon Rowe)
* Remove console color definitions from `BaseTextFormatter`. (Jon Rowe)
* Restructure example group metadata so that the computed keys are
  exposed directly off of the metadata hash rather than being on
  a nested `:example_group` subhash. In addition, the parent example
  group metadata is now available as `[:parent_example_group]` rather
  than `[:example_group][:example_group]`. Deprecated access via the
  old key structure is still provided. (Myron Marston)
* Remove `:describes` metadata key. It duplicates `:described_class`
  for no good reason. Deprecated access via `:describes` is still
  provided. (Myron Marston)
* Rename `:example_group_block` metadata key to `:block`.
  (Myron Marston)
* Remove deprecated `RSpec::Core::Example#options`. (Myron Marston)
* Move `BaseTextFormatter#colorize_summary` to `SummaryNotification#colorize_with`
  (Jon Rowe).
* `describe some_hash` treated `some_hash` as metadata in RSpec 2.x but
  will treat it as the described object in RSpec 3.0. Metadata must
  always come after the description args. (Myron Marston)
* Remove deprecated `display_name` alias of `ExampleGroup.description`.
  (Myron Marston)
* Remove deprecated `describes` alias of `ExampleGroup.described_class`.
  (Myron Marston)
* Remove deprecated `RSpec::Core::ExampleGroup.alias_it_behaves_like_to`.
  Use `RSpec::Core::Configuration#alias_it_behaves_like_to` instead.
  (Myron Marston)
* Remove deprecated `RSpec::Core::ExampleGroup.alias_example_to`.
  Use `RSpec::Core::Configuration#alias_example_to` instead.
  (Myron Marston)
* Removed `focused` example alias and change example/group aliases
  `fit`, `focus`, `fcontext` and `fdescribe` to no longer include
  `:focused => true` metadata. They only contain `:focus => true`
  metadata now. This means that you will need to filter them with
  `filter_run :focus`, not `filter_run :focused`. (Myron Marston)
* Remove `--line-number` filtering. It's semantically dubious since it's
  a global filter (potentially applied to multiple files) but there's no
  meaningful connection between the same line number in multiple files.
  Instead use the `rspec path/to/spec.rb:23:46` form, which is terser
  and makes more sense as it is scoped to a file. (Myron Marston)
* Remove `--default_path` as an alias for `--default-path`. (Jon Rowe)
* Remove deprecated `share_examples_for`. There's still
  `shared_examples` and `shared_examples_for`. (Myron Marston)
* Rename `RSpec::Core::Configuration#warnings` to
  `RSpec::Core::Configuration#warnings?` since it's a boolean flag.
  (Myron Marston)
* RSpec's global state is no longer reset after a spec run. This gives
  more flexibility to alternate runners to decide when and if they
  want the state reset. Alternate runners are now responsible for
  calling this (or doing a similar reset) if they are going to run
  the spec suite multiple times in the same process. (Sam Phippen)
* Merge `RSpec::Core::CommandLine` (never formally declared public)
  into `RSpec::Core::Runner`. (Myron Marston)
* Remove `color_enabled` as an alias of `color`. (Jon Rowe)
* Remove `backtrace_cleaner` as an alias of `backtrace_formatter`. (Jon Rowe)
* Remove `filename_pattern` as an alias of `pattern`. (Jon Rowe)
* Extract support for legacy formatters to `rspec-legacy_formatters`. (Jon Rowe)
* `RSpec::Configuration#formatters` now returns a dup to prevent mutation. (Jon Rowe)
* Replace `stdlib` as an available expectation framework with `test_unit` and
  `minitest`. (Aaron Kromer)
* Remove backtrace formatting helpers from `BaseTextFormatter`. (Jon Rowe)
* Extract profiler support to `ProfileFormatter` and `ProfileNotification`.
  Formatters should implement `dump_profile` if they wish to respond to `--profile`.
  (Jon Rowe)
* Extract remaining formatter state to reporter and notifications. Introduce
  `ExamplesNotification` to share information about examples that was previously
  held in `BaseFormatter`. (Jon Rowe)

Enhancements:

* Add `config.default_formatter` attribute, which can be used to set a
  formatter which will only be used if no other formatter is set
  (e.g. via `--formatter`). (Myron Marston)
* Support legacy colour definitions in `LegacyFormatterAdaptor`. (Jon Rowe)
* Migrate `execution_result` (exposed by metadata) from a hash to a
  first-class object with appropriate attributes. `status` is now
  stored and returned as a symbol rather than a string. It retains
  deprecated hash behavior for backwards compatibility. (Myron Marston)
* Provide console code helper for formatters. (Jon Rowe)
* Use raw ruby hashes for the metadata hashes rather than a subclass of
  a hash. Computed metadata entries are now computed in advance rather
  than being done lazily on first access. (Myron Marston)
* Add `:block` metadata entry to the example metadata, bringing
  parity with `:block` in the example group metadata. (Myron Marston)
* Add `fspecify` and `fexample` as aliases of `specify` and `example`
  with `:focus => true` metadata for parity with `fit`. (Myron Marston)
* Add legacy support for `colorize_summary`. (Jon Rowe)
* Restructure runner so it can be more easily customized in a subclass
  for an alternate runner. (Ben Hoskings)
* Document `RSpec::Core::ConfigurationOptions` as an officially
  supported public API. (Myron Marston)
* Add `--deprecation-out` CLI option which directs deprecation warnings
  to the named file. (Myron Marston)
* Minitest 5 compatability for `expect_with :stdlib` (now available as
  `expect_with :minitest`). (Xavier Shay)
* Reporter now notifies formatters of the load time of RSpec and your
  specs via `StartNotification` and `SummaryNotification`. (Jon Rowe)
* Add `disable_monkey_patching!` config option that disables all monkey
  patching from whatever pieces of RSpec you use. (Alexey Fedorov)
* Add `Pathname` support for setting all output streams. (Aaron Kromer)
* Add `config.define_derived_metadata`, which can be used to apply
  additional metadata to all groups or examples that match a given
  filter. (Myron Marston)
* Provide formatted and colorized backtraces via `FailedExampleNotification`
  and send `PendingExampleFixedNotifications` when the error is due to a
  passing spec you expect to fail. (Jon Rowe)
* Add `dump_profile` to formatter API to allow formatters to implement
  support for `--profile`. (Jon Rowe)
* Allow colourising text via `ConsoleCodes` with RSpec 'states'
  (e.g. `:success`, `:failure`) rather than direct colour codes. (Jon Rowe)
* Expose `fully_formatted` methods off the formatter notification objects
  that make it easy for a custom formatter to produce formatted output
  like rspec-core's. (Myron Marston)

Bug Fixes:

* Fix `spec_helper.rb` file generated by `rspec --init` so that the
  recommended settings correctly use the documentation formatter
  when running one file. (Myron Marston)
* Fix ordering problem where descriptions were generated after
  tearing down mocks, which resulted in unexpected exceptions.
  (Bradley Schaefer, Aaron Kromer, Andrey Savchenko)
* Allow a symbol to be used as an implicit subject (e.g. `describe :foo`).
  (Myron Marston)
* Prevent creating an isolated context (i.e. using `RSpec.describe`) when
  already inside a context. There is no reason to do this, and it could
  potentially cause unexpected bugs. (Xavier Shay)
* Fix shared example group scoping so that when two shared example
  groups share the same name at different levels of nested contexts,
  the one in the nearest context is used. (Myron Marston)
* Fix `--warnings` option so that it enables warnings immediately so
  that it applies to files loaded by `--require`. (Myron Marston)
* Issue a warning when you set `config.deprecation_stream` too late for
  it to take effect because the reporter has already been setup. (Myron Marston)
* Add the full `RSpec::Core::Example` interface to the argument yielded
  to `around` hooks. (Myron Marston)
* Line number always takes precendence when running specs with filters.
  (Xavier Shay)
* Ensure :if and :unless metadata filters are treated as a special case
  and are always in-effect. (Bradley Schaefer)
* Ensure the currently running installation of RSpec is used when
  the rake task shells out to `rspec`, even if a newer version is also
  installed. (Postmodern)
* Using a legacy formatter as default no longer causes an infinite loop.
  (Xavier Shay)

### rspec-expectations 2.99.0.rc1

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.beta2...2.99.0.rc1)

Deprecations:

* Deprecate `matcher_execution_context` attribute on DSL-defined
  custom matchers. (Myron Marston)
* Deprecate `RSpec::Matchers::Pretty#_pretty_print`. (Myron Marston)
* Deprecate `RSpec::Matchers::Pretty#expected_to_sentence`. (Myron Marston)
* Deprecate `RSpec::Matchers::Configuration` in favor of
  `RSpec::Expectations::Configuration`. (Myron Marston)
* Deprecate `be_xyz` predicate matcher on an object that doesn't respond to
  `xyz?` or `xyzs?`. (Daniel Fone)
* Deprecate `have_xyz` matcher on an object that doesn't respond to `has_xyz?`.
  (Daniel Fone)
* Deprecate `have_xyz` matcher on an object that has a private method `has_xyz?`.
  (Jon Rowe)
* Issue a deprecation warning when a block expectation expression is
  used with a matcher that doesn't explicitly support block expectations
  via `supports_block_expectations?`. (Myron Marston)
* Deprecate `require 'rspec-expectations'`. Use
  `require 'rspec/expectations'` instead. (Myron Marston)

### rspec-expectations 3.0.0.rc1

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.0.0.beta2...v3.0.0.rc1)

Breaking Changes for 3.0.0:

* Remove `matcher_execution_context` attribute from DSL-defined
  custom matchers. (Myron Marston)
* Remove `RSpec::Matchers::Pretty#_pretty_print`. (Myron Marston)
* Remove `RSpec::Matchers::Pretty#expected_to_sentence`. (Myron Marston)
* Rename `RSpec::Matchers::Configuration` constant to
  `RSpec::Expectations::Configuration`. (Myron Marston)
* Prevent `have_xyz` predicate matchers using private methods.
  (Adrian Gonzalez)
* Block matchers must now implement `supports_block_expectations?`.
  (Myron Marston)
* Stop supporting `require 'rspec-expectations'`.
  Use `require 'rspec/expectations'` instead. (Myron Marston)

Bug Fixes:

* Fix `NoMethodError` triggered by beta2 when `YARD` was loaded in
  the test environment. (Myron Marston)
* Fix `be_xyz` matcher to accept a `do...end` block. (Myron Marston)
* Fix composable matcher failure message generation logic
  so that it does not blow up when given `$stdout` or `$stderr`.
  (Myron Marston)
* Fix `change` matcher to work properly with `IO` objects.
  (Myron Marston)
* Fix `exist` matcher so that it can be used in composed matcher
  expressions involving objects that do not implement `exist?` or
  `exists?`. (Daniel Fone)
* Fix composable matcher match logic so that it clones matchers
  before using them in order to work properly with matchers
  that use internal memoization based on a given `actual` value.
  (Myron Marston)
* Fix `be_xyz` and `has_xyz` predicate matchers so that they can
  be used in composed matcher expressions involving objects that
  do not implement the predicate method. (Daniel Fone)

Enhancements:

* Document the remaining public APIs. rspec-expectations now has 100% of
  the public API documented and will remain that way (as new undocumented
  methods will fail the build). (Myron Marston)
* Improve the formatting of BigDecimal objects in `eq` matcher failure
  messages. (Daniel Fone)
* Improve the failure message for `be_xyz` predicate matchers so
  that it includes the `inspect` output of the receiver.
  (Erik Michaels-Ober, Sam Phippen)
* Add `all` matcher, to allow you to specify that a given matcher
  matches all elements in a collection:
  `expect([1, 3, 5]).to all( be_odd )`. (Adam Farhi)
* Add boolean aliases (`&`/`|`) for compound operators (`and`/`or`). (Adam Farhi)
* Give users a clear error when they wrongly use a value matcher
  in a block expectation expression (e.g. `expect { 3 }.to eq(3)`)
  or vice versa.  (Myron Marston)

### rspec-mocks 2.99.0.rc1

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.99.0.beta2...v2.99.0.rc1)

Deprecations:

* Deprecate `RSpec::Mocks::TestDouble.extend_onto`. (Myron Marston)
* Deprecate `RSpec::Mocks::ConstantStubber`. (Jon Rowe)
* Deprecate `Marshal.dump` monkey-patch without opt-in. (Xavier Shay)

### rspec-mocks 3.0.0.rc1

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.0.0.beta2...v3.0.0.rc1)

Breaking Changes for 3.0.0:

* Remove `RSpec::Mocks::TestDouble.extend_onto`. (Myron Marston)
* Remove `RSpec::Mocks::ConstantStubber`. (Jon Rowe)
* Make monkey-patch of Marshal to support dumping of stubbed objects opt-in.
  (Xavier Shay)

Enhancements:

* Instead of crashing when cleaning up stub methods on a frozen object, it now
  issues a warning explaining that it's impossible to clean up the stubs.
  (Justin Coyne and Sam Phippen)
* Add meaningful descriptions to `anything`, `duck_type` and `instance_of` argument
  matchers. (Jon Rowe)

Bug Fixes:

* Fix regression introduced in 3.0.0.beta2 that caused
  `double.as_null_object.to_str` to return the double rather
  than a string. (Myron Marston)
* Fix bug in `expect(dbl).to receive_message_chain(:foo, :bar)` where it was
  not setting an expectation for the last message in the chain.
  (Jonathan del Strother)
* Allow verifying partial doubles to have private methods stubbed. (Xavier Shay)
* Fix bug with allowing/expecting messages on Class objects which have had
  their singleton class prepended to. (Jon Rowe)
* Fix an issue with 1.8.7 not running implementation blocks on partial doubles.
  (Maurício Linhares)
* Prevent `StackLevelTooDeep` errors when stubbing an `any_instance` method that's
  accessed in `inspect` by providing our own inspect output. (Jon Rowe)
* Fix bug in `any_instance` logic that did not allow you to mock or stub
  private methods if `verify_partial_doubles` was configured. (Oren Dobzinski)
* Include useful error message when trying to observe an unimplemented method
  on an any instance. (Xavier Shay)
* Fix `and_call_original` to work properly when multiple classes in an
  inheritance hierarchy have been stubbed with the same method. (Myron Marston)
* Fix `any_instance` so that it updates existing instances that have
  already been stubbed. (Myron Marston)
* Fix verified doubles so that their class name is included in failure
  messages. (Myron Marston)
* Fix `expect_any_instance_of` so that when the message is received
  on an individual instance that has been directly stubbed, it still
  satisfies the expectation. (Sam Phippen, Myron Marston)
* Explicitly disallow using `any_instance` to mock or stub a method
  that is defined on a module prepended onto the class. This triggered
  `SystemStackError` before and is very hard to support so we are not
  supporting it at this time. (Myron Marston)

### rspec-rails 2.99.0.rc1

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.99.0.beta2...v2.99.0.rc1)

Deprecations

* Deprecates `stub_model` and `mock_model` in favor of the
  `rspec-activemodel-mocks` gem. (Thomas Holmes)
* Issue a deprecation to instruct users to configure
  `config.infer_spec_type_from_file_location!` during the
  upgrade process since spec type inference is opt-in in 3.0.
  (Jon Rowe)
* Issue a deprecation when `described_class` is accessed in a controller
  example group that has used the `controller { }` macro to generate an
  anonymous controller class, since in 2.x, `described_class` would
  return that generated class but in 3.0 it will continue returning the
  class passed to `describe`. (Myron Marston)

### rspec-rails 3.0.0.rc1

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.0.0.beta2...v3.0.0.rc1)

Breaking Changes for 3.0.0:

* Extracts the `mock_model` and `stub_model` methods to the
  `rspec-activemodel-mocks` gem. (Thomas Holmes)
* Spec types are no longer inferred by location, they instead need to be
  explicitly tagged. The old behaviour is enabled by
  `config.infer_spec_type_from_file_location!`, which is still supplied
  in the default generated `spec_helper.rb`. (Xavier Shay, Myron Marston)
* `controller` macro in controller specs no longer mutates
  `:described_class` metadata. It still overrides the subject and sets
  the controller, though. (Myron Marston)
* Stop depending on or requiring `rspec-collection_matchers`. Users who
  want those matchers should add the gem to their Gemfile and require it
  themselves. (Myron Marston)
* Removes runtime dependency on `ActiveModel`. (Rodrigo Rosenfeld Rosas)

Enhancements:

* Supports Rails 4.x reference attribute ids in generated scaffold for view
  specs. (Giovanni Cappellotto)
* Add `have_http_status` matcher. (Aaron Kromer)
* Add spec type metadata to generator templates. (Aaron Kromer)

Bug Fixes:

* Fix an inconsistency in the generated scaffold specs for a controller. (Andy Waite)
* Ensure `config.before(:all, :type => <type>)` hooks run before groups
  of the given type, even when the type is inferred by the file
  location. (Jon Rowe, Myron Marston)
* Switch to parsing params with `Rack::Utils::parse_nested_query` to match Rails.
  (Tim Watson)
* Fix incorrect namespacing of anonymous controller routes. (Aaron Kromer)
