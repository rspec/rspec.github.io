---
layout: dev_post
title: RSpec 2.13 is released!
section: dev-blog
contents_class: medium-wide
---

I've just released RSpec 2.13. It's a minor release containing a few
backward-compatible enhancements and lots of bug fixes. It is a
recommended upgrade for all users.

Thanks to all the contributors who helped make this RSpec release happen.

## Notable New Features

### Profile more than 10 examples

RSpec has featured a `--profile` option for a long time. It dumps a
report of the 10 slowest examples. Now you can pass a numeric option
to have it print more than 10 examples.

To print off the 15 slowest examples, you could use:

{% codeblock %}
rspec --profile 15
{% endcodeblock %}

### `let` and `subject` declarations can use `super`

Users have requested this for a while. This allows to override a `let` or `subject`
declaration in a nested group while delegating to the original definition from the
parent group. Just use `super()`:

{% codeblock array_spec.rb %}
describe Array do
  let(:numbers) { [1, 2, 3, 4] }

  context "when evens are filtered out" do
    let(:numbers) { super().reject(&:even?) }
  end
end
{% endcodeblock array_spec.rb %}

Note that to use this feature, you _must_ use explicit parens
in the call to `super`; otherwise ruby will give you an ugly
`implicit argument passing of super from method defined by
define_method() is not supported` error.

### `be_within` matcher supports percent deltas

This is best illustrated by an example:

{% codeblock account_spec.rb %}
# The existing `be_within` matcher (which still works):
expect(account.balance).to be_within(10).of(500)

# Now you can do this, too:
expect(account.balance).to be_within(2).percent_of(500)
{% endcodeblock account_spec.rb %}

### `include` matcher can accept a list of matchers

This is handy when you want to verify something about the
items in a list rather that simply verifying the items' identity.

{% codeblock user_spec.rb %}
RSpec::Matchers.define :a_user_named do |name|
  match do |user|
    user.name == name
  end
end

expect(users).to include(a_user_named("Coen"), a_user_named("Daphne"))
{% endcodeblock user_spec.rb %}

## Docs

### RDoc

* [http://rubydoc.info/gems/rspec-core](http://rubydoc.info/gems/rspec-core)
* [http://rubydoc.info/gems/rspec-expectations](http://rubydoc.info/gems/rspec-expectations)
* [http://rubydoc.info/gems/rspec-mocks](http://rubydoc.info/gems/rspec-mocks)
* [http://rubydoc.info/gems/rspec-rails](http://rubydoc.info/gems/rspec-rails)

### Cucumber Features

* [http://relishapp.com/rspec/rspec-core](http://relishapp.com/rspec/rspec-core)
* [http://relishapp.com/rspec/rspec-expectations](http://relishapp.com/rspec/rspec-expectations)
* [http://relishapp.com/rspec/rspec-mocks](http://relishapp.com/rspec/rspec-mocks)
* [http://relishapp.com/rspec/rspec-rails](http://relishapp.com/rspec/rspec-rails)

## Release Notes

### rspec-core 2.13.0

[Full Changelog](http://github.com/rspec/rspec-core/compare/v2.12.2...v2.13.0)

Enhancements

* Allow `--profile` option to take a count argument that
  determines the number of slow examples to dump
  (Greggory Rothmeier).
* Add `subject!` that is the analog to `let!`. It defines an
  explicit subject and sets a `before` hook that will invoke
  the subject (Zubin Henner).
* Fix `let` and `subject` declaration so that `super`
  and `return` can be used in them, just like in a normal
  method. (Myron Marston)
* Allow output colors to be configured individually.
  (Charlie Maffitt)

Bug fixes

* Don't blow up when dumping error output for instances
  of anonymous error classes (Myron Marston).
* Fix default backtrace filters so lines from projects
  containing "gems" in the name are not filtered, but
  lines from installed gems still are (Myron Marston).
* Fix autotest command so that is uses double quotes
  rather than single quotes for windows compatibility
  (Jonas Tingeborn).
* Fix `its` so that uses of `subject` in a `before` or `let`
  declaration in the parent group continue to reference the
  parent group's subject. (Olek Janiszewski)

### rspec-expectations 2.13.0

[Full Changelog](http://github.com/rspec/rspec-expectations/compare/v2.12.1...v2.13.0)

Enhancements

* Add support for percent deltas to `be_within` matcher:
  `expect(value).to be_within(10).percent_of(expected)`
  (Myron Marston).
* Add support to `include` matcher to allow it to be given a list
  of matchers as the expecteds to match against (Luke Redpath).

Bug fixes

* Fix `change` matcher so that it dups strings in order to handle
  mutated strings (Myron Marston).
* Fix `should be =~ /some regex/` / `expect(...).to be =~ /some regex/`.
  Previously, these either failed with a confusing `undefined method
  matches?' for false:FalseClass` error or were no-ops that didn't
  actually verify anything (Myron Marston).
* Add compatibility for diff-lcs 1.2 and relax the version
  constraint (Peter Goldstein).
* Fix DSL-generated matchers to allow multiple instances of the
  same matcher in the same example to have different description
  and failure messages based on the expected value (Myron Marston).
* Prevent `undefined method #split for Array` error when dumping
  the diff of an array of multiline strings (Myron Marston).
* Don't blow up when comparing strings that are in an encoding
  that is not ASCII compatible (Myron Marston).
* Remove confusing "Check the implementation of #==" message
  printed for empty diffs (Myron Marston).

### rspec-mocks 2.13.0

[Full Changelog](http://github.com/rspec/rspec-mocks/compare/v2.12.2...v2.13.0)

Bug fixes

* Fix bug that caused weird behavior when a method that had
  previously been stubbed with multiple return values (e.g.
  `obj.stub(:foo).and_return(1, 2)`) was later mocked with a
  single return value (e.g. `obj.should_receive(:foo).once.and_return(1)`).
  (Myron Marston)
* Fix bug related to a mock expectation for a method that already had
  multiple stubs with different `with` constraints. Previously, the
  first stub was used, even though it may not have matched the passed
  args. The fix defers this decision until the message is received so
  that the proper stub response can be chosen based on the passed
  arguments (Myron Marston).
* Do not call `nil?` extra times on a mocked object, in case `nil?`
  itself is expected a set number of times (Myron Marston).
* Fix `missing_default_stub_error` message so array args are handled
  properly (Myron Marston).
* Explicitly disallow `any_instance.unstub!` (Ryan Jones).
* Fix `any_instance` stubbing so that it works with `Delegator`
  subclasses (Myron Marston).
* Fix `and_call_original` so that it works with `Delegator` subclasses
  (Myron Marston).
* Fix `any_instance.should_not_receive` when `any_instance.should_receive`
  is used on the same class in the same example. Previously it would
  wrongly report a failure even when the message was not received
  (Myron Marston).

### rspec-rails 2.13.0

[Full Changelog](http://github.com/rspec/rspec-rails/compare/v2.12.2...v2.13.0)

Enhancements

* `be_valid` matcher includes validation error messages. (Tom Scott)
* Adds cucumber scenario showing how to invoke an anonymous controller's
  non-resourceful actions. (Paulo Luis Franchini Casaretto)
* Null template handler is used when views are stubbed. (Daniel Schierbeck)
* The generated `spec_helper.rb` in Rails 4 includes a check for pending
  migrations. (Andy Lindeman)
* Adds `rake spec:features` task. (itzki)
* Rake tasks are automatically generated for each spec/ directory.
  (Rudolf Schmidt)

