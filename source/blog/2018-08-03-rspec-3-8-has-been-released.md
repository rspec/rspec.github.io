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
from all over the world. This release includes over xxx commits and yyy
merged pull requests from zzz different contributors!

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

TODO: generate

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

## Release notes:

TODO: generate
