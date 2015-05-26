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
from all over the world. This release includes 752 commits and 198
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
docs (TODO)](https://relishapp.com/rspec-staging/rspec-core/docs/command-line/only-failures)
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
docs (TODO)](https://relishapp.com/rspec-staging/rspec-core/docs/command-line/bisect)
for an end-to-end example of this feature.

### Core: Thread Safe `let` and `subject`

Historically, `let` and `subject` have [never been
thread safe](http://rspec.info/documentation/3.2/rspec-core/RSpec/Core/MemoizedHelpers/ClassMethods.html#let-instance_method).
That's changing in RSpec 3.3, thanks to the [great
work](https://github.com/rspec/rspec-core/pull/1858) of Josh Cheek.

Note that the thread safety synchronization does add a bit of overhead,
as you'd expect. If you're not spinning up any threads in your examples
and want to avoid that overhead, you can configure RSpec to
[disable](TODO) the thread safety.

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

If you want to enable this feature everywhere, you can use [`define_derived_metadata`](TODO):

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

RSpec's [verifying doubles
(TODO)](https://relishapp.com/rspec/rspec-mocks/v/3-2/docs/verifying-doubles)
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

* **Total Commits**: 752
* **Merged pull requests**: 198
* **49 contributors**: Aaron Kromer, Alex Kwiatkowski, Andrey Botalov, Anton Davydov, Ben Axnick, Benjamin Fleischer, Bradley Schaefer, ChrisArcand, David Daniell, Denis Laliberté, Eugene Kenny, Fabian Wiesel, Fabien Schurter, Fabio Napoleoni, Gabe Martin-Dempesy, Gavin Miller, Igor Zubkov, Jared Beck, Jean van der Walt, Joe Grossberg, Johannes Gorset, John Ceh, Jon Rowe, Josh Cheek, Leo Arnold, Lucas Mazza, Mark Swinson, Mauricio Linhares, Melissa Xie, Myron Marston, Nicholas Chmielewski, Nicholas Henry, Orien Madgwick, Pavel Shpak, Raymond Sanchez, Ryan Mulligan, Ryan Ong, Sam Phippen, Samnang Chhun, Samuel Esposito, Siva Gollapalli, Tim Wade, Tony Ta, Vít Ondruch, Yule, charlierudolph, machty, raymond sanchez, takiy33

### rspec-core:

* **Total Commits**: 314
* **Merged pull requests**: 63
* **19 contributors**: Alex Kwiatkowski, Ben Axnick, Benjamin Fleischer, Denis Laliberté, Eugene Kenny, Fabien Schurter, Fabio Napoleoni, Jon Rowe, Josh Cheek, Leo Arnold, Mark Swinson, Melissa Xie, Myron Marston, Raymond Sanchez, Ryan Ong, Samuel Esposito, Yule, raymond sanchez, takiy33

### rspec-expectations:

* **Total Commits**: 146
* **Merged pull requests**: 40
* **12 contributors**: Andrey Botalov, ChrisArcand, Fabien Schurter, Gavin Miller, Jared Beck, Jon Rowe, Myron Marston, Ryan Mulligan, Tim Wade, charlierudolph, machty, takiy33

### rspec-mocks:

* **Total Commits**: 130
* **Merged pull requests**: 39
* **13 contributors**: Bradley Schaefer, Fabien Schurter, John Ceh, Jon Rowe, Mauricio Linhares, Myron Marston, Nicholas Henry, Pavel Shpak, Sam Phippen, Samnang Chhun, Siva Gollapalli, Tim Wade, takiy33

### rspec-rails:

* **Total Commits**: 81
* **Merged pull requests**: 24
* **15 contributors**: Aaron Kromer, Anton Davydov, David Daniell, Gabe Martin-Dempesy, Igor Zubkov, Jean van der Walt, Joe Grossberg, Johannes Gorset, Jon Rowe, Lucas Mazza, Myron Marston, Orien Madgwick, Tony Ta, Vít Ondruch, takiy33

### rspec-support:

* **Total Commits**: 81
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

TODO
