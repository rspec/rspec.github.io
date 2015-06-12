---
title: RSpec 3.3 has been released!
author: Myron Marston
---

RSpec 3.3 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3.0, 3.1 or 3.2, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 769 commits and 200
merged pull requests from nearly 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Unique IDs for every Example and Example Group

Historically, RSpec examples have been identified primarily by _file
location_. For example, this command:

~~~
$ rspec spec/unit/baseball_spec.rb:23
~~~

...would run an example or example group defined on line 23 of
`spec/unit/baseball_spec.rb`. Location-based identification generally
works well, but does not always uniquely identity a particular example.
For example, if you use shared examples, your spec suite may
have multiple copies of the example defined at
`spec/support/shared_examples.rb:47`.

RSpec 3.3 introduces a new way to identify examples and example groups:
unique IDs. The IDs are scoped to a particular file and are based on the
index of the example or group. For example, this command:

~~~
$ rspec spec/unit/baseball_spec.rb[1:2,1:4]
~~~

...would run the 2nd and 4th example or group defined under the 1st
top-level group defined in `spec/unit/baseball_spec.rb`.

For the most part, the new example IDs are primarily used internally by
RSpec to support some of the new 3.3 features, but you're free to use
them from the command line. The re-run command printed by RSpec for
each failure will use them if the file location does not uniquely
identify the failed example. Copying and pasting the re-run command
for a particular failed example will always run just that example now!

### Core: New `--only-failures` option

Now that RSpec has a robust way to uniquely identify every example, we've
added new filtering capabilities to allow you to run only the failures. To
enable this feature, you first have to configure RSpec so it knows where
to persist the status of each example:

~~~ ruby
RSpec.configure do |c|
  c.example_status_persistence_file_path = "./spec/examples.txt"
end
~~~

Once you've configured that, RSpec will begin persisting the status of each
example after every run of your suite. You'll probably want to add this file
to `.gitignore` (or whatever the equivalent for your source control system is),
as it's not intended to be kept under source control. With that configuration
in place, you can use the new CLI option:

~~~
$ rspec --only-failures
# or apply it to a specific file or directory:
$ rspec spec/unit --only-failures
~~~

It's worth noting that this option filters to the examples that failed
the last time they ran, not just to the failures from the last run of
`rspec`. That means, for example, that if there's a slow acceptance spec
that you don't generally run locally (leaving it to your CI server to
run it), and it failed the last time it ran locally, even if it was weeks ago,
it'll be included when you run `rspec --only-failures`.

