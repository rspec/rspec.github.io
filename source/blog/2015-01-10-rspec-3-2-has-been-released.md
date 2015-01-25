---
title: RSpec 3.2 has been released!
author: Myron Marston
published: false
---

(TODO: consider writing a new intro.)

RSpec 3.2 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3.0 or 3.1, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 647 commits from 190
pull requests from 47 different contributors.

Thank you to everyone who helped make this release happen!

## Notable Changes

### Windows CI

### Core: Performance Improvements

### Core: New Sandboxing API

### Core: Each Example Now Has a Singleton Group

### Expectations: DSL-Defined Custom Matchers Can Now Receive Blocks

### Expectations: Chain shorthand for DSL-Defined Custom Matchers

### Mocks: `any_args` Works as a an Arg Splat

### Mocks: Mismatched Args Are Now Diffed

## Stats

(As of 2015-01-01. I plan to regenerate this after releasing 3.2).

### Combined: 

* **Total Commits**: 661
* **Merged pull requests**: 202
* **43 contributors**: Aaron Kromer, Akos Vandra, Alex Chaffee, Alex Genco, Alexey Fedorov, Andy Waite, Arlandis Lawrence, Avner Cohen, Ben Moss, Ben Snape, Cezary Baginski, ChaYoung You, Christian Nelson, Dennis Ideler, Elena Sharma, Elia Schito, Eliot Sykes, Griffin Smith, Jim Kingdon, Jon Rowe, Jonathan, Jonathan Rochkind, Jori Hardman, Kevin Mook, Melanie Gilman, Mike Dalton, Myron Marston, Peter Rhoades, Piotr Jakubowski, Postmodern, Rebecca Skinner, Sam Phippen, Scott Archer, Takashi Nakagawa, Thaddee Tyl, Tim Wade, Tom Schady, Tom Stuart, Tony Novak, Xavier Shay, Yuji Nakayama, dB, tyler-ball

### rspec-core: 

* **Total Commits**: 270
* **Merged pull requests**: 67
* **18 contributors**: Aaron Kromer, Akos Vandra, Alex Chaffee, Alexey Fedorov, Arlandis Lawrence, Ben Moss, Ben Snape, ChaYoung You, Christian Nelson, Jim Kingdon, Jon Rowe, Jonathan Rochkind, Kevin Mook, Mike Dalton, Myron Marston, Sam Phippen, Tom Schady, tyler-ball

### rspec-expectations: 

* **Total Commits**: 99
* **Merged pull requests**: 36
* **12 contributors**: Aaron Kromer, Alex Genco, Avner Cohen, Ben Moss, Elia Schito, Jon Rowe, Jonathan, Jori Hardman, Mike Dalton, Myron Marston, Postmodern, Tom Stuart

### rspec-mocks: 

* **Total Commits**: 123
* **Merged pull requests**: 43
* **14 contributors**: Aaron Kromer, Andy Waite, Ben Moss, Cezary Baginski, Jon Rowe, Melanie Gilman, Myron Marston, Piotr Jakubowski, Sam Phippen, Tim Wade, Tom Schady, Tony Novak, Xavier Shay, dB

### rspec-rails: 

* **Total Commits**: 100
* **Merged pull requests**: 29
* **14 contributors**: Aaron Kromer, Ben Moss, Dennis Ideler, Elena Sharma, Eliot Sykes, Griffin Smith, Jon Rowe, Myron Marston, Peter Rhoades, Rebecca Skinner, Sam Phippen, Takashi Nakagawa, Thaddee Tyl, Yuji Nakayama

### rspec-support: 

* **Total Commits**: 69
* **Merged pull requests**: 27
* **7 contributors**: Aaron Kromer, Alex Genco, Ben Moss, Jon Rowe, Myron Marston, Sam Phippen, Scott Archer

## Docs

### API Docs

(TODO: update this with relative links to ourselves once the branches are all merged.)

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

(As of 2015-01-01. I plan to regenerate this after releasing 3.2).

### rspec-core-3.2.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.1.7...master)

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


### rspec-expectations-3.2.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.1.2...master)

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
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.1.3...master)

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


### rspec-rails-3.2.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.1.7...master)

Enhancements:

* Include generator for `ActionMailer` mailer previews (Takashi Nakagawa, #1185)
* Configure the `ActionMailer` preview path via a Railtie (Aaron Kromer, #1236)
* Show all RSpec generators when running `rails generate` (Eliot Sykes, #1248)
* Support Ruby 2.2 with Rails 4.x (Aaron Kromer, #1264)

Bug Fixes:

* Fix `rspec:feature` generator to use `RSpec` namespace preventing errors when
  monkey-patching is disabled. (Rebecca Skinner, #1231)
* Fix `NoMethodError` caused by calling `RSpec.feature` when Capybara is not
  available or the Capybara version is < 2.4.0. (Aaron Kromer, #1261)

