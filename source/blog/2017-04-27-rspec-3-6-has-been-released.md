---
title: RSpec 3.6 has been released!
author: Sam Phippen, TODO: other editors
---

RSpec 3.6 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be a trivial
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over XXX commits and YYY
merged pull requests from over 50 different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Failure counts of errors occurring outside examples

In previous versions of RSpec, when errors occurred outside of examples, they
could potentially have side effects like preventing examples from running, or
stopping nested example groups from being defined. To help debug those issues,
RSpec now prints when those errors occur in the end of run summary, for
example:

~~~
Finished in 0.00033 seconds (files took 0.14097 seconds to load)
0 examples, 0 failures, 1 error occurred outside of examples
~~~

Special thanks to Jon Rowe for adding this feature.

### Core: `config.fail_if_no_examples`

As it currently stands RSpec will exit with code `0` indicating success if no
examples are defined. This configuration option makes it possible to cause RSpec
to exit with code `1` indicating failure, which is useful for CI environments.

~~~ ruby
RSpec.configure do |config|
  config.fail_if_no_examples = true
end
~~~

A special thanks to Ewa Czechowska for getting this in to core.

### Expectations: Scoped alised and negative matchers

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

here, this test would fail if the `without_partial_double_verification` call was
not made, because we are stubbing the `call` method on the `Widget` object
with an argument count that is different to the implementation.

A special thanks to Jon Rowe for adding this feature.

### Rails: Support for Rails 5.1:

RSpec 3.6.0 comes with full support for Rails 5.1. There are no major changes to
the rails 5.1 API and so this upgrade should be fully smooth. Simply bumping to
the latest version of RSpec will bring the support to your app with no other
changes required on your part


## Stats:

TODO when ready to release
