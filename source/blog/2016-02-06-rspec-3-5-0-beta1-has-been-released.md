---
title: RSpec 3.5.0.beta1 has been released!
author: Sam Phippen
---

RSpec 3.5.0.beta1 has just been released! This is a big release for us because
it's the first release of RSpec we've published that has anything that could be
described as approximating support for Rails 5.

The purpose of this beta release is to enable people who are upgrading to Rails
5 to check their existing RSpec suites with Rails 5. If you do find any problems
with this release, let us know via GitHub, and we'll hopefully get everything
fixed in time for the Rails 5 release proper.

## Upgrading smoothly

As was discussed at Railsconf this year, Rails "soft deprecated" controller
tests in Rails 5. RSpec has been affected by being downstream of this, but
fortunately, we were able to make the process relatively smooth for our users.

If you have existing specs with `:type => :view` or `:type => :controller`
you'll need to add [the Rails Controller Testing Gem](https://github.com/rails/rails-controller-testing)
to your Gemfile. For the moment we recommend using the version from GitHub, but
we hope that there will be a stable version on Rubygems before Rails 5 is released
proper.

Gemfile example:

~~~ruby
source "https://rubygems.org"

gem "rails-controller-testing", :git => "https://github.com/rails/rails-controller-testing"
gem "rspec-rails", "3.5.0.beta1"
~~~

## Summing up

Since this is only a beta, I've kept this blog post nice and short. When 3.5.0
final is released we'll do a full post with much more detail. In the mean time,
there are a few people I'd like to say thanks to:

 * The entire RSpec core team for their continued work on the project
 * [Sean Griffin](https://twitter.com/sgrif), who personally spent a lot of time helping me with fixing up
   RSpec's compatability with Rails 5
 * [Andrew White](https://twitter.com/pixeltrix), who has also been helping me with RSpec's rails integration in
   the past few weeks.
 * [Cristiano Betta](https://twitter.com/cbetta) who quickly smoke tested the
   release against one of his rails apps for me.

This release was a huge amount of work for everyone involved, and I'm really
glad we're able to get you something to test against Rails 5 ahead of it's
release. We hope you enjoy, and do let us know if you've got any feedback on
this release.
