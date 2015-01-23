---
title: RSpec 2.99.0 and 3.0.0 have been released!
author: Myron Marston
---

RSpec 2.99.0 and 3.0.0 have been released! RSpec 3 has tons of [great new
features](/blog/2014/05/notable-changes-in-rspec-3). RSpec 2.99 is
part of the [recommended upgrade path](https://relishapp.com/rspec/docs/upgrade)
for projects currently on RSpec 2.x.

RSpec 3 is the work of many, many people, and it never would have happened without
the community contributing to it. Special thanks to:

* The RSpec core team: Aaron Kromer, Andy Lindeman, Bradley Schaefer, Jon Rowe, Sam Phippen and Xavier Shay.
  It's fantastic to work with all of you.
* Yuji Nakayama, for creating [transpec](http://yujinakayama.me/transpec/).
* The folks who stepped forward to maintain the extracted gems:
  * Peter Alfvin -- [rspec-its](https://github.com/rspec/rspec-its)
  * Hugo Baraúna -- [rspec-collection_matchers](https://github.com/rspec/rspec-collection_matchers)
  * Thomas Holmes -- [rspec-activemodel-mocks](https://github.com/rspec/rspec-activemodel-mocks)
  * Abdelkader Boudih -- [rspec-autotest](https://github.com/rspec/rspec-autotest)
* Everyone who contributed to RSpec 3. Their names are all listed below.
* Everyone who tried out the betas and the release candidate. Getting bug reports early,
  before 3.0 final was out, really helped us make it a solid release, so thank you.

## The numbers

I thought it'd be fun to extract some stats from the git logs to get an idea of how much work went into RSpec 3.
I put together a [rake task](https://github.com/rspec/rspec-dev/pull/71) to do this, and the raw numbers surprised me:

### Across all repos:

* **Total Commits**: 4069
* **Merged pull requests**: 882
* **122 contributors**: Aaron Blew, Aaron Kromer, AbuSabah, Adam Farhi, Adarsh Pandit, Adrian CB, Adrian Gonzalez, Alex Peattie, Alex Rothenberg, Alex Yaremyuk, Alexander Clark, Alexey Fedorov, Alexey Pisarenko, Andy Henson, Andy Lindeman, Andy Waite, Arthur Neves, Arthur Nogueira Neves, Ashish Dixit, Ben Hamill, Ben Hoskings, Ben Moss, Ben Orenstein, Billy, Bradley Schaefer, Brandon Turner, Brian Fontenot, Cezar Halmagean, Christof, Claudio B., Damian Galarza, Daniel Fone, Daniel Murphy, Darryl Pogue, David Chelimsky, David Dollar, David Long, Eloy Espinaco, Erik Michaels-Ober, Federico Ravasio, Florian Thomas, Fujimura Daisuke, Giovanni Cappellotto, Giuseppe Capizzi, Grant Hollingworth, Guilherme Carvalho, Hendy Tanata, Hugo Baraúna, Ivo Wever, Jakub Racek, Jared Norman, Jay Hayes, Jeff Wallace, Johannes / universa1, John Feminella, John Firebaugh, John Voloski, Jon Rowe, Jonathan del Strother, Josef Šimánek, Justin Coyne, Karthik Kastury, Katsuhiko Nishimra, Keiji, Kelly Stannard, Kenrick Chien, Lucas Mazza, Marc-Andre Lafortune, MasterLambaster, Matijs van Zuijlen, Matt Sanders, Matthew M. Boedicker, Mauricio Linhares, Michael Gee, Michael de Silva, Michi Huber, Myron Marston, Nerian, Nick DeLuca, Olle Jonsson, Oren Dobzinski, Paavo Leinonen, Parker Selbert, Paul Annesley, Pedro Gimenez, Pete Higgins, Peter Alfvin, Peter Inglesby, Postmodern, Prathamesh Sonpatki, Puneet Goyal, René Föhring, Reyes Yang, Rodrigo Rosenfeld Rosas, Ryo Nakamura, Salimane Adjao Moustapha, Sam Phippen, Sergey Pchelincev, Stephen Best, Steve Richert, Stuart Hicks, Tay Ray Chuan, Thijs Wouters, Thomas Drake-Brockman, Thomas Holmes, Thomas Stratmann, Tim Cowlishaw, Tim Watson, Tom Stuart, Tom Ward, Travis Herrick, Vinicius Horewicz, Vipul A M, Xavier Shay, Yoshimi, Yuji Nakayama, lucapette, maxlinc, modocache, sanemat, thepoho, vanstee

### rspec:

* **Total Commits**: 23
* **Merged pull requests**: 3
* **5 contributors**: Aaron Kromer, Andy Lindeman, Jon Rowe, Josef Šimánek, Myron Marston

### rspec-core:


* **Total Commits**: 1589
* **Merged pull requests**: 345
* **47 contributors**: Aaron Kromer, Adam Farhi, Adrian CB, Alex Peattie, Alexander Clark, Alexey Fedorov, Andy Lindeman, Arthur Neves, Ashish Dixit, Ben Hoskings, Ben Moss, Bradley Schaefer, David Chelimsky, David Dollar, Federico Ravasio, Giuseppe Capizzi, Jay Hayes, John Feminella, Jon Rowe, Karthik Kastury, Keiji, Kelly Stannard, MasterLambaster, Matijs van Zuijlen, Matthew M. Boedicker, Michael de Silva, Michi Huber, Myron Marston, Nerian, Parker Selbert, Pete Higgins, Peter Alfvin, Postmodern, René Föhring, Ryo Nakamura, Sam Phippen, Sergey Pchelincev, Steve Richert, Tay Ray Chuan, Thomas Stratmann, Tom Stuart, Travis Herrick, Vipul A M, Xavier Shay, Yoshimi, Yuji Nakayama, thepoho

### rspec-expectations:

* **Total Commits**: 924
* **Merged pull requests**: 191
* **41 contributors**: Aaron Kromer, Adam Farhi, Adrian Gonzalez, Alexey Pisarenko, Andy Henson, Andy Lindeman, Ben Moss, Ben Orenstein, Bradley Schaefer, Brandon Turner, Claudio B., Damian Galarza, Daniel Fone, Daniel Murphy, David Chelimsky, Eloy Espinaco, Erik Michaels-Ober, Federico Ravasio, Hendy Tanata, Hugo Baraúna, Ivo Wever, Jared Norman, Jeff Wallace, John Voloski, Jon Rowe, Katsuhiko Nishimra, Kenrick Chien, Myron Marston, Nerian, Pedro Gimenez, Pete Higgins, Prathamesh Sonpatki, René Föhring, Reyes Yang, Sam Phippen, Thijs Wouters, Thomas Holmes, Xavier Shay, Yuji Nakayama, lucapette, modocache

### rspec-mocks:

* **Total Commits**: 1036
* **Merged pull requests**: 249
* **36 contributors**: Aaron Kromer, Adarsh Pandit, Andy Lindeman, Arthur Nogueira Neves, Ashish Dixit, Ben Moss, Bradley Schaefer, Cezar Halmagean, David Chelimsky, Federico Ravasio, Grant Hollingworth, Guilherme Carvalho, Jon Rowe, Jonathan del Strother, Justin Coyne, Marc-Andre Lafortune, Mauricio Linhares, Michael Gee, Michi Huber, Myron Marston, Nick DeLuca, Oren Dobzinski, Paul Annesley, Pete Higgins, René Föhring, Sam Phippen, Stephen Best, Stuart Hicks, Thomas Holmes, Tim Cowlishaw, Tom Ward, Vinicius Horewicz, Xavier Shay, Yuji Nakayama, maxlinc, sanemat

### rspec-rails:

* **Total Commits**: 497
* **Merged pull requests**: 94
* **39 contributors**: Aaron Blew, Aaron Kromer, AbuSabah, Alex Rothenberg, Alex Yaremyuk, Andy Lindeman, Andy Waite, Ben Hamill, Billy, Bradley Schaefer, Brian Fontenot, Christof, Darryl Pogue, David Long, Florian Thomas, Fujimura Daisuke, Giovanni Cappellotto, Jakub Racek, Johannes / universa1, John Firebaugh, John Voloski, Jon Rowe, Lucas Mazza, Matt Sanders, Myron Marston, Olle Jonsson, Paavo Leinonen, Peter Inglesby, Puneet Goyal, René Föhring, Rodrigo Rosenfeld Rosas, Salimane Adjao Moustapha, Sam Phippen, Thomas Drake-Brockman, Thomas Holmes, Tim Watson, Xavier Shay, Yuji Nakayama, vanstee

## Release Notes

These are just the changelogs for what's changed since RC1. The full changelogs are available on github:

* [rspec-core](https://github.com/rspec/rspec-core/blob/master/Changelog.md)
* [rspec-expectations](https://github.com/rspec/rspec-expectations/blob/master/Changelog.md)
* [rspec-mocks](https://github.com/rspec/rspec-mocks/blob/master/Changelog.md)
* [rspec-rails](https://github.com/rspec/rspec-rails/blob/master/Changelog.md)

### rspec-core 2.99.0

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.99.0.rc1...v2.99.0)

Bug Fixes:

* Fix `BaseTextFormatter` so that it does not re-close a closed output
  stream. (Myron Marston)
* Use `RSpec::Configuration#backtrace_exclusion_patterns` rather than the
  deprecated `RSpec::Configuration#backtrace_clean_patterns` when mocking
  with rr. (David Dollar)

### rspec-core 3.0.0

[Full Changelog](http://github.com/rspec/rspec-core/compare/v3.0.0.rc1...v3.0.0)

Bug Fixes:

* Fix `BaseTextFormatter` so that it does not re-close a closed output
  stream. (Myron Marston)
* Fix regression in metadata that caused the metadata hash of a top-level
  example group to have a `:parent_example_group` key even though it has
  no parent example group. (Myron Marston)

Enhancements:

* Alter the default `spec_helper.rb` to no longer recommend
  `config.full_backtrace = true` see #1536 for discussion. (Jon Rowe)

### rspec-expectations 2.99.0

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.99.0.rc1...v2.99.0)

Enhancements:

* Special case deprecation message for `errors_on` with `rspec-rails` to be more useful.
  (Aaron Kromer)

### rspec-expectations 3.0.0

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v3.0.0.rc1...v3.0.0)

No code changes. Just taking it out of pre-release.

### rspec-mocks 2.99.0

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.99.0.rc1...v2.99.0)

No changes. Just taking it out of pre-release.

### rspec-mocks 3.0.0

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v3.0.0.rc1...v3.0.0)

Bug Fixes:

* Fix module prepend detection to work properly on ruby 2.0 for a case
  where a module is extended onto itself. (Myron Marston)
* Fix `transfer_nested_constants` option so that transferred constants
  get properly reset at the end of the example. (Myron Marston)
* Fix `config.transfer_nested_constants = true` so that you don't
  erroneously get errors when stubbing a constant that is not a module
  or a class. (Myron Marston)
* Fix regression that caused `double(:class => SomeClass)` to later
  trigger infinite recursion. (Myron Marston)
* Fix bug in `have_received(...).with(...).ordered` where it was not
  taking the args into account when checking the order. (Myron Marston)
* Fix bug in `have_received(...).ordered` where it was wrongly
  considering stubs when checking the order. (Myron Marston)
* Message expectation matchers now show descriptions from argument
  matchers when their expectations aren't met. (Jon Rowe)
* Display warning when encountering `TypeError` during instance method
  staging on 2.0.0-p195, suffers from https://bugs.ruby-lang.org/issues/8686
  too. (Cezar Halmagean).

### rspec-rails 2.99.0

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.99.0.rc1...v2.99.0)

No changes. Just taking it out of pre-release.

### rspec-rails 3.0.0

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.0.0.rc1...v3.0.0)

Enhancements:

* Separate RSpec configuration in generated `spec_helper` from Rails setup
  and associated configuration options. Moving Rails specific settings and
  options to `rails_helper`. (Aaron Kromer)

Bug Fixes:

* Fix an issue with fixture support when `ActiveRecord` isn't loaded. (Jon Rowe)

