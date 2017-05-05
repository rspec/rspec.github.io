---
title: RSpec 3.6 has been released!
author: Sam Phippen
---

RSpec 3.6 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be an easy
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over 450 commits and 120
merged pull requests from 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Errors outside examples now handled and formatted well

In previous versions of RSpec, we allowed errors encountered while loading spec
files or running `:suite` hooks to crash the ruby interpreter, giving you its
default full-stacktrace output.  In RSpec 3.6, we now handle all errors that
occur outside examples, and format them nicely including a filtered backtrace
and a code snippet for the site of the error.  For example, an error in a
`before(:suite)` hook is now formatted like this:

<img alt="Errors outside example execution"
src="/images/blog/errors_outside_example.png">

Thanks to Jon Rowe for assisting with this feature.

### Core: Output coloring is set automatically if RSpec is outputting to a tty.

In past versions of RSpec, you were required to specify `--color` if you wanted
output coloring, regardless of whether you were outputting to a terminal, a
file, a CI system, or some other output location. Now, RSpec will automatically
color output if it detects it is running in a TTY. You can still force coloring
with `--color`, or if you are running in a TTY and explicitly do not want color,
you can specify `--no-color` to disable this behavior.

We thank Josh Justice for adding this behavior to RSpec.

### Core: `config.fail_if_no_examples`

As it currently stands RSpec will exit with code `0` indicating success if no
examples are defined. This option allows you to configure RSpec to exit with
code `1` indicating failure. This is useful in CI environments, as it helps
detect when you've misconfigured RSpec to look for specs in the wrong place or
with the wrong pattern. When no specs are found and `config.fail_if_no_examples`
is set we consider this to be an error as opposed to passing the suite run.

~~~ ruby
RSpec.configure do |config|
  config.fail_if_no_examples = true
end
~~~

A special thanks to Ewa Czechowska for getting this in to core.

### Expectations: Improved failure messages for the `change` and `satisfy` matchers

The `change` and `satisfy` matchers both accept a block. For the
`change` matcher, you use this to specify _what_ you expect to change.
For the `satisfy` matcher you use a block to specify your pass/fail
criteria.  In either case, the failure message has always been pretty
generic.  For example, consider these specs:

~~~ ruby
RSpec.describe "`change` and `satisfy` matchers" do
  example "`change` matcher" do
    a = b = 1

    expect {
      a += 1
      b += 2
    }.to change { a }.by(1)
    .and change { b }.by(1)
  end

  example "`satisfy` matcher" do
    expect(2).to satisfy { |x| x.odd? }
            .and satisfy { |x| x.positive? }
  end
end
~~~

Prior versions of RSpec would fail with messages like
"expected result to have changed by 1, but was changed by 2"
and "expected 2 to satisfy block".  In both cases, the failure
message is accurate, but does not help you distinguish _which_
`change` or `satisfy` matcher failed.

Here's what the failure output looks like on RSpec 3.6:

~~~
Failures:

  1) `change` and `satisfy` matchers `change` matcher
     Failure/Error:
       expect {
         a += 1
         b += 2
       }.to change { a }.by(1)
       .and change { b }.by(1)

       expected `b` to have changed by 1, but was changed by 2
     # ./spec/example_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) `change` and `satisfy` matchers `satisfy` matcher
     Failure/Error:
       expect(2).to satisfy { |x| x.odd? }
               .and satisfy { |x| x.positive? }

       expected 2 to satisfy expression `x.odd?`
     # ./spec/example_spec.rb:13:in `block (2 levels) in <top (required)>'
~~~

