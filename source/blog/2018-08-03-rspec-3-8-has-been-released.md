---
title: RSpec 3.8 has been released!
author: Myron Marston and Jon Rowe
---

RSpec 3.8 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be an easy
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

We're also happy to announce that [Benoit Tigeot](https://github.com/benoittgt)
has joined the RSpec team since the last release. Welcome to the team, Benoit!
We know you'll do great things :).

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes 369 commits and 98
merged pull requests from 52 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Performance of --bisect has been significantly improved

RSpec has supported a `--bisect` feature since
[RSpec 3.3](/blog/2015/06/rspec-3-3-has-been-released/#core-bisect).
This feature is useful when your test suite has an ordering
dependency--that is, the suite only fails when the tests are run
in a specific order. `--bisect` will repeatedly run smaller and
smaller subsets of your suite in order to narrow it down to the
minimal set of specs needed to reproduce the failures.

Since 3.3, this feature has been implemented by shelling out to
the `rspec` command to run each subset. While simple and effective,
we realized this approach was also quite inefficient. Each time the
`rspec` command runs, it must boot RSpec and your application
environment (which may include Rails and many other gems) from scratch.
The cost of this can vary considerably from a couple hundred milliseconds
to 30+ seconds on a large Rails app. In extreme cases, the runtime of
`--bisect` can be dominated by the time it takes to boot your application
environment over and over and over.

In RSpec 3.8, we've improved bisect's performance by using forking
on platforms that support it rather than shelling out. That way, we
can boot your application environment _once_, and then fork a subprocess
in which to run each subset of the test suite, avoiding the need to boot
your application many times.

The actual improvement you'll see in practice will vary widely, but
in our [limited testing](https://github.com/rspec/rspec-core/pull/2511)
it improved the runtime of `--bisect` by 33% in one case and an
order-of-magnitude (108.9 seconds down to 11.7 seconds) in another.

If you're looking to maximize the benefit of this change, you may
want to pass some additional `--require` options when running a
bisection in order to pre-load as much of your application environment
as possible.

### Core: Support the XDG base directory spec for configuration

RSpec, like many command line tools, supports the use of options
files, which can live at `.rspec` (for team project options)
`~/.rspec` (for global personal options) or at `.rspec-local`
(for personal project options -- this file should not be under
source control). In RSpec 3.8, we've expanded this feature to
support the [XDG Base Directory
Specification](https://specifications.freedesktop.org/basedir-spec/latest/),
which defines a standard way for tools to locate the global personal
options file. This gives users complete control over where this
file is located rather than forcing it to live in their home directory.

To use this feature, simply set the `$XDG_CONFIG_HOME` environment
variable and put your RSpec options at `$XDG_CONFIG_HOME/rspec/options`.

For more info, [read the spec](https://specifications.freedesktop.org/basedir-spec/latest/)
or [check out the pull
request](https://github.com/rspec/rspec-core/pull/2538).

Thanks to Magnus Bergmark for implementing this feature!

### Expectations: Formatted output length is now configurable

When setting expectations on large objects their string representations can become
rather unwieldy and can clutter the console output. In RSpec 3.6, we started
truncating these objects to address this issue, but did not make it easily configurable.

In RSpec 3.8, you can now configure it:

~~~ ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.max_formatted_output_length = 200
  end
end
~~~

You can also disable the truncation entirely by setting the config option to `nil`.

### Rails:  `have_http_status` matcher upgraded to support Rails 5.2

A change in Rails 5.2 caused RSpec's `have_http_status` matcher to issue deprecation
warnings. In RSpec 3.9, these warnings have been removed.

### Rails: View specs `stub_template` performance improved.

Thanks to Simon Coffey for implementing caching for `stub_template`
that prevents unnecessary recreation of templates. This improves performance
by reducing the amount of allocation and setup performed.

### Rails: `rails_helper.rb` improvements

Thank you to Koichi ITO and Alessandro Rodi for improving our generated
`rails_helper.rb` with improved messages when migrations are pending,
and bringing us in line with Rails standards.

## Stats:

### Combined:

* **Total Commits**: 369
* **Merged pull requests**: 98
* **52 contributors**: Ace Dimasuhid, Alessandro Rodi, Alexander
Panasyuk, Alyssa Ross, Andrew, Andrew Vit, Benoit Tigeot, Brad Charna,
Brian Kephart, Christophe Bliard, Craig J. Bass, Daniel Colson, Douglas
Lovell, Eric Hayes, Garett Arrowood, Gary Bernhardt, Gustav Munkby,
James Crisp, Joel Taylor, Jon Rowe, Kenichi Kamiya, Koichi ITO, Lairan,
Laura Paakkinen, Laurent Cobos, Magnus Bergmark, Matt Brictson, Maxim
Krizhanovsky, Myron Marston, Nikola Đuza, Oleg Pudeyev, Olivier Lacan,
Olle Jonsson, Pablo Brasero, Paul McMahon, Regan Chan, Sam Phippen,
Sergiy Yarinovskiy, Shane Cavanaugh, Shia, Simon Coffey, Sorah Fukumori,
Systho, Szijjártó-Nagy Misu, Tom Chen, Xavier Shay, Yuji Nakayama,
arjan0307, joker1007, lsarni, n.epifanov, pavel

### rspec-core:

* **Total Commits**: 94
* **Merged pull requests**: 24
* **17 contributors**: Alyssa Ross, Andrew Vit, Benoit Tigeot, Garett
Arrowood, Gary Bernhardt, Jon Rowe, Kenichi Kamiya, Koichi ITO, Magnus
Bergmark, Myron Marston, Oleg Pudeyev, Olle Jonsson, Sam Phippen, Sorah
Fukumori, Systho, Xavier Shay, arjan0307

### rspec-expectations:

* **Total Commits**: 52
* **Merged pull requests**: 15
* **13 contributors**: Ace Dimasuhid, Alyssa Ross, Benoit Tigeot, James
Crisp, Jon Rowe, Kenichi Kamiya, Myron Marston, Pablo Brasero, Sam
Phippen, Xavier Shay, Yuji Nakayama, joker1007, n.epifanov

### rspec-mocks:

* **Total Commits**: 47
* **Merged pull requests**: 16
* **13 contributors**: Alexander Panasyuk, Alyssa Ross, Andrew, Benoit
Tigeot, James Crisp, Jon Rowe, Kenichi Kamiya, Maxim Krizhanovsky, Myron
Marston, Olle Jonsson, Sam Phippen, Sergiy Yarinovskiy, Xavier Shay

### rspec-rails:

* **Total Commits**: 132
* **Merged pull requests**: 27
* **29 contributors**: Alessandro Rodi, Benoit Tigeot, Brad Charna,
Brian Kephart, Christophe Bliard, Daniel Colson, Douglas Lovell, Eric
Hayes, Joel Taylor, Jon Rowe, Kenichi Kamiya, Koichi ITO, Lairan, Laura
Paakkinen, Laurent Cobos, Matt Brictson, Myron Marston, Nikola Đuza,
Olivier Lacan, Paul McMahon, Regan Chan, Sam Phippen, Shane Cavanaugh,
Shia, Simon Coffey, Szijjártó-Nagy Misu, Tom Chen, lsarni, pavel

### rspec-support:

* **Total Commits**: 44
* **Merged pull requests**: 16
* **10 contributors**: Alyssa Ross, Benoit Tigeot, Craig J. Bass, Gustav
Munkby, James Crisp, Jon Rowe, Kenichi Kamiya, Myron Marston, Sam
Phippen, Xavier Shay

## Docs

### API Docs

* [rspec-core](/documentation/3.8/rspec-core/)
* [rspec-expectations](/documentation/3.8/rspec-expectations/)
* [rspec-mocks](/documentation/3.8/rspec-mocks/)
* [rspec-rails](/documentation/3.8/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core-3.8.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.7.1...v3.8.0)

Enhancements:

* Improve shell escaping used by `RSpec::Core::RakeTask` and `--bisect` so
  that it works on `Pathname` objects. (Andrew Vit, #2479)
* Nicely format errors encountered while loading files specified
  by `--require` option.  (Myron Marston, #2504)
* Significantly improve the performance of `--bisect` on platforms that
  support forking by replacing the shell-based runner with one that uses
  forking so that RSpec and the application environment can be booted only
  once, instead of once per spec run. (Myron Marston, #2511)
* Provide a configuration API to pick which bisect runner is used for
  `--bisect`. Pick a runner via `config.bisect_runner = :shell` or
  `config.bisect_runner = :fork` in a file loaded by a `--require`
  option passed at the command line or set in `.rspec`. (Myron Marston, #2511)
* Support the [XDG Base Directory
  Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
  for the global options file. `~/.rspec` is still supported when no
  options file is found in `$XDG_CONFIG_HOME/rspec/options` (Magnus Bergmark, #2538)
* Extract `RSpec.world.prepare_example_filtering` that sets up the
  example filtering for custom RSpec runners. (Oleg Pudeyev, #2552)

Bug Fixes:

* Prevent an `ArgumentError` when truncating backtraces with two identical
  backtraces. (Systho, #2515, Benoit Tigeot, #2539)


### rspec-expectations-3.8.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.7.0...v3.8.0)

Enhancements:

* Improve failure message of `change(receiver, :message)` by including the
  receiver as `SomeClass#some_message`. (Tomohiro Hashidate, #1005)
* Improve `change` matcher so that it can correctly detect changes in
  deeply nested mutable objects (such as arrays-of-hashes-of-arrays).
  The improved logic uses the before/after `hash` value to see if the
  object has been mutated, rather than shallow duping the object.
  (Myron Marston, #1034)
* Improve `include` matcher so that pseudo-hash objects (e.g. objects
  that decorate a hash using a `SimpleDelegator` or similar) are treated
  as a hash, as long as they implement `to_hash`. (Pablo Brasero, #1012)
* Add `max_formatted_output_length=` to configuration, allowing changing
  the length at which we truncate large output strings.
  (Sam Phippen #951, Benoit Tigeot #1056)
* Improve error message when passing a matcher that doesn't support block
  expectations to a block based `expect`. (@nicktime, #1066)


### rspec-mocks-3.8.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.7.0...v3.8.0)

Bug Fixes:

* Issue error when encountering invalid "counted" negative message expectations.
  (Sergiy Yarinovskiy, #1212)
* Ensure `allow_any_instance_of` and `expect_any_instance_of` can be temporarily
  supressed. (Jon Rowe, #1228)
* Ensure `expect_any_instance_of(double).to_not have_received(:some_method)`
  fails gracefully (as its not supported) rather than issuing a `NoMethodError`.
  (Maxim Krizhanovsky, #1231)


### rspec-rails-3.8.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.7.2...v3.8.0)

Enhancements:

* Improved message when migrations are pending in the default `rails_helper.rb`
  (Koichi ITO, #1924)
* `have_http_status` matcher now supports Rails 5.2 style response symbols
  (Douglas Lovell, #1951)
* Change generated Rails helper to match Rails standards for Rails.root
  (Alessandro Rodi, #1960)
* At support for asserting enqueued jobs have no wait period attached.
  (Brad Charna, #1977)
* Cache instances of `ActionView::Template` used in `stub_template` resulting
  in increased performance due to less allocations and setup. (Simon Coffey, #1979)
* Rails scaffold generator now respects longer namespaces (e.g. api/v1/\<thing\>).
  (Laura Paakkinen, #1958)

Bug Fixes:

* Escape quotation characters when producing method names for system spec
  screenshots. (Shane Cavanaugh, #1955)
* Use relative path for resolving fixtures when `fixture_path` is not set.
  (Laurent Cobos, #1943)
* Allow custom template resolvers in view specs. (@ahorek, #1941)


### rspec-support-3.8.0
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.7.1...v3.8.0)

Bug Fixes:

* Order hash keys before diffing to improve diff accuracy when using mocked calls.
  (James Crisp, #334)

