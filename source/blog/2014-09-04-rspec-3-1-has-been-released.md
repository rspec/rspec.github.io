---
title: RSpec 3.1 has been released!
author: Myron Marston
---

RSpec 3.1 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3.0, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 647 commits from 190
pull requests from 47 different contributors.

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Backtrace filtering changes

In RSpec 2.x and RSpec 3.0, the default backtrace filtering configuration
excluded lines from gems from printed backraces. We [got some
feedback](https://github.com/rspec/rspec-core/issues/1536#issuecomment-43521129)
that this was unhelpful and have removed `/gems/` from the default
backtrace filter patterns. In RSpec 3.1, lines from gems will be
included backtraces, but lines from RSpec itself will continue to be
excluded. Of course, if you want still gems to be excluded, you can easily
add this pattern back yourself:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.backtrace_exclusion_patterns << /gems/
end
{% endcodeblock %}

In addition, we've added a new API to make it easy to filter out one
or more specific gems:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.filter_gems_from_backtrace "rack", "rake"
end
{% endcodeblock %}

### Core: New `--exclude-pattern` option

RSpec 3.1 has a new `--exclude-pattern` option that is the inverse of
`--pattern`. This allows you to exclude particular files, so that,
for example, you can load and run all spec files except those from
a particular directory:

{% codeblock %}
rspec --pattern "spec/**/*_spec.rb" --exclude-pattern "spec/acceptance/**/*_spec.rb"
{% endcodeblock %}

The rake task definition API supports this option now, too, so it is
easy to define tasks that run all specs but those from one directory:

{% codeblock Rakefile lang:ruby %}
require 'rspec/core/rake_task'

desc "Run all but the acceptance specs"
RSpec::Core::RakeTask.new(:all_but_acceptance) do |t|
  t.exclude_pattern = "spec/acceptance/**/*_spec.rb"
end
{% endcodeblock %}

Thanks to John Gesimondo for suggesting and
[implementing](https://github.com/rspec/rspec-core/pull/1651)
this new feature!

### Core: Can now be used standalone without configuration

RSpec got split up into separate gems (core, expecations and mocks) in RSpec 2.0,
which allows users to [mix and
match parts of RSpec](/n/dev-blog/2012/07/mixing-and-matching-parts-of-rspec)
with other testing libraries like Minitest. Tom Stuart pointed out that it
wasn't as easy to use just rspec-core as it could be--specifically, in RSpec 3.0 and
before, if you didn't explicitly configure rspec-core to not use
rspec-expectations and rspec-mocks, it assumed they were available,
tried to load them, and gave you an error if they were not.

In RSpec 3.1, we've rectified this. rspec-expectations and rspec-mocks
will still both be used by default if available, but it they are not
available and you haven't configured anything, rspec-core will work just
fine.

Thanks to Sam Phippen for [implementating](https://github.com/rspec/rspec-core/pull/1615) this improvement.

### Core: Warnings flag no longer defaults to true in generated files

In RSpec 3.0, we put `--warnings` in the generated `.rspec` file. We
did that to encourage gem authors to make their gems warning-free (as
gems that issue warnings inhibit users from using Ruby's warning mode).
However, the rails ecosystem has generally not strived to have warning-free
code, and on new rails projects, this led to a _ton_ of confusing warnings.

In RSpec 3.1, we learned from the community feedback on this and have removed
`--warnings` from the generated `.rspec` file. In non-rails projects, `rspec --init`
will include `config.warnings = true` in the commented-out section of recommended
settings in `spec_helper.rb`.

Thanks to Andrew Hooker for [making this change](https://github.com/rspec/rspec-core/pull/1572).

### Expectations: New `have_attributes` matcher

This new matcher makes it easy to match an object based on its attributes:

{% codeblock lang:ruby %}
Person = Struct.new(:name, :age)
person = Person.new("Coen", 3)
expect(person).to have_attributes(name: "Coen", age: 3)
{% endcodeblock %}

It's also aliased to `an_object_having_attributes`, which is particularly
useful in composed matcher expressions:

{% codeblock lang:ruby %}
people = [Person.new("Coen", 3), Person.new("Daphne", 2)]
expect(people).to match([
  an_object_having_attributes(name: "Coen",   age: 3),
  an_object_having_attributes(name: "Daphne", age: 2)
])
{% endcodeblock %}

It can also be used as an argument matcher for a message expectation:

{% codeblock lang:ruby %}
expect(email_gateway).to receive(:send_receipt).with(
  an_object_having_attributes(email: "foo@example.com")
)
{% endcodeblock %}

Thanks to Adam Farhi for
[implementing](https://github.com/rspec/rspec-expectations/pull/571)
this new matcher.

### Expectations: Block matchers can now be used in compound expressions

RSpec 3.0 gained the ability to use [compound matcher
expressions](/n/dev-blog/2014/01/new-in-rspec-3-composable-matchers#compound_matcher_expressions).
However, it didn't work with block expectations because we had internal
changes that needed to be made to ensure the block is only executed
once as one would expect. We've addressed this in 3.1, which allows an
expression like:

{% codeblock lang:ruby %}
x = y = 0
expect {
  x += 1
  y += 2
}.to change { x }.to(1).and change { y }.to(2)
{% endcodeblock %}

### Expectations: New `define_negated_matcher` API

This new API provides a means to define a negated version of an existing matcher:

{% codeblock lang:ruby %}
# define a negated form of `include`...
RSpec::Matchers.define_negated_matcher :exclude, :include

# ...which allows you to write:
expect(odd_numbers).to exclude(14)

# ...rather than:
expect(odd_numbers).not_to include(14)
{% endcodeblock %}

On its own, this doesn't buy you much. However, it really comes in handy
when dealing with composed or compound matcher expressions:

{% codeblock lang:ruby %}
adults = Town.find("Springfield").adults
marge  = Character.find("Marge")
bart   = Character.find("Bart")

expect(adults).to include(marge).and exclude(bart)
{% endcodeblock %}

Thanks to Adam Farhi for helping with the
[implementation](https://github.com/rspec/rspec-expectations/pull/618)
of this feature.

### Expectations: Custom matcher chained modifiers now included in generated description

The custom matcher DSL allows you to define a fluent interface using
`chain`:

{% codeblock lang:ruby %}
RSpec::Matchers.define :be_smaller_than do |max|
  chain :and_bigger_than do |min|
    @min = min
  end

  match do |actual|
    actual < max && actual > @min
  end
end

# usage:
expect(10).to be_smaller_than(20).and_bigger_than(5)
{% endcodeblock %}

In RSpec 2.x and 3.0, the chained part was not included in failure messages:

{% codeblock %}
Failure/Error: expect(5).to be_smaller_than(10).and_bigger_than(7)
  expected 5 to be smaller than 10
{% endcodeblock %}

RSpec 3.1 can include the chained part in the failure message:

{% codeblock %}
Failure/Error: expect(5).to be_smaller_than(10).and_bigger_than(7)
  expected 5 to be smaller than 10 and bigger than 7
{% endcodeblock %}

...but only if you enable this behavior with a config option:

{% codeblock lang:ruby %}
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
{% endcodeblock %}

This config option defaults to `false` for backwards compatibility.
We plan to always enable it in RSpec 4.

Thanks to Dan Oved for
[implementing](https://github.com/rspec/rspec-expectations/pull/600)
this improvement!

### Mocks: New `*_spy` methods

RSpec 2.14 added support for using test doubles as spies, which allow
you to set an expectation that a message was received after the fact:

{% codeblock lang:ruby %}
spy = double(:foo => nil)
# do something with spy
expect(spy).to have_received(:foo)
{% endcodeblock %}

Note that we stubbed `foo` here. This is necessary because doubles are
strict by default -- meaning that they will raise an error when they
receive an unexpected message. Unfortunately, this forces a bit of
duplication on you as you have to declare the method twice (stubbing it
once before and expecting it was received after).

You can get around this by using `as_null_object` which makes a double
"loose" rather than strict, allowing it to receive any message:

{% codeblock lang:ruby %}
spy = double.as_null_object
# do something with spy
expect(spy).to have_received(:foo)
{% endcodeblock %}

This pattern is useful enough that in RSpec 3.1, we've added new methods
to declare spies:

{% codeblock lang:ruby %}
spy(...)          # equivalent to double(...).as_null_object
instance_spy(...) # equivalent to instance_double(...).as_null_object
class_spy(...)    # equivalent to class_double(...).as_null_object
object_spy(...)   # equivalent to object_double(...).as_null_object
{% endcodeblock %}

Thanks to Justin Searls for [bringing
up this issue](https://github.com/rspec/rspec-mocks/issues/636) and
Sam Phippen for
[implementing](https://github.com/rspec/rspec-mocks/pull/671) the new
methods.

### Mocks: New `and_wrap_original` API

This new API allows you to easily decorate a particular existing method on a
particular object just for the duration of the current example. The
original method is yielded to your block as the first argument (before
the args of the actual method call).

{% codeblock lang:ruby %}
allow(api_client).to receive(:fetch_users).and_wrap_original do |original_method, *args|
  original_method.call(*args).first(10) # truncate the response to the first 10 users
end
{% endcodeblock %}

Thanks to Jon Rowe for
[implementing](https://github.com/rspec/rspec-mocks/pull/762) this
feature.

### Rails: Rails 4.2 support

rspec-rails 3.1 will officially support Rails 4.2. Aaron Kromer has been
doing a great job getting RSpec 3.1 ready for Rails 4.2. This includes
a generator [provided by Abdelkader
Boudih](https://github.com/rspec/rspec-rails/pull/1155) for ActiveJob.

### Rails: Generated `rails_helper.rb` no longer auto-loads `spec/support` files by default

Aaron has also [made a small change](https://github.com/rspec/rspec-rails/pull/1137)
to the generator for `rails_helper.rb`.  Previously, it contained some code that
would automatically load all files under `spec/support`. That code is still
there but is now commented out.  We've found that it helps prevent load time
bloat to manually require the support files that are needed, rather than
always loading all of them.

Of course, if you prefer the convenience of the old way, that's a reasonable
tradeoff, and you can easily uncomment this bit of code.

## Stats

### rspec-core:

* **Total Commits**: 176
* **Merged pull requests**: 50
* **20 contributors**: Aaron Kromer, Alex Tan, Andrew Hooker, Christian Treppo, Colin Jones, Daniela Wellisz, Dominic Muller, Evgeny Zislis, Gary Fleshman, Jimmy Cuadra, John Gesimondo, Jon Rowe, Mark Lorenz, Max Lincoln, Myron Marston, Paul Cortens, Prem Sichanugrist, Sam Phippen, Su Zhang (張甦), tomykaira

### rspec-expectations:

* **Total Commits**: 149
* **Merged pull requests**: 40
* **14 contributors**: Aaron Kromer, Abdelkader Boudih, Adam Farhi, Alex Sunderland, Chris Griego, Dennis Taylor, Hao Su, Jon Rowe, Myron Marston, Pritesh Jain, Sam Phippen, Xavier Shay, fimmtiu, oveddan

### rspec-mocks:

* **Total Commits**: 118
* **Merged pull requests**: 39
* **13 contributors**: Aaron Kromer, Chris Griego, Dennis Taylor, Eugene Kenny, Igor Kapkov, Jimmy Cuadra, Jon Rowe, Karthik T, Myron Marston, Oliver Martell Núñez, Sam Phippen, Thomas Brand, Xavier Shay

### rspec-rails:

* **Total Commits**: 137
* **Merged pull requests**: 38
* **16 contributors**: Aaron Kromer, Abdelkader Boudih, Alex Rothenberg, Andre Arko & Doc Ritezel, André Arko, Bradley Schaefer, Diego Plentz, Jon Rowe, Josh Kalderimis, Juan González, Kosmas Chatzimichalis, Michael E. Gruen, Myron Marston, Sam Phippen, Thomas Kriechbaumer, joker1007

### rspec-support:

* **Total Commits**: 67
* **Merged pull requests**: 23
* **8 contributors**: Aaron Kromer, Ben Langfeld, Jimmy Cuadra, Jon Rowe, Myron Marston, Pritesh Jain, Sam Phippen, Xavier Shay

## Docs

### API Docs

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

### rspec-core-3.1.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.0.4...v3.1.0)

Enhancements:

* Update files generated by `rspec --init` so that warnings are enabled
  in commented out section of `spec_helper` rather than `.rspec` so users
  have to consciously opt-in to the setting. (Andrew Hooker, #1572)
* Update `spec_helper` generated by `rspec --init` so that it sets the new
  rspec-expectations `include_chain_clauses_in_custom_matcher_descriptions`
  config option (which will be on by default in RSpec 4) and also sets the
  rspec-mocks `verify_partial_doubles` option (which will also default
  to on in RSpec 4). (Myron Marston, #1647)
* Provide an `inspect` output for example procsy objects (used in around
  hooks) that doesn't make them look like procs. (Jon Rowe, #1620)
* Remove a few unneeded `require` statements from
  `rspec/core/rake_task.rb`, making it even more lighterweight.
  (Myron Marston, #1640)
* Allow rspec-core to be used when neither rspec-mocks or
  rspec-expectations are installed, without requiring any
  user configuration. (Sam Phippen, Myron Marston, #1615)
* Don't filter out gems from backtraces by default. (The RSpec
  gems will still be filtered). User feedback has indicated
  that including gems in default backtraces will be useful.
  (Myron Marston, #1641)
* Add new `config.filter_gems_from_backtrace "rack", "rake"` API
  to easily filter the named gems from backtraces. (Myron Marston, #1682)
* Fix default backtrace filters so that the RSpec binary is
  excluded when installing RSpec as a bundler `:git` dependency.
  (Myron Marston, #1648)
* Simplify command generated by the rake task so that it no longer
  includes unnecessary `-S`. (Myron Marston, #1559)
* Add `--exclude-pattern` CLI option, `config.exclude_pattern =` config
  option and `task.exclude_pattern =` rake task config option. Matching
  files will be excluded. (John Gesimondo, Myron Marston, #1651, #1671)
* When an around hook fails to execute the example, mark it as
  pending (rather than passing) so the user is made aware of the
  fact that the example did not actually run. (Myron Marston, #1660)
* Remove dependency on `FileUtils` from the standard library so that users do
  not get false positives where their code relies on it but they are not
  requiring it. (Sam Phippen, #1565)

Bug Fixes:

* Fix rake task `t.pattern =` option so that it does not run all specs
  when it matches no files, by passing along a `--pattern` option to
  the `rspec` command, rather than resolving the file list and passing
  along the files individually. (Evgeny Zislis, #1653)
* Fix rake task default pattern so that it follows symlinks properly.
  (Myron Marston, #1672)
* Fix default pattern used with `rspec` command so that it follows
  symlinks properly. (Myron Marston, #1672)
* Change how we assign constant names to example group classes so that
  it avoids a problem with `describe "Core"`. (Daniela Wellisz, #1679)
* Handle rendering exceptions that have a different encoding than that
  of their original source file. (Jon Rowe, #1681)
* Allow access to message_lines without colour for failed examples even
  when they're part of a shared example group. (tomykaira, #1689)


### rspec-expectations-3.1.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.0.4...v3.1.0)

Enhancements:

* Add `have_attributes` matcher, that passes if actual's attribute
  values match the expected attributes hash:
  `Person = Struct.new(:name, :age)`
  `person = Person.new("Bob", 32)`
  `expect(person).to have_attributes(:name => "Bob", :age => 32)`.
  (Adam Farhi, #571)
* Extended compound matcher support to block matchers, for cases like:
  `expect { ... }.to change { x }.to(3).and change { y }.to(4)`. (Myron
  Marston, #567)
* Include chained methods in custom matcher description and failure message
  when new `include_chain_clauses_in_custom_matcher_descriptions` config
  option is enabled. (Dan Oved, #600)
* Add `thrice` modifier to `yield_control` matcher as a synonym for
  `exactly(3).times`. (Dennis Taylor, #615)
* Add `RSpec::Matchers.define_negated_matcher`, which defines a negated
  version of the named matcher. (Adam Farhi, Myron Marston, #618)
* Document and support negation of `contain_exactly`/`match_array`.
  (Jon Rowe, #626).

Bug Fixes:

* Rename private `LegacyMacherAdapter` constant to `LegacyMatcherAdapter`
  to fix typo. (Abdelkader Boudih, #563)
* Fix `all` matcher so that it fails properly (rather than raising a
  `NoMethodError`) when matched against a non-enumerable. (Hao Su, #622)


### rspec-mocks-3.1.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.0.4...v3.1.0)

Enhancements:

* Add spying methods (`spy`, `ìnstance_spy`, `class_spy` and `object_spy`)
  which create doubles as null objects for use with spying in testing. (Sam
  Phippen, #671)
* `have_received` matcher will raise "does not implement" errors correctly when
  used with verifying doubles and partial doubles. (Xavier Shay, #722)
* Allow matchers to be used in place of keyword arguments in `with`
  expectations. (Xavier Shay, #726)
* Add `thrice` modifier to message expectation interface as a synonym
  for `exactly(3).times`. (Dennis Taylor, #753)
* Add more `thrice` synonyms e.g. `.at_least(:thrice)`, `.at_most(:thrice)`,
  `receive(...).thrice` and `have_received(...).thrice`. (Jon Rowe, #754)
* Add `and_wrap_original` modifier for partial doubles to mutate the
  response from a method. (Jon Rowe, #762)

Bugfixes:

* Remove `any_number_of_times` from `any_instance` recorders that were
  erroneously causing mention of the method in documentation. (Jon Rowe, #760)
* Prevent included modules being detected as prepended modules on Ruby 2.0.
  (Eugene Kenny, #771)


### rspec-rails-3.1.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.0.2...v3.1.0)

Enhancements:

* Switch to using the `have_http_status` matcher in spec generators. (Aaron Kromer, #1086)
* Update `rails_helper` generator to allow users to opt-in to auto-loading
  `spec/support` files instead of forcing it upon them. (Aaron Kromer, #1137)
* Include generator for `ActiveJob`. (Abdelkader Boudih, #1155)
* Improve support for non-ActiveRecord apps by not loading ActiveRecord related
  settings in the generated `rails_helper`. (Aaron Kromer, #1150)
* Remove Ruby warnings as a suggested configuration. (Aaron Kromer, #1163)

Bug Fixes:

* Fix controller route lookup for Rails 4.2. (Tomohiro Hashidate, #1142)
