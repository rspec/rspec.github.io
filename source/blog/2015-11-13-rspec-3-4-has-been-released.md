---
title: RSpec 3.4 has been released!
author: Myron Marston
---

RSpec 3.4 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using any RSpec 3 release, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over 500 commits and 160
merged pull requests from nearly 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

TODO

## Stats

### Combined:

* **Total Commits**: 502
* **Merged pull requests**: 163
* **48 contributors**: Aaron Kromer, Alex Dowad, Alex Egan, Alex Pounds, Andrew Horner, Ara Hacopian, Ashley Engelund (aenw / weedySeaDragon), Ben Woosley, Bradley Schaefer, Brian John, Bryce McDonnell, Chris Zetter, Dan Kohn, Dave Marr, Dennis Günnewig, Diego Carrion, Edward Park, Gavin Miller, Jack Scotti, Jam Black, Jamela Black, Jason Karns, Jon Moss, Jon Rowe, Leo Cassarani, Liz Rush, Marek Tuchowski, Max Meyer, Myron Marston, Nikki Murray, Pavel Pravosud, Sam Phippen, Sebastián Tello, Simon Coffey, Tim Mertens, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, Zshawn Syed, bennacer860, bootstraponline, draffensperger, georgeu2000, jackscotti, mrageh, rafik, takiy33, unmanbearpig

### rspec-core:

* **Total Commits**: 180
* **Merged pull requests**: 52
* **24 contributors**: Aaron Kromer, Alex Pounds, Ashley Engelund (aenw / weedySeaDragon), Ben Woosley, Bradley Schaefer, Brian John, Edward Park, Gavin Miller, Jack Scotti, Jon Moss, Jon Rowe, Leo Cassarani, Marek Tuchowski, Myron Marston, Sebastián Tello, Simon Coffey, Tim Mertens, Yuji Nakayama, bennacer860, bootstraponline, draffensperger, jackscotti, mrageh, takiy33

### rspec-expectations:

* **Total Commits**: 93
* **Merged pull requests**: 34
* **17 contributors**: Aaron Kromer, Alex Egan, Bradley Schaefer, Brian John, Dennis Günnewig, Jason Karns, Jon Moss, Jon Rowe, Max Meyer, Myron Marston, Nikki Murray, Sam Phippen, Xavier Shay, Yuji Nakayama, Zshawn Syed, mrageh, unmanbearpig

### rspec-mocks:

* **Total Commits**: 77
* **Merged pull requests**: 26
* **12 contributors**: Aaron Kromer, Alex Dowad, Alex Egan, Brian John, Bryce McDonnell, Jon Moss, Jon Rowe, Liz Rush, Myron Marston, Pavel Pravosud, Sam Phippen, georgeu2000

### rspec-rails:

* **Total Commits**: 97
* **Merged pull requests**: 31
* **16 contributors**: Aaron Kromer, Alex Egan, Ara Hacopian, Bradley Schaefer, Brian John, Chris Zetter, Dan Kohn, Dave Marr, Diego Carrion, Jam Black, Jamela Black, Jon Moss, Jon Rowe, Myron Marston, Nikki Murray, Wojciech Wnętrzak

### rspec-support:

* **Total Commits**: 55
* **Merged pull requests**: 20
* **10 contributors**: Aaron Kromer, Alex Egan, Andrew Horner, Bradley Schaefer, Brian John, Jon Rowe, Myron Marston, Xavier Shay, Yuji Nakayama, rafik

## Docs

### API Docs

* [rspec-core](/documentation/3.4/rspec-core/)
* [rspec-expectations](/documentation/3.4/rspec-expectations/)
* [rspec-mocks](/documentation/3.4/rspec-mocks/)
* [rspec-rails](/documentation/3.4/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core 3.4.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.3.2...v3.4.0)

Enhancements:

