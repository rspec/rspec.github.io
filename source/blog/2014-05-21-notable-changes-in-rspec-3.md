---
title: Notable Changes in RSpec 3
author: Myron Marston
---

Update: there's a [Japanese
translation](http://nilp.hatenablog.com/entry/2014/05/28/003335) of this
available now.

RSpec 3.0.0 RC1 was [released a couple days
ago](http://myronmars.to/n/dev-blog/2014/05/rspec-2-99-and-3-0-rc-1-have-been-released),
and 3.0.0 final is just around the corner.  We've been using the betas for the
last 6 months and we're excited to share them with you. Here's whats new:

## Across all gems

### Removed support for Ruby 1.8.6 and 1.9.1

These versions of Ruby were end-of-lifed long ago and
RSpec 3 does not support them.

### Improved Ruby 2.x support

Recent releases of RSpec 2.x (i.e. those that came out after
Ruby 2.0 was released) have officially supported Ruby 2, but RSpec 3's
support is greatly improved. We now provide support for working
with the new features of Ruby 2, like keyword arguments and prepended
modules.

### New rspec-support gem

[rspec-support](https://github.com/rspec/rspec-support) is a new gem
that we're using for common code needed by more than one of
rspec-(core|expectations|mocks|rails). It doesn't currently contain
any public APIs intended for use by end users or extension library
authors, but we may make some of its APIs public in the future.

If you run bleeding-edge RSpec by sourcing it from github in your
Gemfile, you'll need to start doing the same for rspec-support as well.

### Robust, well-tested upgrade process

Every breaking change in RSpec 3 has a corresponding deprecation warning in 2.99.
Throughout the betas we have done many upgrades to ensure this process is as
smooth as possible. We've put together [step by step upgrade
instructions](https://relishapp.com/rspec/docs/upgrade).

The upgrade process also highlights RSpec's new deprecation system
which is highly configurable (allowing you to output deprecations
into a file or turn all deprecations into errors) and is designed
to minimize duplicated deprecation output.

### Improved Docs

We've put a ton of effort into updating the API docs for all gems.
They're currently hosted on [rubydoc.info](http://rubydoc.info/):

* [rspec-core](http://rubydoc.info/github/rspec/rspec-core/frames)
* [rspec-expectations](http://rubydoc.info/github/rspec/rspec-expectations/frames)
* [rspec-mocks](http://rubydoc.info/github/rspec/rspec-mocks/frames)
* [rspec-rails](http://rubydoc.info/github/rspec/rspec-rails/frames)

...but we're currently working on updating [rspec.info](http://rspec.info/)
to self-host them.

While the docs are still a work-in-progress (and frankly, always will be),
we've made sure to explicitly declare all public APIs as part of
[SemVer](http://semver.org/) compliance. We're absolutely committed to
maintaining all public APIs through all 3.x releases. Private APIs, on
the other hand, are labeled as such because we specifically want to
reserve the flexibility to change them willy nilly in any 3.x release.

Please do not use APIs we've declared private. If you find yourself
with a need not addressed by the existing public APIs, please ask.
We'll gladly either make a private API public for your needs
or add a new API to meet your use case.

### Gems are now signed

We've started signing our gem releases. While the current gem signing
system is far from ideal, and [a better
solution](http://corner.squareup.com/2013/12/securing-rubygems-with-tuf-part-1.html)
is being developed, it's better than nothing. We've put our public cert on
[GitHub](https://github.com/rspec/rspec/blob/master/certs/rspec.pem).

For more details on the current gem signing system, see [A Practical
Guide to Using Signed Ruby
Gems](http://blog.meldium.com/home/2013/3/3/signed-rubygems-part).

### Zero monkey patching mode

RSpec can now be used without any monkey patching whatsoever.
Much of the groundwork for this was laid in recent 2.x releases
that added the new `expect`-based syntax to rspec-expectations
and rspec-mocks. We've gone the rest of the way in RSpec 3 and
provided alternatives for the remaining monkey patches.

For convenience you can disable all of the monkey patches with one option:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |c|
  c.disable_monkey_patching!
end
{% endcodeblock %}

Thanks to [Alexey Fedorov](https://github.com/waterlink) for
[implementing](https://github.com/rspec/rspec-core/pull/1465) this config option.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#disable_monkey_patching%21-instance_method)

## rspec-core

### New names for hook scopes: `:example` and `:context`

RSpec 2.x had three different hook scopes:

{% codeblock my_class_spec.rb %}
describe MyClass do
  before(:each) { } # runs before each example in this group
  before(:all)  { } # runs once before the first example in this group
end
{% endcodeblock %}

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |c|
  c.before(:each)  { } # runs before each example in the entire test suite
  c.before(:all)   { } # runs before the first example of each top-level group
  c.before(:suite) { } # runs once after all spec files have been loaded, before the first spec runs
end
{% endcodeblock %}

At times, users have expressed confusion around what `:each` vs `:all`
means, and `:all` in particular can be confusing when you use it in a
config block:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |c|
  c.before(:all) { }
end
{% endcodeblock %}

In this context, the term `:all` suggests that this hook will run once
before all examples in the suite — but that is what `:suite` is for.

In RSpec 3, `:each` and `:all` have aliases that make their scope
more explicit: `:example` is an alias of `:each` and `:context`
is an alias of `:all`. Note that `:each` and `:all` are _not_ deprecated
and we have no plans to do so.

Thanks to [John Feminella](https://github.com/fj) for
[implementing](https://github.com/rspec/rspec-core/pull/1174) this.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Hooks#before-instance_method)
* [rspec-core #297 - original discussion](https://github.com/rspec/rspec-core/pull/297)

### DSL methods yield the example as an argument

`RSpec::Core::Example` provides access to all the details about an
example: its description, location, metadata, execution result, etc.
In RSpec 2.x the example was exposed via an `example` method that could
be accessed from any hook or individual example:

{% codeblock my_class_spec.rb %}
describe MyClass do
  before(:each) { puts example.metadata }
end
{% endcodeblock %}

In RSpec 3, we've removed the `example` method. Instead, the example
instance is yielded to all example-scoped DSL methods as an explicit
argument:

{% codeblock my_class_spec.rb %}
describe MyClass do
  before(:example) { |ex| puts ex.metadata }
  let(:example_description) { |ex| ex.description }

  it 'accesses the example' do |ex|
    # use ex
  end
end
{% endcodeblock %}

Thanks to [David Chelimsky](https://github.com/dchelimsky) for coming up
with the idea and
[implementing](https://github.com/rspec/rspec-core/pull/666) it!

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Example)

### New `expose_dsl_globally` config option to disable rspec-core monkey patching

RSpec 2.x monkey patched `main` and `Module` to provide top level
methods like `describe`, `shared_examples_for` and `shared_context`:

{% codeblock my_gem_spec.rb %}
shared_examples_for "something" do
end

module MyGem
  describe SomeClass do
    it_behaves_like "something"
  end
end
{% endcodeblock %}

In RSpec 3, these methods are now also available on the `RSpec` module
(in addition to still being available as monkey patches):

{% codeblock my_gem_spec.rb %}
RSpec.shared_examples_for "something" do
end

module MyGem
  RSpec.describe SomeClass do
    it_behaves_like "something"
  end
end
{% endcodeblock %}

You can completely remove rspec-core's monkey patching (which
would make the first example above raise `NoMethodError`) by
setting the new `expose_dsl_globally` config option to `false`:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.expose_dsl_globally = false
end
{% endcodeblock %}

Thanks to [Jon Rowe](https://github.com/JonRowe) for
[implementing](https://github.com/rspec/rspec-core/pull/1036) this.

For more info:

* [Documentation](https://relishapp.com/rspec/rspec-core/v/3-0/docs/configuration/global-namespace-dsl)

### Define example group aliases with `alias_example_group_to`

In RSpec 2.x, we provided an API that allowed you to define `example`
aliases with attached metadata. For example, this is used internally to
define `fit` as an alias for `it` with `:focus => true` metadata:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.alias_example_to :fit, :focus => true
end
{% endcodeblock %}

In RSpec 3, we've extended this feature to example groups:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.alias_example_group_to :describe_model, :type => :model
end
{% endcodeblock %}

You could use this example in a project using rspec-rails and use
`describe_model User` rather than `describe User, :type => :model`.

Thanks to [Michi Huber](https://github.com/michihuber) for
[implementing](https://github.com/rspec/rspec-core/pull/1236) this.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#alias_example_group_to-instance_method)
* [rspec-core #493 - original discussion](https://github.com/rspec/rspec-core/issues/493)

### New example group aliases: `xdescribe`, `xcontext`, `fdescribe`, `fcontext`

Besides including an API to define example group aliases, we've also
included several additional built-in aliases (on top of `describe` and
`context`):

* `xdescribe`/`xcontext`, like `xit` for examples, can be used to temporarily skip an
  example group.
* `fdescribe`/`fcontext`, like `fit` for examples, can be used to temporarily add
  `:focus => true` metadata to an example group so that you can easily
  filter to the focused examples and groups via `config.filter_run :focus`.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/ExampleGroup)
* [rspec-core #1255 - implementation](https://github.com/rspec/rspec-core/pull/1255)

### Changes to `pending` semantics (and introduction of `skip`)

Pending examples are now run to check if they are actually passing. If
a pending block fails, then it will be marked pending as before. However, if
it succeeds it will cause a failure. This helps ensure that pending examples are
valid, and also that they are promptly dealt with when the behaviour they
describe is implemented.

To support the old "never run" behaviour, the `skip` method and metadata has
been added. None of the following examples will ever be run:

{% codeblock post_spec.rb %}
describe Post do
  skip 'not implemented yet' do
  end

  it 'does something', :skip => true do
  end

  it 'does something', :skip => 'reason explanation' do
  end

  it 'does something else' do
    skip
  end

  it 'does something else' do
    skip 'reason explanation'
  end
end
{% endcodeblock %}

With this change, passing a block to `pending` within an example no longer
makes sense, so that behaviour has been removed.

Thanks to [Xavier Shay](http://xaviershay.com) for
[implementing](https://github.com/rspec/rspec-core/pull/1267) this.

For more info:

* [Documentation](https://relishapp.com/rspec/rspec-core/v/3-0/docs/pending-and-skipped-examples)
* [rspec-core #1208 - original discussion](https://github.com/rspec/rspec-core/issues/1208)

### New API for one-liners: `is_expected`

RSpec has had a one-liner syntax for many years:

{% codeblock post_spec.rb %}
describe Post do
  it { should allow_mass_assignment_of(:title) }
end
{% endcodeblock %}

In this context, `should` is _not_ the monkey-patched `should`
that can be removed by configuring rspec-expectations to only
support the `:expect` syntax. It doesn't have the baggage that
monkey-patching `Object` with `should` brings, and is always
available regardless of your syntax configuration.

Some users have expressed confusion about how this `should` relates
to the `expect` syntax and if you can continue using it. It will continue
to be available in RSpec 3 (again, regardless of your syntax configuration),
but we've also added an alternate API that is a bit more consistent with
the `expect` syntax:

{% codeblock post_spec.rb %}
describe Post do
  it { is_expected.to allow_mass_assignment_of(:title) }
end
{% endcodeblock %}

`is_expected` is defined very simply as `expect(subject)` and also
supports negative expectations via `is_expected.not_to matcher`.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/MemoizedHelpers#is_expected-instance_method)
* [rspec-core #1180 - implementation](https://github.com/rspec/rspec-core/pull/1180)

### Example groups can be ordered individually

RSpec 2.8 introduced random ordering to RSpec, which is very useful for
surfacing unintentional ordering dependencies in your spec suite. In
RSpec 3, it's no longer an all-or-nothing feature. You can control how
individual example groups are ordered by tagging them with appropriate
metadata:

{% codeblock my_class_spec.rb %}
describe MyClass, :order => :defined do
  # examples in this group will always run in defined order,
  # regardless of any other ordering configuration.
end

describe MyClass, :order => :random do
  # examples in this group will always run in random order,
  # regardless of any other ordering configuration.
end
{% endcodeblock %}

This is particularly useful for migrating from defined to random
ordering, as it allows you to deal with ordering dependencies one-by-one
as you opt-in to the feature for particular groups rather than
having to solve the issues all at once.

As part of this we've also renamed `--order default` to `--order
defined`, because we realized that "default" was a highly overloaded
term.

Thanks to [Andy Lindeman](https://github.com/alindeman) and [Sam
Phippen](https://github.com/samphippen) for helping
[implement](https://github.com/rspec/rspec-core/pull/1025) this feature.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#register_ordering-instance_method)

### New ordering strategy API

In RSpec 3, we've overhauled the ordering strategy API. What used to be
[three](http://rubydoc.info/gems/rspec-core/2.14.8/RSpec/Core/Configuration:order_examples)
[different](http://rubydoc.info/gems/rspec-core/2.14.8/RSpec/Core/Configuration:order_groups)
[methods](http://rubydoc.info/gems/rspec-core/2.14.8/RSpec/Core/Configuration:order_groups_and_examples)
is now one method: `register_ordering`. Use it to define a named ordering
strategy:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.register_ordering(:description_length) do |list|
    list.sort_by { |item| item.description.length }
  end
end
{% endcodeblock %}

{% codeblock my_class_spec.rb %}
describe MyClass, :order => :description_length do
  # ...
end
{% endcodeblock %}

Or, you can use it to define the global ordering:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.register_ordering(:global) do |list|
    # sort them alphabetically
    list.sort_by { |item| item.description }
  end
end
{% endcodeblock %}

The `:global` ordering is used to order the top-level example groups
and to order all example groups that do not have `:order` metadata.

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#register_ordering-instance_method)
* [rspec-core #1025 - implementation](https://github.com/rspec/rspec-core/pull/1025)

### `rspec --init` improvements

The `rspec` command has provided the `--init` option to setup a project
skeleton for a long time. In RSpec 3, the files it produces have been
greatly improved to provide a better out-of-the-box experience and
to provide a `spec/spec_helper.rb` file with more recommended settings.

Note that recommended settings which are not slated to become future
defaults are commented out in the generated file, so it's a good idea
to open the file and accept the recommendations you want.

For more info:

* [rspec-core #1219 - implementation](https://github.com/rspec/rspec-core/pull/1219)

### New `--dry-run` CLI option

This option will print the formatter output of your spec suite
without running any of the examples or hooks. It's particularly
useful as way to review your suite's documentation output without
waiting for your specs to run or worrying about their pass/fail
status.

Thanks to [Thomas Stratmann](https://github.com/schnittchen) for
[contributing](https://github.com/rspec/rspec-core/pull/1028) this!

For more info:

* [Documentation](https://relishapp.com/rspec/rspec-core/v/3-0/docs/command-line/dry-run-option)
* [rspec-core #1022 - original discussion](https://github.com/rspec/rspec-core/issues/1022)

### Formatter API changes

A completely new formatter API has been added that is much more flexible.

* Subscribe only to the events you care about.
* Methods receive notification objects rather than specific parameters,
  so new notification data can be added in a backwards compatible manner.
* Helper methods are exposed on notification objects such that inheriting
  from `BaseTextFormatter` is no longer effectively necessary.

A new formatters looks like this:

{% codeblock custom_formatter.rb %}
class CustomFormatter
  RSpec::Core::Formatters.register self, :example_started

  def initialize(output)
    @output = output
  end

  def example_started(notification)
    @output << "example: " << notification.example.description
  end
end
{% endcodeblock %}

The [rspec-legacy_formatters
gem](https://github.com/rspec/rspec-legacy_formatters) is provided to continue
to support the old 2.x formatter API.

Thanks to [Jon Rowe](https://github.com/JonRowe) for taking charge of
this.

For more info:

* [Fivemat's RSpec 3 formatter (example of a full formatter implemenation)](https://github.com/tpope/fivemat/blob/3f4f550fa2852a34a020d31d834a7a3f0210b1ca/lib/fivemat/rspec3.rb)

### Assertion config changes

While most users use rspec-expectations, it's trivial to use something
else and RSpec 2.x made the most common alternate easily available via
a config option:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.expect_with :stdlib
  # or, to use both:
  config.expect_with :stdlib, :rspec
end
{% endcodeblock %}

However, there's been confusion around `:stdlib`. On Ruby 1.8, the
standard lib assertion module is `Test::Unit::Assertions`. On 1.9+ it's
a thin wrapper over `Minitest::Assertions` (and you're generally better
off using just that).  Meanwhile, there's also a test-unit gem
that defines `Test::Unit::Assertions` (which is _not_ a wrapper over
minitest) and a minitest gem.

For RSpec 3, we've removed `expect_with :stdlib` and instead opted
for explicit `:test_unit` and `:minitest` options:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  # for test-unit:
  config.expect_with :test_unit

  # for minitest:
  config.expect_with :minitest
end
{% endcodeblock %}

Thanks to [Aaron Kromer](http://aaronkromer.com/) for [implementing
this](https://github.com/rspec/rspec-core/pull/1466).

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#expect_with-instance_method)

### Define derived metadata

RSpec's metadata system is extremely flexible, allowing you to slice and
dice your test suite in many ways. There's a new config API that allows
you to define derived metadata. For example, to automatically tag all
example groups in `spec/acceptance/js` with `:js => true`:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.define_derived_metadata(:file_path => %r{/spec/acceptance/js/}) do |metadata|
    metadata[:js] = true
  end
end
{% endcodeblock %}

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration#define_derived_metadata-instance_method)
* [rspec-core #1496 - implementation](https://github.com/rspec/rspec-core/pull/1496)
* [rspec-core #969 - original discussion](https://github.com/rspec/rspec-core/issues/969)

### Removals

Several things that are no longer core to RSpec have either been removed
entirely or extracted into an external gem:

* The Textmate formatter has been moved into the [Textmate
  bundle](https://github.com/rspec/rspec-tmbundle).
  Having a formatter for one specific text editor in rspec-core doesn't
  really make sense.
* RCov integration has been dropped. It was never updated to work with
  1.9+ and these days we recommend using
  [simplecov](https://github.com/colszowka/simplecov) instead.
* The `--debug` CLI option has been removed. These days there are many
  different debugger options, and you can activate them from the command
  line using the `--require` (or `-r`) option. For example, to use
  [byebug](https://github.com/deivid-rodriguez/byebug), pass `-rbyebug`
  at the command line.
* We've removed the `--line-number` CLI option. It had dubious semantics
  to begin with (`--line-number 43` would filter to the example defined
  near line 43 in every loaded spec file, but there's no reason line 43 in
  each file would be related), and duplicates the more terse
  `path/to/spec.rb:43` form.
* `its` has been extracted into the new
  [rspec-its](https://github.com/rspec/rspec-its) gem, which
  [Peter Alfvin](https://github.com/palfvin) has kindly offered to maintain.
* Autotest integration has been extracted into the new new
  [rspec-autotest](https://github.com/rspec/rspec-autotest) gem (which
  could use a maintainer: any volunteers?).

## rspec-expectations

### Using `should` syntax without explicitly enabling it is deprecated

In RSpec 2.11 we started the move towards eliminating monkey patching
from RSpec by [introducing a new expect-based
syntax](http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax).
In RSpec 3, we've kept the `should` syntax, and it is available by
default, but you will get a deprecation warning if you use it without
explicitly enabling it. This will pave the way for it being disabled
by default (or potentially extracted into a seperate gem) in RSpec 4,
while minimizing confusion for newcomers coming to RSpec via an old tutorial.

We consider the `expect` syntax to be the "main" syntax of RSpec now,
but if you prefer the older `should`-based syntax, feel free to keep using it:
we have no plans to ever kill it.

Thanks to [Sam Phippen](https://github.com/samphippen) for
[implementing](https://github.com/rspec/rspec-expectations/pull/326)
this.

For more info:

* [Documentation](https://relishapp.com/rspec/rspec-expectations/v/3-0/docs/syntax-configuration)

### Compound Matcher Expressions

In RSpec 3, you can chain multiple matchers together using `and` or `or`:

{% codeblock compound_examples.rb %}
# these two expectations...
expect(alphabet).to start_with("a")
expect(alphabet).to end_with("z")

# ...can be combined into one expression:
expect(alphabet).to start_with("a").and end_with("z")

# You can also use `or`:
expect(stoplight.color).to eq("red").or eq("green").or eq("yellow")
{% endcodeblock %}

These are aliased to the `&` and `|` operators:

{% codeblock compound_operator_examples.rb %}
expect(alphabet).to start_with("a") & end_with("z")
expect(stoplight.color).to eq("red") | eq("green") | eq("yellow")
{% endcodeblock %}

Thanks to [Eloy Espinaco](https://github.com/eloyesp) for [suggesting and
implementing](https://github.com/rspec/rspec-expectations/pull/329)
this feature, and to [Adam Farhi](https://github.com/yelled3) for [extending
it](https://github.com/rspec/rspec-expectations/pull/537) with the `&` and `|` operators.

For more info:

* [New in RSpec 3: Composable Matchers](http://myronmars.to/n/dev-blog/2014/01/new-in-rspec-3-composable-matchers#compound_matcher_expressions)
* [Documentation](https://relishapp.com/rspec/rspec-expectations/v/3-0/docs/compound-expectations)

### Composable Matchers

RSpec 3 allows you to expressed detailed intent by passing matchers
as arguments to other matchers:

{% codeblock composed_matcher_examples.rb %}
s = "food"
expect { s = "barn" }.to change { s }.
  from( a_string_matching(/foo/) ).
  to( a_string_matching(/bar/) )

expect { |probe|
  "food".tap(&probe)
}.to yield_with_args( a_string_starting_with("f") )
{% endcodeblock %}

For improved readability in both the code expression and failure
messages, most matchers have aliases that read properly when
passed as arguments in these sorts of expressions.

For more info:

* [New in RSpec 3: Composable Matchers](http://myronmars.to/n/dev-blog/2014/01/new-in-rspec-3-composable-matchers)
* [rspec-expectations #280 - original discussion](https://github.com/rspec/rspec-expectations/issues/280)
* [rspec-expectations #393 - implementation](https://github.com/rspec/rspec-expectations/pull/393)
* [API Documentation (including list of matcher aliases)](http://rubydoc.info/github/rspec/rspec-expectations/RSpec/Matchers)
* [Relish Documentation](https://relishapp.com/rspec/rspec-expectations/v/3-0/docs/composing-matchers)

### `match` matcher can be used for data structures

Before RSpec 3, the `match` matcher existed to perform string/regex
matching using the `#match` method:

{% codeblock match_examples.rb %}
expect("food").to match("foo")
expect("food").to match(/foo/)
{% endcodeblock %}

In RSpec 3, it additionally supports matching arbitrarily nested
array/hash data structures. The expected value can be expressed
using matchers at any level of nesting:

{% codeblock match_data_structure_example.rb %}
hash = {
  :a => {
    :b => ["foo", 5],
    :c => { :d => 2.05 }
  }
}

expect(hash).to match(
  :a => {
    :b => a_collection_containing_exactly(
      an_instance_of(Fixnum),
      a_string_starting_with("f")
    ),
    :c => { :d => (a_value < 3) }
  }
)
{% endcodeblock %}

For more info:

* [New in RSpec 3: Composable Matchers](http://myronmars.to/n/dev-blog/2014/01/new-in-rspec-3-composable-matchers#match)

### New `all` matcher

This matcher lets you specify that something is true of all items in a
collection. Pass a matcher as an argument:

{% codeblock all_example.rb %}
expect([1, 3, 5]).to all( be_odd )
{% endcodeblock %}

Thanks to [Adam Farhi](https://github.com/yelled3) for
[contributing](https://github.com/rspec/rspec-expectations/pull/491) this!

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-expectations/RSpec/Matchers#all-instance_method)

### New `output` matcher

This matcher can be used to specify that a block writes to either stdout
or stderr:

{% codeblock output_examples.rb %}
expect { print "foo" }.to output("foo").to_stdout
expect { print "foo" }.to output(/fo/).to_stdout
expect { warn  "bar" }.to output(/bar/).to_stderr
{% endcodeblock %}

Thanks to [Matthias Günther](https://github.com/matthias-guenther) for
[suggesting](https://github.com/rspec/rspec-expectations/pull/399) this
(and for getting the ball rolling) and [Luca
Pette](https://github.com/lucapette) for [taking the feature
across the finish line](https://github.com/rspec/rspec-expectations/pull/410).

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-expectations/RSpec/Matchers#output-instance_method)

### New `be_between` matcher

RSpec 2 provided a `be_between` matcher for objects that implement
`between?` using the dynamic predicate support. In RSpec 3, we are
gaining a first class `be_between` matcher that is better in a few ways:

* The failure message is much better — rather than telling you that
  `between?(1, 10)` returned false, it will tell you `expected 11 to be
  between 1 and 10`.
* It works on objects that implement the comparison operators (e.g. `<`,
  `<=`, `>`, `>=`) but do not implement `between?`.
* It provides both `inclusive` and `exclusive` modes.

{% codeblock be_between_examples.rb %}
# like `Comparable#between?`, it is inclusive by default
expect(10).to be_between(5, 10)

# ...but you can make it exclusive:
expect(10).not_to be_between(5, 10).exclusive

# ...or explicitly label it inclusive:
expect(10).to be_between(5, 10).inclusive
{% endcodeblock %}

Thanks to [Erik Michaels-Ober](https://github.com/sferik) for
[contributing](https://github.com/rspec/rspec-expectations/pull/405) this and
[Pedro Gimenez](https://github.com/pedrogimenez) for
[improving](https://github.com/rspec/rspec-expectations/pull/412) it!

For more info:

* [Documentation](http://rubydoc.info/github/rspec/rspec-expectations/RSpec/Matchers#be_between-instance_method)

### Boolean matchers have been renamed

RSpec 2 had a pair of matchers (`be_true` and `be_false`) that mirror
Ruby's conditional semantics: `be_true` would pass for any value besides
`nil` or `false`, and `be_false` would pass for `nil` or `false`.

In RSpec 3, we've renamed these to `be_truthy` and `be_falsey`
(or `be_falsy`, if you prefer that spelling) to make their semantics
more explicit and to reduce confusion with `be true`/`be false`
(which read the same as `be_true`/`be_false` but only pass when given
exact `true`/`false` values).

Thanks to [Sam Phippen](https://github.com/samphippen) for
[implementing](https://github.com/rspec/rspec-expectations/pull/284)
this.

For more info:

* [rspec-expectations #283 - original discussion](https://github.com/rspec/rspec-expectations/issues/283)

### `match_array` matcher now available as `contain_exactly`

RSpec has long had a matcher that allows you to match the contents of
two arrays while disregarding any ordering differences. Originally,
this was available using the `=~` operator with the old `should` syntax:

{% codeblock match_array_operator_example.rb %}
[2, 1, 3].should =~ [1, 2, 3]
{% endcodeblock %}

Later, when we [added the `expect`
syntax](http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax),
we decided not to bring the operator matchers forward to the new syntax,
and called the matcher `match_array`:

{% codeblock match_array_example.rb %}
expect([2, 1, 3]).to match_array([1, 2, 3])
{% endcodeblock %}

`match_array` was the best name we could think of at the time
but we weren't super happy with it: "match" is an imprecise
term and the matcher is meant to work on other kinds of collections
besides arrays. We came up with a much better name for it
in RSpec 3:

{% codeblock contain_exactly_example.rb %}
expect([2, 1, 3]).to contain_exactly(1, 2, 3)
{% endcodeblock %}

Note that `match_array` is _not_ deprecated. The two methods behave identically,
except that `contain_exactly` accepts the items splatted out individually,
whereas `match_array` accepts a single array argument.

For more info:

* [Documentation](https://relishapp.com/rspec/rspec-expectations/v/3-0/docs/built-in-matchers/contain-exactly-matcher)
* [rspec-expectations #398 - original discussion](https://github.com/rspec/rspec-expectations/issues/398)
* [Implementation](https://github.com/rspec/rspec-expectations/commit/6bde36e7b4ec67fcdd239cf498bebf07f661e561)

### Collection cardinality matchers extracted into `rspec-collection_matchers` gem

The collection cardinality matchers — `have(x).items`,
`have_at_least(y).items` and `have_at_most(z).items` — were one of
the more "magical" and confusing parts of RSpec. They have
been [extracted](https://github.com/rspec/rspec-expectations/pull/293) into the
[rspec-collection-matchers](https://github.com/rspec/rspec-collection_matchers) gem, which
[Hugo Baraúna](https://github.com/hugobarauna) has graciously volunteered to maintain.

The general alternative is to set an expectation on the size of
a collection:

{% codeblock collection_matcher_examples.rb %}
expect(list).to have(3).items
# ...can be written as:
expect(list.size).to eq(3)

expect(list).to have_at_least(3).items
# ...can be written as:
expect(list.size).to be >= 3

expect(list).to have_at_most(3).items
# ...can be written as:
expect(list.size).to be <= 3
{% endcodeblock %}

### Improved integration with Minitest

In RSpec 2.x, rspec-expectations would [automatically include
itself](https://github.com/rspec/rspec-expectations/blob/v2.14.5/lib/rspec/matchers/test_unit_integration.rb)
in `MiniTest::Unit::TestCase` or `Test::Unit::TestCase` so that
you could use rspec-expectations from Minitest or Test::Unit simply
by loading it.

In RSpec 3, we've updated this integration in a couple ways:

* Integration with Minitest 4 (or lower) or Test::Unit is no
  longer automatic. If you use rspec-expectations in such an
  environment, you'll need to `include RSpec::Matchers` yourself.
* Improved integration with Minitest 5 is now provided, but you
  have to explicitly load it via `require 'rspec/expectations/minitest_integration'`

For more info:

* [rspec/expectations/minitest\_integration.rb](https://github.com/rspec/rspec-expectations/blob/v3.0.0.beta2/lib/rspec/expectations/minitest_integration.rb)

### Changes to the matcher protocol

As mentioned above, in RSpec 3, we no longer consider `should` to be
the main syntax of rspec-expectations. We've updated the matcher
protocol to reflect this:

* `failure_message_for_should` is now `failure_message`.
* `failure_message_for_should_not` is now `failure_message_when_negated`.
* `match_for_should` (an alias of `match` in the custom matcher DSL)
  has been removed with no replacement. (Just use `match`).
* `match_for_should_not` in the custom matcher DSL is now
  `match_when_negated`.

In addition, we've added `supports_block_expectations?` as a new, optional part
of the matcher protocol. This is used to give users clear errors when they
wrongly use a value matcher in a block expectation expression. For
example, before this change, passing a block to `expect` when using a
matcher like `be_nil` could lead to false positives:

{% codeblock block_expectation_gotcha.rb %}
expect { foo.bar }.not_to be_nil

# ...is equivalent to:
block = lambda { foo.bar }
expect(block).not_to be_nil

# ...but the block is not nil (even though `foo.bar` might return nil),
# so the expectation will pass even though the user probably meant:
expect(foo.bar).not_to be_nil
{% endcodeblock %}

Note that `supports_block_expectations?` is an optional part of the
protocol. For matchers that are not intended to be used in block
expectation expressions, you do not need to define it.

For more info:

* [rspec-expectations #270 - original discussion](https://github.com/rspec/rspec-expectations/issues/270)
* [rspec-expectations #373 - implementation](https://github.com/rspec/rspec-expectations/pull/373)
* [rspec-expectations #530 - original discussion of `supports_block_expectations?`](https://github.com/rspec/rspec-expectations/issues/526)
* [rspec-expectations #530 - implementation of `supports_block_expectations?`](https://github.com/rspec/rspec-expectations/pull/530)

## rspec-mocks

### Using the monkey-patched syntax without explicitly enabling it is deprecated

As with rspec-expectations, we've been moving rspec-mocks towards a
zero-monkey patching syntax. This was [originally
introduced](http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/)
in 2.14. In RSpec 3, you'll get a deprecation warning if you use the
original syntax (e.g. `obj.stub`, `obj.should_receive`, etc) without
explicitly enabling it (just like with rspec-expectations' new syntax).

Thanks to [Sam Phippen](https://github.com/samphippen) for
[implementing](https://github.com/rspec/rspec-mocks/pull/339)
this.

### `receive_messages` and `receive_message_chain` for the new syntax

The original monkey patching syntax had some features that the
new syntax, as released in 2.14, lacked. We've addressed that
in RSpec 3 via a couple new APIs: `receive_messages` and
`receive_message_chain`.

{% codeblock examples.rb %}
# old syntax:
object.stub(:foo => 1, :bar => 2)
# new syntax:
allow(object).to receive_messages(:foo => 1, :bar => 2)

# old syntax:
object.stub_chain(:foo, :bar, :bazz).and_return(3)
# new syntax:
allow(object).to receive_message_chain(:foo, :bar, :bazz).and_return(3)
{% endcodeblock %}

One nice benefit of these new APIs is that they work with `expect`, too,
whereas there was no message expectation equivalent of `stub(hash)` or
`stub_chain` in the old syntax.

Thanks to [Jon Rowe](https://github.com/JonRowe) and
[Sam Phippen](https://github.com/samphippen) for implementing this.

For more info:

* [Documentation for `receive_messages`](http://rubydoc.info/github/rspec/rspec-mocks/RSpec/Mocks/ExampleMethods#receive_messages-instance_method)
* [Documentation for
  `receive_message_chain`](http://rubydoc.info/github/rspec/rspec-mocks/RSpec/Mocks/ExampleMethods#receive_message_chain-instance_method)
* [rspec-mocks #368 - discussion of `receive_messages`](https://github.com/rspec/rspec-mocks/issues/368)
* [rspec-mocks #399 - implementation of `receive_messages`](https://github.com/rspec/rspec-mocks/pull/399)
* [rspec-mocks #464 - discussion of `receive_message_chain`](https://github.com/rspec/rspec-mocks/issues/464)
* [rspec-mocks #467 - implementation of `receive_message_chain`](https://github.com/rspec/rspec-mocks/pull/467)

### Removed `mock` and `stub` aliases of `double`

Historically, rspec-mocks has provided 3 methods for creating
a test double: `mock`, `stub` and `double`. In RSpec 3, we've
removed `mock` and `stub` in favor of just `double`, and built
out more features that use the `double` nomenclature (such as
verifying doubles — see below).

Of course, while RSpec 3 no longer provides `mock` and `stub`
aliases of `double`, it's easy to define these aliases on your
own if you'd like to keep using them:

{% codeblock spec/spec_helper.rb %}
module DoubleAliases
  def mock(*args, &block)
    double(*args, &block)
  end
  alias stub mock
end

RSpec.configure do |config|
  config.include DoubleAliases
end
{% endcodeblock %}

Thanks to [Sam Phippen](https://github.com/samphippen) for
[implementation](https://github.com/rspec/rspec-mocks/pull/341)
this.

For more info:

* [Explanation for why we made this change](https://gist.github.com/myronmarston/6576665)

### Verifying doubles

A new type of double has been added that ensures you only stub or mock methods
that actually exist, and that passed arguments conform to the declared method
signature. The `instance_double`, `class_double`, and `object_double` doubles
will all raise an exception if those conditions aren't met. If the class has
not been loaded (usually when running a unit test in isolation), then no
exceptions will be raised.

This is a subtle behaviour, but very powerful since it allows the speed of
isolated unit tests with the confidence closer to that of an integration test
(or a type system). There is rarely a reason not to use these new more powerful
double types.

Thanks to [Xavier Shay](http://xaviershay.com) for the idea and implementation
of this feature.

For more info:

* [Blog post on motivation and uses](http://rhnh.net/2013/12/10/new-in-rspec-3-verifying-doubles)
* [Documentation](https://relishapp.com/rspec/rspec-mocks/v/3-0/docs/verifying-doubles)

### Partial double verification configuration option

Verifying double behaviour can also be [enabled globally on partial
doubles](https://relishapp.com/rspec/rspec-mocks/v/3-0/docs/verifying-doubles/partial-doubles).
(A partial double is when you mock or stub an existing object:
`expect(MyClass).to receive(:some_message)`.)

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
{% endcodeblock %}

We recommend you enable this option for all new code.

### Scoping changes

rspec-mocks's operations are designed with a per-test lifecycle in mind.
This was documented in RSpec 2, but was not always explicitly enforced
at runtime, and we sometimes got bug reports from users when they tried
to use features of rspec-mocks outside of the per-test lifecycle.

In RSpec 3, we've tightened this up and this lifecycle is enforced
explicitly at runtime:

* Usage of rspec-mocks features from a `before(:context)` hook (or in any
  other context when there is not a current example) is not supported.
* Test doubles are only usable for one example. If you attempt to use
  a test double outside of the example in which it originated (e.g. by
  accidentally assigning it to a class attribute and then using it in
  a later example), you will get explicit errors.

We've also provided a new API that lets you create temporary scopes in
arbitrary places (such as a `before(:context)` hook):

{% codeblock my_web_crawler_spec.rb %}
describe MyWebCrawler do
  before(:context) do
    RSpec::Mocks.with_temporary_scope do
      allow(MyWebCrawler).to receive(:crawl_depth_limit).and_return(5)
      @crawl_results = MyWebCrawler.perform_crawl_on("http://some-host.com/")
    end # verification and resets happen when the block completes
  end

  # ...
end
{% endcodeblock %}

Thanks to [Sam Phippen](https://github.com/samphippen) for helping with
[implementing](https://github.com/rspec/rspec-mocks/pull/449) these changes,
and [Sebastian Skałacki](https://github.com/skalee) for suggesting the new
`with_temporary_scope` feature.

For more info:

* [rspec-mocks #240 - original discussion](https://github.com/rspec/rspec-mocks/issues/240)
* [rspec-mocks #519 - `with_temporary_scope` implementation](https://github.com/rspec/rspec-mocks/pull/519)

### `any_instance` implementation blocks yield the receiver

When providing an implementation block for a method stub it can be
useful to do some calculation based on the state of the object.
Unfortunately, there wasn't a simple way to do this when using
`any_instance` in RSpec 2. In RSpec 3, the receiver is yielded
as the first argument to an `any_instance` implementation block,
making this easy:

{% codeblock any_instance_example.rb %}
allow_any_instance_of(Employee).to receive(:salary) do |employee, currency|
  usd_amount = 50_000 + (10_000 * employee.years_worked)
  currency.from_usd(usd_amount)
end

employee = Employee.find(23)
salary = employee.salary(Currency.find(:CAD))
{% endcodeblock %}

Thanks to [Sam Phippen](https://github.com/samphippen) for
[implementing](https://github.com/rspec/rspec-mocks/pull/351) this.

For more info:

* [rspec-mocks #175 - original discussion](https://github.com/rspec/rspec-mocks/issues/175)

## rspec-rails

### File-type inference disabled by default

rspec-rails automatically adds metadata to specs based on their location on the
filesystem. This is confusing to new users, and not desirable for some veteran
users.

In RSpec 3, this behavior must be explicitly enabled:

{% codeblock spec/spec_helper.rb %}
RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
{% endcodeblock %}

Since this assumed behavior is so prevalent in tutorials, the default generated
configuration still enables this.

To explicitly tag specs without using automatic inference, set the `type`
metadata:

{% codeblock things_controller_spec.rb %}
RSpec.describe ThingsController, type: :controller do
  # Equivalent to being in spec/controllers
end
{% endcodeblock %}

The different available types are documented in each of the different spec
types, for instance [documentation for controller
specs](https://relishapp.com/rspec/rspec-rails/v/3-0/docs/controller-specs).

For more info:

* [rspec-rails #662 - original discussion](https://github.com/rspec/rspec-rails/issues/662)
* [rspec-rails #970 - implementation](https://github.com/rspec/rspec-rails/pull/970)

### Extracted activemodel mocks support

`mock_model` and `stub_model` have been extracted into the [rspec-activemodel-mocks
gem](https://github.com/rspec/rspec-activemodel-mocks).

Thanks to [Thomas Holmes](https://github.com/thomas-holmes) for doing the
extraction and for offering to maintain the new gem.

### Dropped webrat support

Webrat support has been removed. Use capybara instead.

### Anonymous controller improvements

rspec-rails has long allowed you to create anonymous controllers for testing.
In RSpec 3 they have received some improvements:

* By default they will inherit from the described class rather than
  `AppplicationController`. This behaviour can be disabled with the
  `infer_base_class_for_anonymous_controllers` configuration option.
* Many bugfixes when using in "non-standard" contexts, such as with abstract
  parents or with no `ApplicationController`. If you have had issues with
  anonymous controllers in the past, now would be a good time to try them
  again.

For more info:

* [Documentation - Anonymous controllers](https://relishapp.com/rspec/rspec-rails/v/3-0/docs/controller-specs/anonymous-controller)
* [rspec-rails #893 - Enable infering base class by default](https://github.com/rspec/rspec-rails/pull/893)
* [rspec-rails #905 - Fix anonymous controller route helpers](https://github.com/rspec/rspec-rails/pull/905)
* [rspec-rails #924 - Don't assume presence of ApplicationController](https://github.com/rspec/rspec-rails/pull/924)


## Final words

As always, full changelogs are available for each for the subprojects:

* [rspec-core](https://github.com/rspec/rspec-core/blob/master/Changelog.md)
* [rspec-expectations](https://github.com/rspec/rspec-expectations/blob/master/Changelog.md)
* [rspec-mocks](https://github.com/rspec/rspec-mocks/blob/master/Changelog.md)
* [rspec-rails](https://github.com/rspec/rspec-rails/blob/master/Changelog.md)

RSpec 3 is the first major release of RSpec in nearly 4 years. It
represents a huge amount of work from a large number of contributors.

We hope you like the new changes as much as we do, no matter how you use RSpec.

_Thanks to Xavier Shay for helping write this blog post and to Jon Rowe,
Sam Phippen and Aaron Kromer for proofreading it._

