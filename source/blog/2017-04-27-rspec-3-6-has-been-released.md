---
title: RSpec 3.6 has been released!
author: Sam Phippen, TODO: other editors
---

RSpec 3.6 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be an easy
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over XXX commits and YYY
merged pull requests from over 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Errors outside examples now handled and formatted well

In previous versions of RSpec, we allowed errors encountered while loading spec
files or running `:suite` hooks to crash the ruby interpreter, giving you its
default full-stacktrace output.  In RSpec 3.6, we now handle all errors that
occur outside examples, and format them nicely including a filtered backtrace
and a code snippet for the site of the error.  For example, an error in a
`before(:suite)` hook is now formatted like this:

<img width="479" alt="screen shot 2017-04-27 at 9 59 12 pm"
src="https://cloud.githubusercontent.com/assets/49391/25514870/cb9db6c8-2b94-11e7-952f-f26fd783512b.png">

Thanks to Jon Rowe for assisting with this feature.

### Core: `config.fail_if_no_examples`

As it currently stands RSpec will exit with code `0` indicating success if no
examples are defined. This configuration option makes it possible to cause RSpec
to exit with code `1` indicating failure. This is useful in CI environments, it
helps detect when you've misconfigured RSpec to look for specs in the wrong
place or with the wrong pattern. When this occurs we consider finding no specs
to being an error, as opposed to always passing.

~~~ ruby
RSpec.configure do |config|
  config.fail_if_no_examples = true
end
~~~

A special thanks to Ewa Czechowska for getting this in to core.

### Core: Output coloring is set automatically if RSpec is outputting to a tty.

In past versions of RSpec, you were required to specify `--color` if you wanted
output coloring, regardless of whether you were outputting to a terminal, a
file, a CI system, or some other output location. Now, RSpec will automatically
color output if it detects it is running in a TTY. You can still force coloring
with `--color`, or if you are running in a TTY and explicitly do not want color,
you can specify `--no-color` to disable this behavior.

For existing RSpec projects, that were initialized with either `bundle exec
rspec --init` or `bundle exec rails g rspec:install` you can find this setting
in your `.rspec` file if you'd like to change it.

We thank Josh Justice for adding this behavior to RSpec.

### Expectations: Scoped aliased and negative matchers

TODO: is anyone more familiar with this feature who could full this out?

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
    without_partial_double_verification {
      w = Widget.new
      allow(w).to receive(:call).with(1, 2).and_return(3)
      w.call(1, 2)
    }
  end
end
~~~

Here, this test would fail if the `without_partial_double_verification` call was
not made, because we are stubbing the `call` method on the `Widget` object with
an argument count that is different to the implementation. This can be useful in
situations where methods aren't already defined on the object, like in Rails,
when methods on `ActiveRecord` objects are defined after database interactions.
With this feature, we can test interfaces to those objects while retaining
database isolation.

A special thanks to Jon Rowe for adding this feature.

### Rails: Support for Rails 5.1:

RSpec 3.6.0 comes with full support for Rails 5.1. There are no major changes to
the rails 5.1 API and so this upgrade should be fully smooth. Simply bumping to
the latest version of RSpec will bring the support to your app with no other
changes required on your part.

Rails [system tests](http://weblog.rubyonrails.org/2017/4/27/Rails-5-1-final/) are not yet supported,
but we plan to add support for them in the near future.


## Stats:

TODO when ready to release
