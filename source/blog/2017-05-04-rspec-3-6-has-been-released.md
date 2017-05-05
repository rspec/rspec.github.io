---
title: RSpec 3.6 has been released!
author: Sam Phippen
---

RSpec 3.6 has just been released! Given our commitment to
[semantic versioning](http://semver.org/), this should be an easy
upgrade for anyone already using RSpec 3, but if we did introduce
any regressions, please let us know, and we'll get a patch release
out with a fix ASAP.

RSpec continues to be a community-driven project with contributors
from all over the world. This release includes over XXX commits and YYY
merged pull requests from over ZZZ different contributors!

Thank you to everyone who helped make this release happen!

## Notable Changes

### Core: Errors outside examples now handled and formatted well

In previous versions of RSpec, we allowed errors encountered while loading spec
files or running `:suite` hooks to crash the ruby interpreter, giving you its
default full-stacktrace output.  In RSpec 3.6, we now handle all errors that
occur outside examples, and format them nicely including a filtered backtrace
and a code snippet for the site of the error.  For example, an error in a
`before(:suite)` hook is now formatted like this:

<img alt="Errors outside example execution"
src="/images/blog/errors_outside_example.png">

Thanks to Jon Rowe for assisting with this feature.

### Core: Output coloring is set automatically if RSpec is outputting to a tty.

In past versions of RSpec, you were required to specify `--color` if you wanted
output coloring, regardless of whether you were outputting to a terminal, a
file, a CI system, or some other output location. Now, RSpec will automatically
color output if it detects it is running in a TTY. You can still force coloring
with `--color`, or if you are running in a TTY and explicitly do not want color,
you can specify `--no-color` to disable this behavior.

We thank Josh Justice for adding this behavior to RSpec.

### Core: `config.fail_if_no_examples`

As it currently stands RSpec will exit with code `0` indicating success if no
examples are defined. This option allows you to configure RSpec to exit with
code `1` indicating failure. This is useful in CI environments, as it helps
detect when you've misconfigured RSpec to look for specs in the wrong place or
with the wrong pattern. When no specs are found and `config.fail_if_no_examples`
is set we consider this to be an error as opposed to passing the suite run.

~~~ ruby
RSpec.configure do |config|
  config.fail_if_no_examples = true
end
~~~

A special thanks to Ewa Czechowska for getting this in to core.

### Expectations: Improved failure messages for the `change` and `satisfy` matchers

The `change` and `satisfy` matchers both accept a block. For the
`change` matcher, you use this to specify _what_ you expect to change.
For the `satisfy` matcher you use a block to specify your pass/fail
criteria.  In either case, the failure message has always been pretty
generic.  For example, consider these specs:

~~~ ruby
RSpec.describe "`change` and `satisfy` matchers" do
  example "`change` matcher" do
    a = b = 1

    expect {
      a += 1
      b += 2
    }.to change { a }.by(1)
    .and change { b }.by(1)
  end

  example "`satisfy` matcher" do
    expect(2).to satisfy { |x| x.odd? }
            .and satisfy { |x| x.positive? }
  end
end
~~~

Prior versions of RSpec would fail with messages like
"expected result to have changed by 1, but was changed by 2"
and "expected 2 to satisfy block".  In both cases, the failure
message is accurate, but does not help you distinguish _which_
`change` or `satisfy` matcher failed.

Here's what the failure output looks like on RSpec 3.6:

~~~
Failures:

  1) `change` and `satisfy` matchers `change` matcher
     Failure/Error:
       expect {
         a += 1
         b += 2
       }.to change { a }.by(1)
       .and change { b }.by(1)

       expected `b` to have changed by 1, but was changed by 2
     # ./spec/example_spec.rb:5:in `block (2 levels) in <top (required)>'

  2) `change` and `satisfy` matchers `satisfy` matcher
     Failure/Error:
       expect(2).to satisfy { |x| x.odd? }
               .and satisfy { |x| x.positive? }

       expected 2 to satisfy expression `x.odd?`
     # ./spec/example_spec.rb:13:in `block (2 levels) in <top (required)>'
~~~

Thanks to the great work of Yuji Nakayama, RSpec now uses
[Ripper](http://ruby-doc.org/stdlib-2.4.0/libdoc/ripper/rdoc/Ripper.html)
to extract a snippet to include in the failure message. If we're not
able to extract a simple, single-line snippet, we fall back to the older
generic messages.

### Expectations: Scoped aliased and negated matchers

In RSpec 3, we added `alias_matcher`, allowing users to 
[alias matchers](http://rspec.info/blog/2014/01/new-in-rspec-3-composable-matchers/#matcher-aliases) 
for better readability. In 3.1 we added the ability to define
[negated matchers](http://rspec.info/blog/2014/09/rspec-3-1-has-been-released/#expectations-new-definenegatedmatcher-api)
with the `define_negated_matcher` method.

Before RSpec 3.6 when you called either of these methods the newly defined
matchers were always defined at the global scope. With this feature you are able
to invoke either `alias_matcher` or `define_negated_matcher` in the scope of an
example group (`describe`, `context`, etc). When doing so the newly defined
matcher will only be available to examples in that example group and any nested
groups:

~~~ ruby
RSpec.describe 'scoped matcher aliases' do
  describe 'example group with a matcher alias' do
    alias_matcher :be_a_string_starting_with, :start_with

    it 'can use the matcher alias' do
      expect('a').to be_a_string_starting_with('a')
    end
  end

  describe 'example group without the matcher alias' do
    it 'cannot use the matcher alias' do
      # fails because the matcher alias is not available
      expect('a').to be_a_string_starting_with('a')
    end
  end
end
~~~

Thanks to Markus Reiter for contributing this feature.

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
    without_partial_double_verification do
      w = Widget.new
      allow(w).to receive(:call).with(1, 2).and_return(3)
      w.call(1, 2)
    end
  end
end
~~~

Here, this test would fail if the `without_partial_double_verification` call was
not made, because we are stubbing the `call` method on the `Widget` object with
an argument count that is different from the implementation. We added this feature
specifically to address a problem with partial double verification when stubbing
locals in views. Details can be found in [this issue](https://github.com/rspec/rspec-mocks/issues/1102)
and the rspec-rails issues linked from it.

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
