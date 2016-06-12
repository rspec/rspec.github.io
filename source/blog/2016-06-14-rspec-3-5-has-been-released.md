---
title: RSpec 3.5 has been released!
author: Sam Phippen
---

RSpec 3.5 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over 450 commits and 150
merged pull requests from over 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: `config.when_first_matching_example_defined`

### Core: `config.filter_run_when_matching`

### Core: Load spec files in order specified at command line

### Core: Shared example group changes

### Expectations: Minitest integration now works with Minitest 5.6+

### Mocks: Add Minitest integration

### Rails: Support for Rails 5

The headline here is that RSpec 3.5.0 is compatible with Rails 5. As Rails 5
betas and release candidates have been released, we've been releasing betas of
3.5.0 to keep up alongside Rails. Due to this being a major release of Rails
some APIs that we consume have been deprecated. RSpec is not doing a major
release and so  this only gets exposed to you, our users, in one place:
controller testing.

In [Rails 5](https://github.com/rails/rails/issues/18950) `assigns` and
`assert_template` are "soft deprecated". Controller tests themselves *are not*,
and adding `:type => :controller` to your specs is still 100% supported.
Through Rails 3 and 4 it was both prevalent and idiomatic to use `assigns` in
controller specs. As this is a minor release of RSpec our commitment to SemVer
means that we are not going to break your existing controller specs. For
existing Rails applications that make heavy use of `assigns` adding the
[`rails-controller-testing`](https://github.com/rails/rails-controller-testing)
to your Gemfile will restore `assigns` and `assert_template`. RSpec integrates
with this gem seamlessly, so your controller specs should just continue to work.

For new Rails apps: we don't recommend adding the `rails-controller-testing` gem
to your application. The official recommendation of the Rails team and the RSpec
core team is to write  [request
specs](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec)
instead. Request specs allow you to focus on a single controller action, but
unlike controller tests involve the router, the middleware stack, and both rack
requests and responses. This adds realism to the test that you are writing, and
helps avoid many of the issues that are common in controller specs. In Rails 5,
request specs are significantly faster than either request or controller specs
were in rails 4, thanks to the work by [Eileen Uchitelle](https://twitter.com/eileencodes?lang=en-gb)[^foot_1] of the Rails Committer Team.

The other important feature of Rails 5 we wanted to discuss is ActionCable.
Unfortunately RSpec is not able to provide a simple testing story for
ActionCable at this time. Rails is working on a testing type for ActionCable
slated for release as part of Rails 5.1. We'll be watching that closely and work
something up when it's ready. In the mean time, we suggest you test ActionCable
through a browser, in an integrated fashion.

The work on Rails 5 represented a significant investment by a number of RSpec
Core Team members, and we received significant help from members of the Rails
Commiter and Core teams. We offer kind thanks to everyone that was involved with
making this possible.

## Stats

**TODO: regenerate this on day of release**

### Combined:

* **Total Commits**: 480
* **Merged pull requests**: 153
* **53 contributors**: Aaron Stone, Ahmed AbouElhamayed, Al Snow, Alex Altair, Alexander Skiba, Andrew Kozin (aka nepalez), Andrew White, Ben Saunders, Benjamin Quorning, Bradley Schaefer, Bruno Bonamin, David Rodríguez, Diogo Benicá, Eliot Sykes, Fernando Seror, Isaac Betesh, James Coleman, Joe Rafaniello, John Schroeder, Jon Moss, Jon Rowe, Jun Aruga, Kilian Cirera Sant, Koen Punt, Liss McCabe, Marc Ignacio, Martin Emde, Miklos Fazekas, Myron Marston, Patrik Wenger, Perry Smith, Peter Swan, Prem Sichanugrist, Rob, Ryan Beckman, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev, Thomas Hart II, Timo Schilling, Tobias Bühlmann, Travis Grathwell, William Jeffries, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama, Zshawn Syed, chrisarcand, liam-m, mrageh, sleepingkingstudios, yui-knk

### rspec-core:

* **Total Commits**: 133
* **Merged pull requests**: 45
* **14 contributors**: Alexander Skiba, Benjamin Quorning, Bradley Schaefer, Jon Moss, Jon Rowe, Myron Marston, Patrik Wenger, Perry Smith, Sam Phippen, Thomas Hart II, Travis Grathwell, Yuji Nakayama, mrageh, yui-knk

### rspec-expectations:

* **Total Commits**: 50
* **Merged pull requests**: 16
* **12 contributors**: Alex Altair, Ben Saunders, Benjamin Quorning, Bradley Schaefer, James Coleman, Jon Rowe, Myron Marston, Sam Phippen, William Jeffries, Yuji Nakayama, Zshawn Syed, chrisarcand

### rspec-mocks:

* **Total Commits**: 70
* **Merged pull requests**: 25
* **17 contributors**: Andrew Kozin (aka nepalez), Benjamin Quorning, Bradley Schaefer, Bruno Bonamin, David Rodríguez, Isaac Betesh, Joe Rafaniello, Jon Rowe, Kilian Cirera Sant, Marc Ignacio, Martin Emde, Myron Marston, Patrik Wenger, Ryan Beckman, Sam Phippen, Tobias Bühlmann, Yuji Nakayama

### rspec-rails:

* **Total Commits**: 157
* **Merged pull requests**: 44
* **27 contributors**: Ahmed AbouElhamayed, Al Snow, Andrew White, Benjamin Quorning, Bradley Schaefer, David Rodríguez, Diogo Benicá, Eliot Sykes, Fernando Seror, John Schroeder, Jon Rowe, Jun Aruga, Koen Punt, Liss McCabe, Miklos Fazekas, Myron Marston, Peter Swan, Prem Sichanugrist, Rob, Ryan Clark, Sam Phippen, Scott Bronson, Sergey Pchelintsev, Timo Schilling, Wojciech Wnętrzak, Xavier Shay, Yuji Nakayama

### rspec-support:

* **Total Commits**: 70
* **Merged pull requests**: 23
* **8 contributors**: Aaron Stone, Bradley Schaefer, Jon Rowe, Myron Marston, Sam Phippen, Yuji Nakayama, liam-m, sleepingkingstudios

## Docs

### API Docs

* [rspec-core](/documentation/3.5/rspec-core/)
* [rspec-expectations](/documentation/3.5/rspec-expectations/)
* [rspec-mocks](/documentation/3.5/rspec-mocks/)
* [rspec-rails](/documentation/3.5/rspec-rails/)

### Cucumber Features

* [rspec-core](http://relishapp.com/rspec/rspec-core)
* [rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

**TODO: fill this out on day of release**


## Footnotes

[^foot_1]: See also Eileen's [talk about request spec performance](https://www.youtube.com/watch?v=oT74HLvDo_A)
