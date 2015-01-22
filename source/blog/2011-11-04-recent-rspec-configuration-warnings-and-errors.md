---
title: Recent RSpec Configuration Warnings and Errors
author: Myron Marston
---

RSpec 2.6 introduced a deprecation warning when using `RSpec.configure {
... }` after defining an example group.  In RSpec 2.7, this warning was
removed, and now an error is raised when particular configuration
settings (`expect_with` and `mock_with`) are set after defining an
example group.

Recently, there have been comments and complaints on these changes
from [several](http://twitter.com/#!/elight/status/112166313518039040)
[different](http://twitter.com/#!/stevenharman/status/132251947473444864)
[people](http://twitter.com/#!/pda/status/129116122074185728)
on [twitter](http://twitter.com/#!/kytrinyx/status/116773198833532928).

I'm the one who made those changes to RSpec, and people are rightfully
annoyed with these changes...but there's a lot more to the story. I'm
not sure what the right solution is to the problem I was trying to solve
by making those changes, but I'm hoping that by blogging about it, we
can get some good ideas from the community.

## RSpec 2.0

One of the primary goals of RSpec 2 was to decouple the spec runner (rspec-core)
from the mocking framework (rspec-mocks) and the expectation framework
(rspec-expectations).  Besides the fact that decoupling is A Good Thing&trade;,
this separation opened up new possibilities for people to pick and
choose which parts of RSpec they want to use.

In particular, it allows people to use rspec-core to define and run their tests
using RSpec's example definition DSL (`describe`, `it`, `before`, `let`,
etc) while sticking with the `assert_foo` assertion methods from
Test::Unit or minitest, rather than using RSpec's `object.should whatever`
syntax. For better or worse, some people really dislike rspec-expectations
but love the runner.

RSpec 2 allows you to configure which you want to use:

{% codeblock spec_helper.rb %}
RSpec.configure do |config|
  config.expect_with :stdlib
end

# or

RSpec.configure do |config|
  # not strictly necessary; this is the default config anyway
  config.expect_with :rspec
end
{% endcodeblock %}

Both rspec-expectations and the standard library assertions are
available as modules--`RSpec::Matchers` and `Test::Unit::Assertions`,
respectively.  RSpec 2.0 to 2.5 included the appropriate module into
`RSpec::Core::ExampleGroup` just prior to running the examples (that is,
after all of them have been defined) to allow people to configure this
whenever they want.

Unfortunately, this triggered an unfortunate bug in ruby 1.9...which
I'll get to below.

## Infinite Recursion Issues

Shortly after RSpec 2 was released, we began to get some
[intermittent](http://groups.google.com/group/rspec/browse_thread/thread/eb54642fa0f051d1)
[reports](https://github.com/rspec/rspec-expectations/issues/63)
that users were occasionally getting a `SystemStackError` from
RSpec, indicating infinite recursion was occurring.  I myself saw this
error when working on the rspec-core specs at one point.

The recursion always happened in rspec-expectations' [method\_missing
hook](https://github.com/rspec/rspec-expectations/blob/v2.7.0/lib/rspec/matchers/method_missing.rb#L6-10).
In particular, the call to `super` triggered infinite recursion.

I found this very, very puzzling, and spent many hours troubleshooting
trying to figure out why `super` would infinitely recurse on itself.

## It's a Bug in Ruby 1.9

I eventually managed to boil the problem down to a simple rspec-less example:

{% codeblock example.rb %}
module MyModule
  def some_method; super; end
end

class MyBaseClass; end

class MySubClass < MyBaseClass;
  include MyModule
end

# To trigger this bug, we must include the module in the base class after
# the module has already been included in the subclass.  If we move this line
# above the subclass declaration, this bug will not occur.
MyBaseClass.send(:include, MyModule)

MySubClass.new.some_method
{% endcodeblock %}

If you run this on ruby 1.8, you will (correctly) get a `NoMethodError`.
On ruby 1.9, you get infinite recursion and a `SystemStackError`. Here's
my short explanation of the conditions that trigger this bug:

* Define a module that has a method that uses `super`.
* Include that module in a class _after_ it has already been included in one of its subclasses.
* Create an instance of said subclass and call the method.

Note that this error does not occur if the module is included in the
superclass _before_ it is included in the subclass.

## How this Bug Manifested Itself in RSpec

Here's how this bug manifested itself in RSpec:

* Every time you define an example group (using `describe` or `context`),
  RSpec creates a new subclass of `RSpec::Core::ExampleGroup`, or a
  subclass-of-a-subclass, if you have nested your example group within
  another one.
* Some users included `RSpec::Matchers` into their example groups.
  [Here's one example](https://github.com/radar/forem/blob/a9ce93d15fa77dbb3c586c3583dda49e70750809/spec/support/integration_example_group.rb#L13).
* As I explained above, in 2.0 to 2.5, RSpec included `RSpec::Matchers` in
  `RSpec::Core::ExampleGroup` right before running the examples, _after_
  all examples have been defined (and hence, after the user may have
  already included `RSpec::Matchers` in their example groups).
* When a user called an undefined or misspelled method from an example,
  it would trigger this error.

## Fixing the Issue...by Introducing Other Problems :(

To prevent users from getting infinite recursion, we need to prevent
`RSpec::Matchers` (and really, any other module that may use `super`)
from being included in an example group before it is included in
`RSpec::Core::ExampleGroup`. At one point, I considered adding a hook to
either `RSpec::Core::ExampleGroup` or `RSpec::Matchers` to detect when a
user is including it, and somehow prevent or warn them.  However, I
quickly realized that the extreme flexibility of Ruby's module system
makes this very complicated. A user may not be including
`RSpec::Matchers` directly; they may be including a module from some
library or plugin, that itself includes `RSpec::Matchers`, or includes a
module that includes `RSpec::Matchers`. I realized this wasn't going to
be a simple solution to get right.

Instead, after talking with [David
Chelimsky](http://twitter.com/#!/dchelimsky) and some other members of the
RSpec core team, we decided it was best to change when `RSpec::Matchers`
gets included. By including `RSpec::Matchers` in
`RSpec::Core::ExampleGroup` before it has been subclassed the issue goes away entirely.

We still wanted to let people configure `expect_with :stdlib`, though.
the best solution we could come up with is to delay the inclusion of the
expectation module until the moment when `RSpec::Core::ExampleGroup` is
being subclassed for the first time. This gives the user a chance to
configure `expect_with :stdlib` as long as they do so before defining
any example groups. Once an example group has been defined, we
automatically default to `expect_with :rspec`--which means that any
future `expect_with` configuration would be effectively ignored.

[Here's the commit](https://github.com/rspec/rspec-core/commit/622a4b7ac41e0ab6a4786070cca3ff866b72b57c),
if you're interested.  You'll notice that it also changes when the
mocking framework adapter module gets included.  Since we don't want to deal
with this issue again if/when one of the mocking framework adapter
modules uses `super`, I thought it best to change it as well.

This whole issue suggested to me that it's problematic to allow users to
configure RSpec after defining examples.  In my mind, since the
configuration affects how RSpec works, it's best to set it _before_ you
start to use RSpec (i.e. by defining examples).  I [made a
change](https://github.com/rspec/rspec-core/commit/fc70cee014689a947bfdea1ab04d91191327946f)
to cause RSpec to print a deprecation warning when you use
`RSpec.configure` after defining an example group.

In retrospect, I should have realized that this would affect a lot of
users. At the time, it didn't occur to me that it would. I do all of my
RSpec configuration before defining any example groups and I assumed
that's what everyone else did, too. The deprecation warning was mostly
just put there on the off chance that someone might configure RSpec
after defining an example.

## RSpec 2.6

RSpec 2.6 was released with these changes and we immediately began
getting questions and complaints
about this warning. People like [Gary Bernhardt](http://twitter.com/#!/garybernhardt)
and [Corey Haines](http://twitter.com/#!/coreyhaines) have a technique
of speeding up their tests by loading as little as possible--and this
usually involves not loading `spec_helper` from each spec file. This can
trigger the deprecation warning when one spec file (say,
`spec/lib/my_class_spec.rb`) does not require `spec_helper`, but another file in
the same suite (say `spec/models/user_spec.rb`) does.  If
`spec/lib/my_class_spec.rb` is
loaded before `spec/models/user_spec.rb` (which usually happens--they tend to
get loaded in alphabetical order), it will trigger the warning since
examples are defined in `spec/lib/my_class_spec.rb` before the configuration
happens in `spec_helper.rb`.

I'm a big fan of the "don't load spec\_helper" approach now, but at the time I made the changes,
I had never heard or thought of doing it that way.

We had a conversation about this on an [rspec-rails issue](https://github.com/rspec/rspec-rails/issues/371).
The best suggestion to come out of that (and one that no one argued
against) was to remove the warning, and instead raise an error on the
specific, problematic configs (`expect_with` and `mock_with`), if they
get set after defining an example group.

I made [this change](https://github.com/rspec/rspec-core/commit/f46e00aff4c9aa028991ff57e71d54f3dcd5c307)
and it was released in RSpec 2.7.

## RSpec 2.7

After RSpec 2.7 came out, there were yet more complaints about this
change. Now some users were unable to run their specs because of the
error. Effectively, this had made the problem worse--the previous
warning could be ignored, but not the error.

I [committed a change](https://github.com/rspec/rspec-core/commit/f2dc2f8954fc6663dc45f03375912dc58fc590f9)
a few days ago that should improve things here: instead of raising an error anytime
`expect_with` or `mock_with` are called after an example group is
defined, the error is only raised if the method call is changing the
setting. No error will be raised if you're simply explicitly setting the
default (i.e. `mock_with :rspec`) or re-setting the existing config
value.

This is certainly an important, needed change that I simply didn't
consider when I made the previous changes.  I apologize.

Note that this does not remove the error entirely: if you are
configuring RSpec to use a different expectation/assertion framework or
mocking framework, this must still be done _before_ an example group is
defined so that RSpec can include the appropriate module in
`RSpec::Core::ExampleGroup` _before_ it has been subclassed.

## Avoiding these warnings/errors

If you're on RSpec 2.6 or 2.7 and have gotten these warnings or errors,
there are some very simple changes you can make to avoid them.

First, make sure all of your spec\_helper requires are simply `require
'spec_helper'`. If you use a path relative to `__FILE__`, as people
often do, spec\_helper.rb can be loaded multiple times (since ruby will
happily re-require a file if it is specified as a different file path).
RSpec puts the spec directoy on the load path for you, so you can (and
generally should) just require `spec_helper`.

Second, if you follow the "don't load spec\_helper" approach, and
you need to configure either `expect_with` or `mock_with`, you'll
need to create a secondary helper file for your isolated, fast specs.

Here's one way to do it:

{% codeblock spec/fast_spec_helper.rb %}
require 'rspec'

RSpec.configure do |c|
  c.mock_with :mocha
end
{% endcodeblock %}

{% codeblock spec/spec_helper.rb %}
require 'fast_spec_helper'

# load rails or whatever to get your full app environment booted

RSpec.configure do |c|
  # other RSpec configuration
end
{% endcodeblock %}

{% codeblock spec/lib/my_class_spec.rb %}
require 'fast_spec_helper'

describe MyClass do
end
{% endcodeblock %}

{% codeblock spec/controllers/my_controller_spec.rb %}
require 'spec_helper'

describe MyController do
end
{% endcodeblock %}

I know this goes against the "don't load spec\_helper" approach a bit,
but the important thing is that the rails/sinatra/whatever environment
is not fully loaded in the isolated specs.  We're using
fast\_spec\_helper.rb to only configure the bare minimum--the specific
`expect_with` or `mock_with` settings that must be set before an
example group is defined. The one extra require isn't going to make a
noticeable difference in the speed of your isolated tests.

Of course, if you are just setting `mock_with` or `expect_with` to the
default (`:rspec`) then you should just remove that configuration
entirely and the error should go away--no need for a separate
`fast_spec_helper.rb` file.

Alternatively, you could use ruby's `-r` flag to force a helper file to
be loaded before any isolated specs, rather than having to require
a helper file from each.

## Is There a Better Way to Work Around this Bug?

So there you have it...the full story behind the recent configuration
warnings and errors in RSpec. I apologize if this has caused upgrade
pain for you. I solved the issues in the best way I could figure out.

If you think I totally screwed up, or if you can think of a better way
to deal with the ruby 1.9 bug, please let me know in the comments!

Also, I [filed a bug](http://redmine.ruby-lang.org/issues/5236) on
the ruby issue tracker. Please comment there if you would like to see it
fixed.
