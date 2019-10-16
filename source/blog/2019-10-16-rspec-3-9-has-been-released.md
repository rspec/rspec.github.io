---
title: RSpec 3.9 has been released, and RSpec team changes.
author: Jon Rowe
---

RSpec 3.9 has just been released! As the RSpec project follows
[semantic versioning](http://semver.org/), anyone already using RSpec 3
should be able to upgrade to this version seemlessly, but if we have
introduced a regression please let us know, and we'll get a patch
release out to sort it out as soon as possible.

We're sad to announce that [Penelope Phippen](https://github.com/samphippen) has
retired from the project, leaving myself, [Jon Rowe](https://github.com/jonrowe) as
the sole lead maintainer going forward, but its not all bad news, we welcome our
newest core team member [Phil Pirozhkov](https://github.com/pirj`).

Thank you Penelope for all your hard word over the years and welcome Phil!

This is the last release in which the RSpec gems, `rspec`, `rspec-core`,
`rspec-expectations` and `rspec-mocks` will be in sync with `rspec-rails`.
We'll be launched `rspec-rails` 4 soon which will be classed as an extension
gem and not kept in sync version wise with the core gems, which will allow
us to keep `rspec-rails` in sync with Rails versions, more on that soon.

RSpec continues to receive contributions from all over the world, we had
369 commits and 98 merged pull requests from 52 different contributors
who helped make this release happen. Thank you all :)

## Notable Changes

### Core: Improved error handling

If RSpec encounters an error whilst loading support files, it will now
skip loading specs files removing later confusing errors due to the earlier
error(s). Additionally when available `did_you_mean` suggestions will be
shown for any `LoadError`s that are encountered.

### Core: Command Line Interface improvement, `--example-matches`

With the release of 3.9 you can now use `--example-matches` to filter your
examples via a regular expression, useful if you only know part of an example
name or have specs with a common theme across a number of different files.

### Core: New Formatter

In 3.9 you will find a new built in formatter option, the failure list formatter,
which can be used via the command line as `--format f` or `--format failure_list`,
or via the `RSpec::Configuration#formatter` method. This new formatter produces
output in a more minimalist "quick fix" style output.

### Expectations: respond_to(:new)

The `respond_to` matcher now special cases `:new` and checks `:initialize`
if its a standard class method.

### Expectations: Empty diff warning

Prior to 3.9 when you had matchers that failed but the items under test
produced the same inspect output you'd get a confusing diff were both
sides look the same, we now detect this scenario and issue a warning.

### Mocks: Improved thread safety

A bonus for people running parralleised specs, 3.9 brings some improvements
to our threaded behaviour by adding mutexes to avoid deadlocking errors.

### Rails: `rails_helper.rb` improvements

A minor tweak in 3.9 brining the generated `rails_helper.rb` inline
with Ruby semantics and using `__dir__` rather than `__FILE__` on
newer Rubies.

### Rails: New email matchers

Add a new `have_enqueued_mail` matcher for making it easier to assert
on mailer specific active jobs.

### Rails: New generators

Version 3.9 brings a couple of new generator scaffolds, you can now
generate system specs on Rails 5.1 and above, generate specs for generators
and add routes when generating controller specs.

## Stats:

### Combined:

* **Total Commits**: 322
* **Merged pull requests**: 59
* **54 contributors**: Aaron Kromer, Alex Haynes, Alireza Bashiri, Andy Waite,
Benoit Tigeot, Bobby McDonald, Chris, Christophe Bliard, ConSou, David Rodríguez,
Douglas Lovell, Eito Katagiri, Emric, Fred Snyder, Giovanni Kock Bonetti, Grey
Baker, Jack Wink, Jamie English, Joel Lubrano, Jon Rowe, Juanito Fatas, Keiji,
Kevin, Kevin Kuchta, Kieran O'Grady, Kohei Sugi, Laura Paakkinen, Manuel
Schnitzer, Matijs van Zuijlen, Michel Ocon, Myron Marston, Nazar Matus, Nick
LaMuro, OKURA Masafumi, Olle Jonsson, Orien Madgwick, Patrick Boatner, Penelope
Phippen, Pete Johns, Phil Pirozhkov, Philippe Hardardt, Rafe Rosen, Romain Tartière,
Ryan Lue, Sam Joseph, Samuel Williams, Taichi Ishitani, Takumi Kaji,
Thomas Walpole, Tom Grimley, Viktor Fonic, Yoshimi, aymeric-ledorze, 三上大河

### rspec-core:

* **Total Commits**: 92
* **Merged pull requests**: 13
* **22 contributors**: Alex Haynes, Andy Waite, Benoit Tigeot, Chris, Christophe
Bliard, David Rodríguez, Jon Rowe, Juanito Fatas, Keiji, Matijs van Zuijlen,
Myron Marston, Nick LaMuro, Olle Jonsson, Orien Madgwick, Pete Johns,
Phil Pirozhkov, Philippe Hardardt, Romain Tartière, Sam Joseph, Samuel Williams,
Viktor Fonic, Yoshimi

### rspec-expectations:

* **Total Commits**: 60
* **Merged pull requests**: 7
* **15 contributors**: Benoit Tigeot, Eito Katagiri, Fred Snyder, Jack Wink,
Jamie English, Jon Rowe, Juanito Fatas, Matijs van Zuijlen, Myron Marston,
Nazar Matus, Olle Jonsson, Orien Madgwick, Pete Johns, Phil Pirozhkov,
Taichi Ishitani

### rspec-mocks:

* **Total Commits**: 38
* **Merged pull requests**: 2
* **10 contributors**: Alireza Bashiri, Benoit Tigeot, Jon Rowe, Juanito Fatas,
Kevin, Matijs van Zuijlen, Myron Marston, Olle Jonsson, Orien Madgwick,
Patrick Boatner

### rspec-rails:

* **Total Commits**: 103
* **Merged pull requests**: 17
* **27 contributors**: Aaron Kromer, Benoit Tigeot, Bobby McDonald, ConSou,
Douglas Lovell, Emric, Giovanni Kock Bonetti, Grey Baker, Joel Lubrano, Jon Rowe,
Kevin Kuchta, Kieran O'Grady, Kohei Sugi, Laura Paakkinen, Manuel Schnitzer,
Michel Ocon, Myron Marston, OKURA Masafumi, Olle Jonsson, Orien Madgwick,
Penelope Phippen, Rafe Rosen, Ryan Lue, Takumi Kaji, Thomas Walpole, Tom Grimley,
aymeric-ledorze

### rspec-support:

* **Total Commits**: 29
* **Merged pull requests**: 20
* **4 contributors**: Benoit Tigeot, Jon Rowe, Myron Marston, 三上大河

## Docs

### API Docs

* [rspec-core](/documentation/3.9/rspec-core/)
* [rspec-expectations](/documentation/3.9/rspec-expectations/)
* [rspec-mocks](/documentation/3.9/rspec-mocks/)
* [rspec-rails](/documentation/3.9/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core-3.9.0
[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.8.2...v3.9.0)

Enhancements:
* Improve the handling of errors during loading support files, if a file
  errors before loading specs, RSpec will now skip loading the specs.
  (David Rodríguez, #2568)
* Add support for --example-matches to run examples by regular expression.
  (Sam Joseph, Matt Rider, @okothkongo1, #2586)
* Add `did_you_mean` suggestions for file names encountering a `LoadError`
  outside of examples. (@obromios, #2601)
* Add a minimalist quick fix style formatter, only outputs failures as
  `file:line:message`. (Romain Tartière, #2614)
* Convert string number values to integer when used for `RSpec::Configuration#fail_fast`
  (Viktor Fonic, #2634)
* Issue warning when invalid values are used for `RSpec::Configuration#fail_fast`
  (Viktor Fonic, #2634)
* Add support for running the Rake task in a clean environment.
  (Jon Rowe, #2632)
* Indent messages by there example group / example in the documentation formatter.
  (Samuel Williams, #2649)


### rspec-expectations-3.9.0
[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.8.5...v3.9.0)

Enhancements:

* The `respond_to` matcher now uses the signature from `initialize` to validate checks
  for `new` (unless `new` is non standard). (Jon Rowe, #1072)
* Generated descriptions for matchers now use `is expected to` rather than `should` in
  line with our preferred DSL. (Pete Johns, #1080, rspec/rspec-core#2572)
* Add the ability to re-raise expectation errors when matching
  with `match_when_negated` blocks. (Jon Rowe, #1130)
* Add a warning when an empty diff is produce due to identical inspect output.
  (Benoit Tigeot, #1126)


### rspec-mocks-3.9.0
[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.8.2...v3.9.0)

Enhancements:

* Improve thread safety of message expectations by using Mutex to prevent
  deadlocking errors. (Ry Biesemeyer, #1236)
* Add the ability to use `time` as an alias for `times`. For example:
  `expect(Class).to receive(:method).exactly(1).time`.
  (Pistos, Benoit Tigeot, #1271)


### rspec-rails-3.9.0
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.8.2...v3.9.0)

Enhancements

* Use `__dir__` instead of `__FILE__` in generated `rails_helper.rb` where
  supported. (OKURA Masafumi, #2048)
* Add `have_enqueued` matcher as a "super" matcher to the `ActiveJob` matchers
  making it easier to match on `ActiveJob` delivered emails. (Joel Lubrano, #2047)
* Add generator for system specs on Rails 5.1 and above. (Andrzej Sliwa, #1933)
* Add generator for generator specs. (@ConSou, #2085)
* Add option to generate routes when generating controller specs. (David Revelo, #2134)

Bug Fixes:

* Make the `ActiveJob` matchers fail when multiple jobs are queued for negated
  matches. e.g. `expect { job; job; }.to_not have_enqueued_job.
  (Emric Istanful, #2069)