See our [relish
docs](https://relishapp.com/rspec/rspec-core/v/3-3/docs/command-line/only-failures)
for an end-to-end example of this feature.

### Core: New `--next-failure` option

When making a change that causes many failures across my spec suite---such
as renaming a commonly used method---I've often used a specific work flow:

1. Run the entire suite to get the failure list.
2. Run each failure individually in sequence using the re-run command
   that RSpec printed, fixing each example before moving on to the next failure.

This allows me to systematically work through all of the failures,
without paying the cost of repeatedly running the entire suite. RSpec
3.3 includes a new option that vastly simplifies this work flow:

~~~
$ rspec --next-failure
# or apply it to a specific file or directory:
$ rspec spec/unit --next-failure
~~~

This option is the equivalent of `--only-failures --fail-fast --order defined`.
It filters to only failures, and will abort as soon as one fails. It
applies `--order defined` in order to ensure that you keep getting the same
failing example when you run it multiple times in a row without fixing
the example.

### Core: Stable Random Ordering

RSpec's random ordering has always allowed you to pass a particular
`--seed` to run the suite in the same order as a prior run. However,
this only worked if you ran the same set of examples as the original
run. If you apply the seed to a subset of examples, their ordering
wouldn't necessarily be consistent relative to each other. This is
a consequence of how `Array#shuffle` works: `%w[ a b c d ].shuffle` may
order `c` before `b`, but `%w[ b c d ].shuffle` may order `c` _after_
`b` even if you use the same random seed.

This may not seem like a big deal, but it makes `--seed` far less
useful. When you are trying to track down the source of an ordering
dependency, you have to keep running the entire suite to reproduce
the failure.

RSpec 3.3 addresses this. We no longer use `shuffle` for random
ordering. Instead, we combine the `--seed` value with the id of each
example, hash it, and sort by the produced values. This ensures that
if a particular seed orders example `c` before example `b`, `c` will
always come before `b` when you re-use that seed no matter what subset
of the suite you are running.

While stable random ordering is useful in its own right, the big win
here is a new feature that it enables: bisect.

### Core: Bisect

RSpec has supported random ordering (with a `--seed` option to reproduce
a particular ordering) since RSpec 2.8. These features help surface
ordering dependencies between specs, which you'll want to quickly
isolate and fix.

Unfortunately, RSpec provided little to help with isolating
an ordering dependency. That's changing in RSpec 3.3. We now provide
a `--bisect` option that narrows an ordering dependency down to a
minimal reproduction case. The new bisect flag repeatedly runs subsets
of your suite in order to isolate the minimal set of examples that
reproduce the same failures when you run your whole suite.

Stable random ordering makes it possible for you to run various subsets
of the suite to try to narrow an ordering dependency down to a minimal 
reproduction case.

See our [relish
docs](https://relishapp.com/rspec/rspec-core/v/3-3/docs/command-line/bisect)
for an end-to-end example of this feature.

### Core: Thread Safe `let` and `subject`

Historically, `let` and `subject` have [never been
thread safe](http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/MemoizedHelpers/ClassMethods.html#let-instance_method).
That's changing in RSpec 3.3, thanks to the [great
work](https://github.com/rspec/rspec-core/pull/1858) of Josh Cheek.

Note that the thread safety synchronization does add a bit of overhead,
as you'd expect. If you're not spinning up any threads in your examples
and want to avoid that overhead, you can configure RSpec to
[disable](http://rspec.info/documentation/3.3/rspec-core/RSpec/Core/Configuration.html#threadsafe-instance_method) the thread safety.

### Expectations: New `aggregrate_failures` API

When you've got multiple independent expectations to make about a
particular result, there's generally two routes you can take. One way is
to define a separate example for each expectation:

~~~ ruby
RSpec.describe Client do
  let(:response) { Client.make_request }

  it "returns a 200 response" do
    expect(response.status).to eq(200)
  end

  it "indicates the response body is JSON" do
    expect(response.headers).to include("Content-Type" => "application/json")
  end

  it "returns a success message" do
    expect(response.body).to eq('{"message":"Success"}')
  end
end
~~~

This follows the "one expectation per example" guideline that encourages
you to keep each spec focused on a single facet of behavior. Alternately,
you can put all the expectations in a single example:

~~~ ruby
RSpec.describe Client do
  it "returns a successful JSON response" do
    response = Client.make_request

    expect(response.status).to eq(200)
    expect(response.headers).to include("Content-Type" => "application/json")
    expect(response.body).to eq('{"message":"Success"}')
  end
end
~~~

This latter approach is going to be faster, as the request is only made once
rather than three times. However, if the status code is not a 200, the example
will abort on the first expectation and you won't be able to see whether or not
the latter two expectations passed or not.

RSpec 3.3 has a new feature that helps when, for speed or other reasons, you
want to put multiple expectations in a single example. Simply wrap your
expectations in an `aggregate_failures` block:

~~~ ruby
RSpec.describe Client do
  it "returns a successful JSON response" do
    response = Client.make_request

    aggregate_failures "testing response" do
      expect(response.status).to eq(200)
      expect(response.headers).to include("Content-Type" => "application/json")
      expect(response.body).to eq('{"message":"Success"}')
    end
  end
end
~~~

Within the `aggregate_failures` block, expectations failures do not cause the
example to abort. Instead, a single _aggregate_ exception will be
raised at the end containing multiple sub-failures which RSpec will
format nicely for you:

~~~
1) Client returns a successful response
   Got 3 failures from failure aggregation block "testing reponse".
   # ./spec/client_spec.rb:5

   1.1) Failure/Error: expect(response.status).to eq(200)

          expected: 200
               got: 404

          (compared using ==)
        # ./spec/client_spec.rb:6

   1.2) Failure/Error: expect(response.headers).to include("Content-Type" => "application/json")
          expected {"Content-Type" => "text/plain"} to include {"Content-Type" => "application/json"}
          Diff:
          @@ -1,2 +1,2 @@
          -[{"Content-Type"=>"application/json"}]
          +"Content-Type" => "text/plain",
        # ./spec/client_spec.rb:7

   1.3) Failure/Error: expect(response.body).to eq('{"message":"Success"}')

          expected: "{\"message\":\"Success\"}"
               got: "Not Found"

          (compared using ==)
        # ./spec/client_spec.rb:8