Thanks to the great work of Yuji Nakayama, RSpec now uses
[Ripper](http://ruby-doc.org/stdlib-2.4.0/libdoc/ripper/rdoc/Ripper.html)
to extract a snippet to include in the failure message. If we're not
able to extract a simple, single-line snippet, we fall back to the older
generic messages.

### Expectations: Scoped aliased and negated matchers

In RSpec 3, we added `alias_matcher`, allowing users to
[alias matchers](http://rspec.info/blog/2014/01/new-in-rspec-3-composable-matchers/#matcher-aliases)
for better readability. In 3.1 we added the ability to define
[negated matchers](http://rspec.info/blog/2014/09/rspec-3-1-has-been-released/#expectations-new-definenegatedmatcher-api)
with the `define_negated_matcher` method.

Before RSpec 3.6 when you called either of these methods the newly defined
matchers were always defined at the global scope. With this feature you are able
to invoke either `alias_matcher` or `define_negated_matcher` in the scope of an
example group (`describe`, `context`, etc). When doing so the newly defined
matcher will only be available to examples in that example group and any nested
groups:

~~~ ruby
RSpec.describe 'scoped matcher aliases' do
  describe 'example group with a matcher alias' do
    alias_matcher :be_a_string_starting_with, :start_with

    it 'can use the matcher alias' do
      expect('a').to be_a_string_starting_with('a')
    end
  end

  describe 'example group without the matcher alias' do
    it 'cannot use the matcher alias' do
      # fails because the matcher alias is not available
      expect('a').to be_a_string_starting_with('a')
    end
  end
end
~~~

Thanks to Markus Reiter for contributing this feature.

### Mocks: `without_partial_double_verification`

When we released RSpec 3.0 we added [verifying doubles](http://rspec.info/blog/2014/05/notable-changes-in-rspec-3/#verifying-doubles).
Verifying doubles allow you to ensure that stubs and mocks that you create with
RSpec correctly emulate the interfaces on the objects in your tests.
`without_partial_double_verification` allows you to turn off the verifying
double behaviour for the duration of the execution of a block. For example:

~~~ ruby
class Widget
  def call(takes_an_arg)
  end
end

RSpec.describe Widget do
  it 'can be stub with a mismatched arg count' do
    without_partial_double_verification do
      w = Widget.new
      allow(w).to receive(:call).with(1, 2).and_return(3)
      w.call(1, 2)
    end
  end
end
~~~

Here, this test would fail if the `without_partial_double_verification` call was
not made, because we are stubbing the `call` method on the `Widget` object with
an argument count that is different from the implementation. We added this feature
specifically to address a problem with partial double verification when stubbing
locals in views. Details can be found in [this issue](https://github.com/rspec/rspec-mocks/issues/1102)
and the rspec-rails issues linked from it.

A special thanks to Jon Rowe for adding this feature.

### Rails: Support for Rails 5.1:

RSpec 3.6.0 comes with full support for Rails 5.1. There are no major changes to
the rails 5.1 API and so this upgrade should be fully smooth. Simply bumping to
the latest version of RSpec will bring the support to your app with no other
changes required on your part.

Rails [system tests](http://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/) are not yet supported,
but we plan to add support for them in the near future.


## Stats:

### Combined:

* **Total Commits**: 493
* **Merged pull requests**: 127
* **58 contributors**: Alessandro Berardi, Alex Coomans, Alex DeLaPena, Alyssa Ross, Andy Morris, Anthony Dmitriyev, Ben Pickles, Benjamin Quorning, Damian Simon Peter, David Grayson, Devon Estes, Dillon Welch, Eugene Kenny, Ewa Czechowska, Gaurish Sharma, Glauco Custódio, Hanumakanth, Hun Jae Lee, Ilya Lavrov, Isaac Betesh, John Meehan, Jon Jensen, Jon Moss, Jon Rowe, Josh Justice, Juanito Fatas, Jun Aruga, Kevin Glowacz, Koichi ITO, Krzysztof Zych, Luke Rollans, Luís Costa, Mark Campbell, Markus Reiter, Markus Schwed, Megan O'Neill, Mike Butsko, Mitsutaka Mimura, Myron Marston, Olle Jonsson, Phil Thompson, Sam Phippen, Samuel Giddins, Samuel Lourenço, Sasha Gerrand, Sophie Déziel, Travis Spangle, VTJamie, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, ansonK, bootstraponline, gajewsky, matrinox, mrageh, proby, yui-knk

### rspec-core:

* **Total Commits**: 201
* **Merged pull requests**: 59
* **25 contributors**: Alyssa Ross, Benjamin Quorning, David Grayson, Devon Estes, Eugene Kenny, Ewa Czechowska, Ilya Lavrov, Jon Jensen, Jon Rowe, Josh Justice, Juanito Fatas, Jun Aruga, Mark Campbell, Mitsutaka Mimura, Myron Marston, Phil Thompson, Sam Phippen, Samuel Lourenço, Travis Spangle, VTJamie, Xavier Shay, Yuji Nakayama, bootstraponline, matrinox, yui-knk

### rspec-expectations:

* **Total Commits**: 85
* **Merged pull requests**: 25
* **11 contributors**: Alex DeLaPena, Alyssa Ross, Gaurish Sharma, Jon Rowe, Koichi ITO, Markus Reiter, Myron Marston, Sam Phippen, Xavier Shay, Yuji Nakayama, gajewsky

### rspec-mocks:

* **Total Commits**: 68
* **Merged pull requests**: 17
* **13 contributors**: Alessandro Berardi, Alex DeLaPena, Dillon Welch, Glauco Custódio, Jon Rowe, Luís Costa, Myron Marston, Olle Jonsson, Sam Phippen, Samuel Giddins, Yuji Nakayama, mrageh, proby

### rspec-rails:

* **Total Commits**: 84
* **Merged pull requests**: 13
* **25 contributors**: Andy Morris, Anthony Dmitriyev, Ben Pickles, Damian Simon Peter, Hanumakanth, Hun Jae Lee, Isaac Betesh, John Meehan, Jon Moss, Jon Rowe, Josh Justice, Kevin Glowacz, Krzysztof Zych, Luke Rollans, Markus Schwed, Megan O'Neill, Mike Butsko, Myron Marston, Sam Phippen, Sasha Gerrand, Sophie Déziel, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, yui-knk

### rspec-support:

* **Total Commits**: 55
* **Merged pull requests**: 13
* **7 contributors**: Alex Coomans, Jon Rowe, Myron Marston, Olle Jonsson, Sam Phippen, Yuji Nakayama, ansonK

## Docs

### API Docs

* [rspec-core](/documentation/3.6/rspec-core/)
* [rspec-expectations](/documentation/3.6/rspec-expectations/)
* [rspec-mocks](/documentation/3.6/rspec-mocks/)
* [rspec-rails](/documentation/3.6/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### RSpec Core (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Add seed information to JSON formatter output. (#2388, Mitsutaka Mimura)
* Include example id in the JSON formatter output. (#2369, Xavier Shay)
* Respect changes to `config.output_stream` after formatters have been
  setup. (#2401, #2419, Ilya Lavrov)

Bug Fixes:

* Delay formatter loading until the last minute to allow accessing the reporter
  without triggering formatter setup. (Jon Rowe, #2243)
* Ensure context hook failures running before an example can access the
  reporter. (Jon Jensen, #2387)
* Multiple fixes to allow using the runner multiple times within the same
  process: `RSpec.clear_examples` resets the formatter and no longer clears
  shared examples, and streams can be used across multiple runs rather than
  being closed after the first. (#2368, Xavier Shay)
* Prevent unexpected `example_group_finished` notifications causing an error.
  (#2396, VTJamie)
* Fix bugs where `config.when_first_matching_example_defined` hooks would fire
  multiple times in some cases. (Yuji Nakayama, #2400)
* Default `last_run_status` to "unknown" when the `status` field in the
  persistence file contains an unrecognized value. (#2360, matrinox)
* Prevent `let` from defining an `initialize` method. (#2414, Jon Rowe)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Include count of errors occurring outside examples in default summaries.
  (#2351, Jon Rowe)
* Warn when including shared example groups recursively. (#2356, Jon Rowe)
* Improve failure snippet syntax highlighting with CodeRay to highlight
  RSpec "keywords" like `expect`. (#2358, Myron Marston)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.5.4...v3.6.0.beta1)

Enhancements:

* Warn when duplicate shared examples definitions are loaded due to being
  defined in files matching the spec pattern (e.g. `_spec.rb`) (#2278, Devon Estes)
* Improve metadata filtering so that it can match against any object
  that implements `===` instead of treating regular expressions as
  special. (Myron Marston, #2294)
* Improve `rspec -v` so that it prints out the versions of each part of
  RSpec to prevent confusion. (Myron Marston, #2304)
* Add `config.fail_if_no_examples` option which causes RSpec to fail if
  no examples are found. (Ewa Czechowska, #2302)
* Nicely format errors encountered while loading spec files.
  (Myron Marston, #2323)
* Improve the API for enabling and disabling color output (Josh
  Justice, #2321):
  * Automatically enable color if the output is a TTY, since color is
    nearly always desirable if the output can handle it.
  * Introduce new CLI flag to force color on (`--force-color`), even
    if the output is not a TTY. `--no-color` continues to work as well.
  * Introduce `config.color_mode` for configuring the color from Ruby.
    `:automatic` is the default and will produce color if the output is
    a TTY. `:on` forces it on and `:off` forces it off.

### RSpec Expectations (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Treat NoMethodError as a failure for comparison matchers. (Jon Rowe, #972)
* Allow for scoped aliased and negated matchers--just call
  `alias_matcher` or `define_negated_matcher` from within an example
  group. (Markus Reiter, #974)
* Improve failure message of `change` matcher with block and `satisfy` matcher
  by including the block snippet instead of just describing it as `result` or
  `block` when Ripper is available. (Yuji Nakayama, #987)

Bug Fixes:

* Fix `yield_with_args` and `yield_successive_args` matchers so that
  they compare expected to actual args at the time the args are yielded
  instead of at the end, in case the method that is yielding mutates the
  arguments after yielding. (Alyssa Ross, #965)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.6.0.beta1...v3.6.0.beta2)

Bug Fixes:

* Using the exist matcher on `File` no longer produces a deprecation warning.
  (Jon Rowe, #954)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Fix `contain_exactly` to work correctly with ranges. (Myron Marston, #940)
* Fix `change` to work correctly with sets. (Marcin Gajewski, #939)

### RSpec Mocks (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0.beta2...v3.6.0)

Bug Fixes:

* Fix "instance variable @color not initialized" warning when using
  rspec-mocks without rspec-core. (Myron Marston, #1142)
* Restore aliased module methods properly when stubbing on 1.8.7.
  (Samuel Giddins, #1144)
* Allow a message chain expectation to be constrained by argument(s).
  (Jon Rowe, #1156)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Add new `without_partial_double_verification { }` API that lets you
  temporarily turn off partial double verification for an example.
  (Jon Rowe, #1104)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Return the test double instance form `#freeze` (Alessandro Berardi, #1109)
* Allow the special logic for stubbing `new` to work when `<Class>.method` has
  been redefined. (Proby, #1119)

### RSpec Rails (combining all betas of RSpec 3.6.0)

#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Add compatibility for Rails 5.1. (Sam Phippen, Yuichiro Kaneko, #1790)

Bug Fixes:

* Fix scaffold generator so that it does not generate broken controller specs
  on Rails 3.x and 4.x. (Yuji Nakayama, #1710)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Improve failure output of ActiveJob matchers by listing queued jobs.
  (Wojciech Wnętrzak, #1722)
* Load `spec_helper.rb` earlier in `rails_helper.rb` by default.
  (Kevin Glowacz, #1795)

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.5.2...v3.6.0.beta1)

Enhancements:

* Add support for `rake notes` in Rails `>= 5.1`. (John Meehan, #1661)
* Remove `assigns` and `assert_template` from scaffold spec generators (Josh
  Justice, #1689)
* Add support for generating scaffolds for api app specs. (Krzysztof Zych, #1685)

### RSpec Support (combining all betas of RSpec 3.6.0)


#### 3.6.0 / 2017-05-04
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0.beta2...3.6.0)

Enhancements:

* Import `Source` classes from rspec-core. (Yuji Nakayama, #315)

#### 3.6.0.beta2 / 2016-12-12
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.6.0.beta1...v3.6.0.beta2)

No user-facing changes.

#### 3.6.0.beta1 / 2016-10-09
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.5.0...v3.6.0.beta1)

Bug Fixes:

* Prevent truncated formatted object output from mangling console codes. (#294, Anson Kelly)