* Combine multiple `--pattern` arguments making them equivalent to
  `--pattern=1,2,...,n`. (Jon Rowe, #2002)
* Improve `inspect` and `to_s` output for `RSpec::Core::Example`
  objects, replacing Ruby's excessively verbose output. (Gavin Miller, #1922)
* Add `silence_filter_announcements` configuration option.
  (David Raffensperger, #2007)
* Add optional `example_finished` notification to the reporter protocol for
  when you don't care about the example outcome. (Jon Rowe, #2013)
* Switch `--bisect` to a recursion-based bisection algorithm rather than
  a permutation-based one. This better handles cases where an example
  depends upon multiple other examples instead of just one and minimizes
  the number of runs necessary to determine that an example set cannot be
  minimized further. (Simon Coffey, #1997)
* Allow simple filters (e.g. `:symbol` key only) to be triggered by truthey
  values. (Tim Mertens, #2035)
* Remove unneeded warning about need for `ansicon` on Windows when using
  RSpec's `--color` option. (Ashley Engelund, #2038)
* Add option to configure RSpec to raise errors when issuing warnings.
  (Jon Rowe, #2052)
* Append the root `cause` of a failure or error to the printed failure
  output when a `cause` is available. (Adam Magan)
* Stop rescuing `NoMemoryError`, `SignalExcepetion`, `Interrupt` and
  `SystemExit`. It is dangerous to interfere with these. (Myron Marston, #2063)
* Add `config.project_source_dirs` setting which RSpec uses to determine
  if a backtrace line comes from your project source or from some
  external library. It defaults to `spec`, `lib` and `app` but can be
  configured differently. (Myron Marston, #2088)
* Improve failure line detection so that it looks for the failure line
  in any project source directory instead of just in the spec file.
  In addition, if no backtrace lines can be found from a project source
  file, we fall back to displaying the source of the first backtrace
  line. This should virtually eliminate the "Unable to find matching
  line from backtrace" messages. (Myron Marston, #2088)
* Add support for `:extra_failure_lines` example metadata that will
  be appended to the failure output. (bootstraponline, #2092).
* Add `RSpec::Core::Example#duplicate_with` to produce new examples
  with cloned metadata. (bootstraponline, #2098)
* Add `RSpec::Core::Configuration#on_example_group_definition` to register
  hooks to be invoked when example groups are created. (bootstraponline, #2094)
* Add `add_example` and `remove_example` to `RSpec::Core::ExampleGroup` to
  allow  manipulating an example groups examples. (bootstraponline, #2095)
* Display multiline failure source lines in failure output when Ripper is
  available (MRI >= 1.9.2, and JRuby >= 1.7.5 && < 9.0.0.0.rc1).
  (Yuji Nakayama, #2083)
* Add `max_displayed_failure_line_count` configuration option
  (defaults to 10). (Yuji Nakayama, #2083)
* Enhance `fail_fast` option so it can take a number (e.g. `--fail-fast=3`)
  to force the run to abort after the specified number of failures.
  (Jack Scotti, #2065)
* Syntax highlight the failure snippets in text formatters when `color`
  is enabled and the `coderay` gem is installed on a POSIX system.
  (Myron Marston, #2109)

Bug Fixes:

* Lock `example_status_persistence_file` when reading from and writing
  to it to prevent race conditions when multiple processes try to use
  it. (Ben Woosley, #2029)
* Fix regression in 3.3 that caused spec file names with square brackets in
  them (such as `1[]_spec.rb`) to not be loaded properly. (Myron Marston, #2041)
* Fix output encoding issue caused by ASCII literal on 1.9.3 (Jon Rowe, #2072)
* Fix requires in `rspec/core/rake_task.rb` to avoid double requires
  seen by some users. (Myron Marston, #2101)

### rspec-expectations 3.4.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.3.1...v3.4.0)

Enhancements:

* Warn when `RSpec::Matchers` is included in a superclass after it has
  already been included in a subclass on MRI 1.9, since that situation
  can cause uses of `super` to trigger infinite recursion. (Myron Marston, #816)
* Stop rescuing `NoMemoryError`, `SignalExcepetion`, `Interrupt` and
  `SystemExit`. It is dangerous to interfere with these. (Myron Marston, #845)
* Add `#with_captures` to the
  [match matcher](https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers/match-matcher)
  which allows a user to specify expected captures when matching a regex
  against a string. (Sam Phippen, #848)
* Always print compound failure messages in the multi-line form. Trying
  to print it all on a single line didn't read very well. (Myron Marston, #859)

Bug Fixes:

* Fix failure message from dynamic predicate matchers when the object
  does not respond to the predicate so that it is inspected rather
  than relying upon it's `to_s` -- that way for `nil`, `"nil"` is
  printed rather than an empty string. (Myron Marston, #841)
* Fix SystemStackError raised when diffing an Enumerable object
  whose `#each` includes the object itself. (Yuji Nakayama, #857)

### rspec-mocks 3.4.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.3.2...v3.4.0)

Enhancements:

* Make `expect(...).to have_received` work without relying upon
  rspec-expectations. (Myron Marston, #978)
* Add option for failing tests when expectations are set on `nil`.
  (Liz Rush, #983)

Bug Fixes:

* Fix `have_received { ... }` so that any block passed when the message
  was received is forwarded to the `have_received` block. (Myron Marston, #1006)
* Fix infinite loop in error generator when stubbing `respond_to?`.
  (Alex Dowad, #1022)
* Fix issue with using `receive` on subclasses (at a class level) with 1.8.7.
  (Alex Dowad, #1026)

### rspec-rails 3.4.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.3.3...v3.4.0)

Enhancements:

* Improved the failure message for `have_rendered` matcher on a redirect
  response. (Alex Egan, #1440)
* Add configuration option to filter out Rails gems from backtraces.
  (Bradley Schaefer, #1458)
* Enable resolver cache for view specs for a large speed improvement
  (Chris Zetter, #1452)
* Add `have_enqueued_job` matcher for checking if a block has queued jobs.
  (Wojciech Wnętrzak, #1464)

Bug Fixes:

* Fix another load order issued which causes an undefined method `fixture_path` error
  when loading rspec-rails after a spec has been created. (Nikki Murray, #1430)
* Removed incorrect surrounding whitespace in the rspec-rails backtrace
  exclusion pattern for its own `lib` code. (Jam Black, #1439)

### rspec-support 3.4.0
[Full Changelog](http://github.com/rspec/rspec-support/compare/v3.3.0...v3.4.0)

Enhancements:

* Improve formatting of `Delegator` based objects (e.g. `SimpleDelgator`) in
  failure messages and diffs. (Andrew Horner, #215)
* Add `ComparableVersion`. (Yuji Nakayama, #245)
* Add `Ripper` support detection. (Yuji Nakayama, #245)

Bug Fixes:

* Work around bug in JRuby that reports that `attr_writer` methods
  have no parameters, causing RSpec's verifying doubles to wrongly
  fail when mocking or stubbing a writer method on JRuby. (Myron Marston, #225)