~~~

`RSpec::Core` provides improved support for this feature through the use of
metadata. Instead of wrapping the expectations with `aggregate_failures`,
simply tag the example or group with `:aggregate_failures`:

~~~ ruby
RSpec.describe Client, :aggregate_failures do
  it "returns a successful JSON response" do
    response = Client.make_request

    expect(response.status).to eq(200)
    expect(response.headers).to include("Content-Type" => "application/json")
    expect(response.body).to eq('{"message":"Success"}')
  end
end
~~~

If you want to enable this feature everywhere, you can use [`define_derived_metadata`](http://rspec.info/documentation/3.3/rspec-core/RSpec/Core/Configuration.html#define_derived_metadata-instance_method):

~~~ ruby
RSpec.configure do |c|
  c.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
end
~~~

Of course, you may not want this enabled everywhere. When you've got _dependent_ expectations
(e.g. where an expectation only makes sense if the prior expectation passed), or if you're
using expectations to express a pre-condition, you'll probably want the example to immediately abort
when the expectation fails.

### Expectations: Improved Failure Output

RSpec 3.3 includes improved failure messages across the board for all matchers.
Test doubles now look prettier in our failure messages:

~~~
Failure/Error: expect([foo]).to include(bar)
  expected [#<Double "Foo">] to include #<Double "Bar">
  Diff:
  @@ -1,2 +1,2 @@
  -[#<Double "Bar">]
  +[#<Double "Foo">]
~~~

In addition, RSpec's improved formatting for `Time` and other objects will
now be used wherever those objects are inspected, regardless of which
built-in matcher you used. So, for example, where you used to get this:

~~~
Failure/Error: expect([Time.now]).to include(Time.now)
  expected [2015-06-09 07:48:06 -0700] to include 2015-06-09 07:48:06 -0700
~~~

...you'll now get this instead:

~~~
Failure/Error: expect([Time.now]).to include(Time.now)
  expected [2015-06-09 07:49:16.610635000 -0700] to include 2015-06-09 07:49:16.610644000 -0700
  Diff:
  @@ -1,2 +1,2 @@
  -[2015-06-09 07:49:16.610644000 -0700]
  +[2015-06-09 07:49:16.610635000 -0700]
~~~

...which makes it much clearer that the time objects differ at the level of milliseconds.

Thanks to Gavin Miller, Nicholas Chmielewski and Siva Gollapalli for contributing to
these improvements!

### Mocks: Improved Failure Output

RSpec::Mocks has also received some nice improvements to its failure output. RSpec's
improved formatting for `Time` and other objects is now applied to mock expectation
failures as well:

~~~
Failure/Error: dbl.foo(Time.now)
  #<Double (anonymous)> received :foo with unexpected arguments
    expected: (2015-06-09 08:33:36.865827000 -0700)
         got: (2015-06-09 08:33:36.874197000 -0700)
  Diff:
  @@ -1,2 +1,2 @@
  -[2015-06-09 08:33:36.865827000 -0700]
  +[2015-06-09 08:33:36.874197000 -0700]
~~~

In addition, the failure output for `have_received` has been much improved so that when
the expected args do not match, it lists each set of actual args, and the number of
times the message was received with those args:

~~~
Failure/Error: expect(dbl).to have_received(:foo).with(3)
  #<Double (anonymous)> received :foo with unexpected arguments
    expected: (3)
         got: (1) (2 times)
              (2) (1 time)
~~~

Thanks to John Ceh for implementing the latter improvement!

### Mocks: Stubbing `MyClass.new` Verifies Against `MyClass#initialize`

RSpec's [verifying doubles](https://relishapp.com/rspec/rspec-mocks/v/3-3/docs/verifying-doubles)
use the metadata that Ruby's reflection capabilities provide to verify,
among other things, that passed arguments are valid according to the
original method's signature. However, when a method is defined using
just an arg splat:

~~~ ruby
def method_1(*args)
  method_2(*args)
end

def method_2(a, b)
end
~~~

...then the verifying double is going to allow _any_ arguments, even
if the method simply delegates to _another_ method that does have a
strong signature. Unfortunately, `Class#new` is one of these methods.
It's defined by Ruby to delegate to `#initialize`, and will only accept
arguments that the signature of `initialize` can handle, but the metadata
provided by `MyClass.method(:new).parameters` indicates it can handle any
arguments, even if it can't.

In RSpec 3.3, we've improved verifying doubles so that when you stub
`new` on a class, it uses the method signature of `#initialize` to
verify arguments, unless you've redefined `new` to do something
different. This allows verifying doubles to give you an error when
you pass arguments to a stubbed `MyClass#new` method that the real
class would not allow.

### Rails: Generated scaffold routing specs now include PATCH spec

Rails 4 added support for `PATCH` as the primary HTTP method for
updates. The routing matchers in rspec-rails have likewise supported
`PATCH` since 2.14, but the generated scaffold spec were not updated
to match. This has been
[addressed](https://github.com/rspec/rspec-rails/pull/1336) in
rspec-rails 3.3.

Thanks to Igor Zubkov for this improvement!

### Rails: New `:job` spec type

Now that `ActiveJob` is part of Rails, rspec-rails has a new `:job` spec
type that you can opt into by either tagging your example group with
`:type => :job` or putting the spec file in `spec/jobs` if you've
enabled `infer_spec_type_from_file_location!`.

Thanks to Gabe Martin-Dempesy for this improvement!

## Stats

### Combined: 

* **Total Commits**: 769
* **Merged pull requests**: 200
* **49 contributors**: Aaron Kromer, Alex Kwiatkowski, Andrey Botalov, Anton Davydov, Ben Axnick, Benjamin Fleischer, Bradley Schaefer, ChrisArcand, David Daniell, Denis Laliberté, Eugene Kenny, Fabian Wiesel, Fabien Schurter, Fabio Napoleoni, Gabe Martin-Dempesy, Gavin Miller, Igor Zubkov, Jared Beck, Jean van der Walt, Joe Grossberg, Johannes Gorset, John Ceh, Jon Rowe, Josh Cheek, Leo Arnold, Lucas Mazza, Mark Swinson, Mauricio Linhares, Melissa Xie, Myron Marston, Nicholas Chmielewski, Nicholas Henry, Orien Madgwick, Pavel Shpak, Raymond Sanchez, Ryan Mulligan, Ryan Ong, Sam Phippen, Samnang Chhun, Samuel Esposito, Siva Gollapalli, Tim Wade, Tony Ta, Vít Ondruch, Yule, charlierudolph, machty, raymond sanchez, takiy33

### rspec-core: 

* **Total Commits**: 323
* **Merged pull requests**: 65
* **19 contributors**: Alex Kwiatkowski, Ben Axnick, Benjamin Fleischer, Denis Laliberté, Eugene Kenny, Fabien Schurter, Fabio Napoleoni, Jon Rowe, Josh Cheek, Leo Arnold, Mark Swinson, Melissa Xie, Myron Marston, Raymond Sanchez, Ryan Ong, Samuel Esposito, Yule, raymond sanchez, takiy33

### rspec-expectations: 

* **Total Commits**: 148
* **Merged pull requests**: 40
* **12 contributors**: Andrey Botalov, ChrisArcand, Fabien Schurter, Gavin Miller, Jared Beck, Jon Rowe, Myron Marston, Ryan Mulligan, Tim Wade, charlierudolph, machty, takiy33

### rspec-mocks: 

* **Total Commits**: 132
* **Merged pull requests**: 39
* **13 contributors**: Bradley Schaefer, Fabien Schurter, John Ceh, Jon Rowe, Mauricio Linhares, Myron Marston, Nicholas Henry, Pavel Shpak, Sam Phippen, Samnang Chhun, Siva Gollapalli, Tim Wade, takiy33

### rspec-rails: 

* **Total Commits**: 83
* **Merged pull requests**: 24
* **15 contributors**: Aaron Kromer, Anton Davydov, David Daniell, Gabe Martin-Dempesy, Igor Zubkov, Jean van der Walt, Joe Grossberg, Johannes Gorset, Jon Rowe, Lucas Mazza, Myron Marston, Orien Madgwick, Tony Ta, Vít Ondruch, takiy33

### rspec-support: 

* **Total Commits**: 83
* **Merged pull requests**: 32
* **8 contributors**: Benjamin Fleischer, Fabian Wiesel, Gavin Miller, Jon Rowe, Myron Marston, Nicholas Chmielewski, Siva Gollapalli, takiy33

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

### rspec-core-3.3.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.2.3...v3.3.0)

Enhancements:

* Expose the reporter used to run examples via `RSpec::Core::Example#reporter`.
  (Jon Rowe, #1866)
* Make `RSpec::Core::Reporter#message` a public supported API. (Jon Rowe, #1866)
* Allow custom formatter events to be published via
  `RSpec::Core::Reporter#publish(event_name, hash_of_attributes)`. (Jon Rowe, #1869)
* Remove dependency on the standard library `Set` and replace with `RSpec::Core::Set`.
  (Jon Rowe, #1870)
* Assign a unique id to each example and group so that they can be
  uniquely identified, even for shared examples (and similar situations)
  where the location isn't unique. (Myron Marston, #1884)
* Use the example id in the rerun command printed for failed examples
  when the location is not unique. (Myron Marston, #1884)
* Add `config.example_status_persistence_file_path` option, which is
  used to persist the last run status of each example. (Myron Marston, #1888)
* Add `:last_run_status` metadata to each example, which indicates what
  happened the last time an example ran. (Myron Marston, #1888)
* Add `--only-failures` CLI option which filters to only the examples
  that failed the last time they ran. (Myron Marston, #1888)
* Add `--next-failure` CLI option which allows you to repeatedly focus
  on just one of the currently failing examples, then move on to the
  next failure, etc. (Myron Marston, #1888)
* Make `--order random` ordering stable, so that when you rerun a
  subset with a given seed, the examples will be order consistently
  relative to each other. (Myron Marston, #1908)
* Set example group constant earlier so errors when evaluating the context
  include the example group name (Myron Marson, #1911)
* Make `let` and `subject` threadsafe. (Josh Cheek, #1858)
* Add version information into the JSON formatter. (Mark Swinson, #1883)
* Add `--bisect` CLI option, which will repeatedly run your suite in
  order to isolate the failures to the smallest reproducible case.
  (Myron Marston, #1917)
* For `config.include`, `config.extend` and `config.prepend`, apply the
  module to previously defined matching example groups. (Eugene Kenny, #1935)
* When invalid options are parsed, notify users where they came from
  (e.g. `.rspec` or `~/.rspec` or `ENV['SPEC_OPTS']`) so they can
  easily find the source of the problem. (Myron Marston, #1940)
* Add pending message contents to the json formatter output. (Jon Rowe, #1949)
* Add shared group backtrace to the output displayed by the built-in
  formatters for pending examples that have been fixed. (Myron Marston, #1946)
* Add support for `:aggregate_failures` metadata. Tag an example or
  group with this metadata and it'll use rspec-expectations'
  `aggregate_failures` feature to allow multiple failures in an example
  and list them all, rather than aborting on the first failure. (Myron
  Marston, #1946)
* When no formatter implements #message add a fallback to prevent those
  messages being lost. (Jon Rowe, #1980)
* Profiling examples now takes into account time spent in `before(:context)`
  hooks. (Denis Laliberté, Jon Rowe, #1971)
* Improve failure output when an example has multiple exceptions, such
  as one from an `it` block and one from an `after` block. (Myron Marston, #1985)

Bug Fixes:

* Handle invalid UTF-8 strings within exception methods. (Benjamin Fleischer, #1760)
* Fix Rake Task quoting of file names with quotes to work properly on
  Windows. (Myron Marston, #1887)
* Fix `RSpec::Core::RakeTask#failure_message` so that it gets printed
  when the task failed. (Myron Marston, #1905)
* Make `let` work properly when defined in a shared context that is applied
  to an individual example via metadata. (Myron Marston, #1912)
* Ensure `rspec/autorun` respects configuration defaults. (Jon Rowe, #1933)
* Prevent modules overriding example group defined methods when included,
  prepended or extended by config defined after an example group. (Eugene Kenny, #1935)
* Fix regression which caused shared examples to be mistakenly run when specs
  where filtered to a particular location.  (Ben Axnick, #1963)
* Fix time formatting logic so that it displays 70 seconds as "1 minute,
  10 seconds" rather than "1 minute, 1 second". (Paul Brennan, #1984)
* Fix regression where the formatter loader would allow duplicate formatters.
  (Jon Rowe, #1990)


### rspec-expectations-3.3.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.2.1...v3.3.0)

Enhancements:

* Expose `RSpec::Matchers::EnglishPhrasing` to make it easier to write
  nice failure messages in custom matchers. (Jared Beck, #736)
* Add `RSpec::Matchers::FailMatchers`, a mixin which provides
  `fail`, `fail_with` and `fail_including` matchers for use in
  specifying that an expectation fails for use by
  extension/plugin authors. (Charlie Rudolph, #729)
* Avoid loading `tempfile` (and its dependencies) unless
  it is absolutely needed. (Myron Marston, #735)
* Improve failure output when attempting to use `be_true` or `be_false`.
  (Tim Wade, #744)
* Define `RSpec::Matchers#respond_to_missing?` so that
  `RSpec::Matchers#respond_to?` and `RSpec::Matchers#method` handle
  dynamic predicate matchers. (Andrei Botalov, #751)
* Use custom Time/DateTime/BigDecimal formatting for all matchers
  so they are consistently represented in failure messages.
  (Gavin Miller, #740)
* Add configuration to turn off warnings about matcher combinations that
  may cause false positives. (Jon Rowe, #768)
* Warn when using a bare `raise_error` matcher that you may be subject to
  false positives. (Jon Rowe, #768)
* Warn rather than raise when using the`raise_error` matcher in negative
  expectations that may be subject to false positives. (Jon Rowe, #775)
* Improve failure message for `include(a, b, c)` so that if `a` and `b`
  are included the failure message only mentions `c`. (Chris Arcand, #780)
* Allow `satisfy` matcher to take an optional description argument
  that will be used in the `description`, `failure_message` and
  `failure_message_when_negated` in place of the undescriptive
  "sastify block". (Chris Arcand, #783)
* Add new `aggregate_failures` API that allows multiple independent
  expectations to all fail and be listed in the failure output, rather
  than the example aborting on the first failure. (Myron Marston, #776)
* Improve `raise_error` matcher so that it can accept a matcher as a single argument
  that matches the message. (Time Wade, #782)

Bug Fixes:

* Make `contain_exactly` / `match_array` work with strict test doubles
  that have not defined `<=>`. (Myron Marston, #758)
* Fix `include` matcher so that it omits the diff when it would
  confusingly highlight items that are actually included but are not
  an exact match in a line-by-line diff. (Tim Wade, #763)
* Fix `match` matcher so that it does not blow up when matching a string
  or regex against another matcher (rather than a string or regex).
  (Myron Marston, #772)
* Silence whitespace-only diffs. (Myron Marston, #801)


### rspec-mocks-3.3.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.2.1...v3.3.0)

Enhancements:

* When stubbing `new` on `MyClass` or `class_double(MyClass)`, use the
  method signature from `MyClass#initialize` to verify arguments.
  (Myron Marston, #886)
* Use matcher descriptions when generating description of received arguments
  for mock expectation failures. (Tim Wade, #891)
* Avoid loading `stringio` unnecessarily. (Myron Marston, #894)
* Verifying doubles failure messages now distinguish between class and instance
  level methods. (Tim Wade, #896, #908)
* Improve mock expectation failure messages so that it combines both
  number of times and the received arguments in the output. (John Ceh, #918)
* Improve how test doubles are represented in failure messages.
  (Siva Gollapalli, Myron Marston, #932)
* Rename `RSpec::Mocks::Configuration#when_declaring_verifying_double` to
  `RSpec::Mocks::Configuration#before_verifying_doubles` and utilise when
  verifying partial doubles. (Jon Rowe, #940)
* Use rspec-support's `ObjectFormatter` for improved formatting of
  arguments in failure messages so that, for example, full time
  precisions is displayed for time objects. (Gavin Miller, Myron Marston, #955)

Bug Fixes:

* Ensure expectations that raise eagerly also raise during RSpec verification.
  This means that if exceptions are caught inside test execution the test will
  still fail. (Sam Phippen, #884)
* Fix `have_received(msg).with(args).exactly(n).times` and
  `receive(msg).with(args).exactly(n).times` failure messages
  for when the message was received the wrong number of times with
  the specified args, and also received additional times with other
  arguments. Previously it confusingly listed the arguments as being
  mis-matched (even when the double was allowed to receive with any
  args) rather than listing the count. (John Ceh, #918)
* Fix `any_args`/`anything` support so that we avoid calling `obj == anything`
  on user objects that may have improperly implemented `==` in a way that
  raises errors. (Myron Marston, #924)
* Fix edge case involving stubbing the same method on a class and a subclass
  which previously hit a `NoMethodError` internally in RSpec. (Myron Marston #954)
* Fix edge case where the message received count would be incremented multiple
  times for one failure. (Myron Marston, #957)
* Fix failure messages for when spies received the expected message with
  different arguments and also received another message. (Maurício Linhares, #960)
* Silence whitespace-only diffs. (Myron Marston, #969)


### rspec-rails-3.3.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.2.3...v3.3.0)

Enhancements:

* Add support for PATCH to route specs created via scaffold. (Igor Zubkov, #1336)
* Improve controller and routing spec calls to `routes` by using `yield`
  instead of `call`. (Anton Davydov, #1308)
* Add support for `ActiveJob` specs as standard `RSpec::Rails::RailsExampleGoup`s
  via both `:type => :job` and inferring type from spec directory `spec/jobs`.
  (Gabe Martin-Dempesy, #1361)
* Include `RSpec::Rails::FixtureSupport` into example groups using metadata
  `:use_fixtures => true`. (Aaron Kromer, #1372)
* Include `rspec:request` generator for generating request specs; this is an
  alias of `rspec:integration` (Aaron Kromer, #1378)
* Update `rails_helper` generator with a default check to abort the spec run
  when the Rails environment is production. (Aaron Kromer, #1383)


### rspec-support-3.3.0
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.2.2...v3.3.0)

Enhancements:

* Improve formatting of arrays and hashes in failure messages so they
  use our custom formatting of matchers, time objects, etc.
  (Myron Marston, Nicholas Chmielewski, #205)
* Use improved formatting for diffs as well. (Nicholas Chmielewski, #205)

Bug Fixes:

* Fix `FuzzyMatcher` so that it checks `expected == actual` rather than
  `actual == expected`, which avoids errors in situations where the
  `actual` object's `==` is improperly implemented to assume that only
  objects of the same type will be given. This allows rspec-mocks'
  `anything` to match against objects with buggy `==` definitions.
  (Myron Marston, #193)
