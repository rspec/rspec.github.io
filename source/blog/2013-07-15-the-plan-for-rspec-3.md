---
layout: dev_post
title: The Plan for RSpec 3
section: dev-blog
contents_class: medium-wide
---

Update: [There's a Japanese translation of
this](http://nilp.hatenablog.com/entry/2013/07/16/131641) available
now.

RSpec 2.0 was released in October 2010. In the nearly three years since
then, we've been able to continually improve RSpec without needing to
make breaking changes, but we've reached a point where RSpec has a fair
bit of cruft stemming from the need to retain backwards
compatibility with older 2.x releases.

[RSpec 2.14](/n/dev-blog/2013/07/rspec-2-14-is-released)
will be the last RSpec 2 feature release. (We may do some
bug-fix patch releases, though). We're getting started on RSpec 3, and
I'd like to share our thoughts on the direction RSpec will be going.

None of this is set in stone, of course, and ultimately RSpec has been
a successful project because of all of the people who use it. So please
speak up if you have any thoughts about the direction we should take
with RSpec 3!

## What's Being Removed

### No More 1.8.6 and 1.9.1 Support

RSpec 2.x has continued to support Ruby 1.8.6 long after that version
has ceased being supported by the MRI team. As an important piece of
testing infrastructure in the Ruby ecosystem, we've felt that it's
important to allow gem authors to decide when to drop support for
older Ruby versions, and not be forced to do so prematurely because
the test framework they've chosen to use no longer supports one of
the versions they support.

Ruby 1.8.6 and 1.9.1 have not been available on
[Travis](https://travis-ci.org/) for [nearly two
years](https://gist.github.com/michaelklishin/1223640), and
without the safety net of a CI server running our builds
on those versions, it's become extremely difficult to continue
supporting them. In practice, we've really only "semi-supported"
these ruby versions for the last couple years: when users report
issues on these ruby versions, we'll fix them, but we haven't been
expending effort on support beyond that.

And so, the time has come to drop support for these versions. We plan
to continue to support 1.8.7, 1.9.2 and all newer ruby versions on
RSpec 3. Given that 1.8.7 is now legacy, we'll probably be dropping
support for 1.8.7 in RSpec 4, although if/when Travis stops supporting it
before then, we'll only be able to "semi-support" it in the same way
we've been semi-supporting 1.8.6.

### Core: `its` will be moved into an external gem

[I've written about this
before](https://gist.github.com/myronmarston/4503509), so I won't
belabor the point here.  We plan to move `its` out of rspec-core
and into an external gem.

### Expectations: `have(x).items` matchers will be moved into an external gem

RSpec originated in a time before the existence of Cucumber/Gherkin,
and one of its early goals was to express things in natural language
that a project stakeholder could understand.  In those early days,
an expression like `team.should have(9).players` made sense for
the goals of the project. Since then, Cucumber/Gherkin have emerged
as a better alternative for stakeholder-focused tests, and RSpec
is rarely used for that purpose today. The `have(x).items` family
of matchers (including the `have_at_least(x).items` and
`have_at_most(x).items` siblings) are unnecessarily complicated, when a
simple expression like `expect(team.players.size).to eq(9)` works just fine.

We plan to move these matchers out of `rspec-expectations` and into
an external gem.

### Core: No more explicit debugger support

RSpec has long supported a `-d` / `--debug` command line option
for enabling the debugger via the `ruby-debug` gem. However, today
`ruby-debug` is not the only (or even main) debugging gem in use
today. [debugger](https://github.com/cldwalker/debugger) has become
the de-facto standard debugging gem for MRI 1.9.2+, and many developers
prefer to use [pry](http://pryrepl.org/) for debugging. Other
ruby interpreters like Rubinius feature [their own
debugger](http://rubini.us/doc/en/tools/debugger/).

We plan to remove the explicit debugger support in RSpec 3. Besides
removing the command line option, we'll be removing the
[monkey patching of debugger in
Kernel](https://github.com/rspec/rspec-core/blob/v2.13.1/lib/rspec/core/extensions/kernel.rb)
when ruby-debug is not loaded, so you will get a `NoMethodError`
from `debugger` when a debugger is not loaded.

If you want to continue to load the debugger using a command line option,
you can use the require flag (`-r`), using an option like `-rdebugger`.

### Core: No more RCov integration

`RSpec::Core::RakeTask` has had some [RCov
options](https://github.com/rspec/rspec-core/blob/v2.13.1/lib/rspec/core/rake_task.rb#L65-L84)
for a long time. RCov only works with MRI 1.8, and today
most ruby developers use
[SimpleCov](https://github.com/colszowka/simplecov) for their code
coverage needs. SimpleCov integrates with RSpec (or any test framework)
very simply, with no explicit support needed from within RSpec itself.

### Core: Autotest integration will be moved into an external gem

Autotest used to be the primary ruby continuous test runner.
These days, [guard](https://github.com/guard/guard) seems to
be the more popular choice, and there's no reason that RSpec's
Autotest integration needs to remain in rspec-core.

### Core: TextMate formatter will be moved into the TextMate bundle

For many years, TextMate was the most popular text editor used by
ruby developers. RSpec has had a [TextMate-specific
formatter](https://github.com/rspec/rspec-core/blob/v2.13.1/lib/rspec/core/formatters/text_mate_formatter.rb)
for many years.  These days, [TextMate isn't nearly as popular
among ruby developers as it used to
be](http://survey.hamptoncatlin.com/survey/stats#question_6), and
there's no compelling reason for the TextMate formatter
to remain in rspec-core.

### Lots of Deprecations

RSpec 2.14 includes many things that have been deprecated
over the last couple of years. We plan to remove nearly all of the
deprecated APIs and features.

### What about the old expectation/mock syntax?

[RSpec 2.11
introduced](http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax)
a new `expect`-based syntax for rspec-expectations.
[In RSpec
2.14](http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/),
we updated rspec-mocks to use a similar syntax. Since
introducing the new syntax, I've received a number of questions
about how soon we will be deprecating or removing the old
`should`-based syntax.

While I won't say "never" (who knows what the future holds?),
we don't have any current plans to ever remove the old syntax.
Users have invested in code that uses the old syntax for many
years, and while we recommend using the new syntax (particularly
for new projects), we'd be doing users a disservice to remove
the old syntax anytime soon. It's also not a significant
maintenance burden.

For RSpec 3, we considered the idea of disabling the old syntax
by default, forcing users to opt-in to use it.  However, I think
that doing so would be a disservice to new users who are coming
to RSpec through a less-than-current tutorial. Getting a `NoMethodError`
for an example copied from a tutorial can be very frustrating
to someone trying RSpec for the first time. Experienced users
can easily disable the old syntax, whereas new users aren't
likely to have enough RSpec knowledge to know to enable
the old syntax used by their tutorial.

That said, we do want to encourage people to switch to
the new syntax, so we plan to make RSpec 3
print a warning on first usage of any the old syntax
methods (`should`, `should_not`, `should_receive`, etc)
_unless the `should` syntax has been explicitly enabled_.
This should nudge folks towards the new syntax while keeping
RSpec friendly to new users and will pave the way for
the old syntax to be disabled by default in RSpec 4.

## What's New

### Zero Monkey Patching Mode!

Historically, RSpec has extensively used monkey patching
to create its readable syntax, adding methods like `describe`,
`shared_examples_for`, `shared_context`,
`should`, `should_not`, `should_receive`, `should_not_receive`
and `stub` to every object. In the last few 2.x releases, we've
worked towards reducing the amount of monkey patching done by RSpec:

* As of rspec-core 2.11, `describe` is no longer added to every
  object. Instead, it is only added to the top-level `main` object
  and to `Module` (so that it is available from within classes
  and modules).
* In rspec-expectations 2.11, we added the `expect` syntax and
  provided a config option to disable the `should` syntax -- which
  removes `should` and `should_not` from every object.
* As of rspec-core 2.12, `shared_examples_for` and `shared_context`,
  are no longer added to every object. As with `describe`, they are
  only added to the top-level `main` object and to `Module`.
* In rspec-mocks 2.14, we updated `rspec-mocks` to support an
  `expect`-based syntax as well, and provided a config option
  to disable the old mocking syntax -- which removes `should_receive`,
  `should_not_receive` and `stub` from every object.

As discussed above, we'll be removing RSpec's monkey-patched
`Kernel#debugger` in 3.0. We're also planning to provide a
config option to remove the monkey patching of the top-level
DSL methods (`describe`, `shared_examples_for`, etc) onto
`main` and `Module`, instead requiring you to prefix these
methods with `RSpec.`:

{% codeblock my_class_spec.rb %}
RSpec.describe MyClass do
  # Within an example group you'll still be able to use
  # a bare `describe`:
  describe "#some_method" do
  end

  # And you'll be able to use a bare `shared_examples_for`:
  shared_examples_for "something" do
  end
end

RSpec.shared_examples_for "some behavior" do
end
{% endcodeblock %}

The net result will be a set of config options (one for
`rspec-expectations`, one for `rspec-mocks` and one for `rspec-core`), that
will provide a zero-monkey-patching mode for RSpec. (We may also
provide a single unified config option that sets all three).

We plan for these config options to become the defaults in RSpec 4.0,
so that RSpec 4.0 will have zero monkey patching out of the box.

### Mocks: Test double interface verification

It's unfortunately been very easy to let your test doubles
get out of sync with the real interfaces they are doubling.
When you rename a method, or change the number of arguments
a method expects, it's easy to forget to update the test doubles
you are using as standins for the changed class.

I've long been a fan of
[rspec-fire's](https://github.com/xaviershay/rspec-fire) approach
to solving this problem.  I plan to port a version of it to rspec-mocks.

Take a look at the [github
issue](https://github.com/rspec/rspec-mocks/issues/227#issuecomment-19143955)
where we are discussing this for the full details (the API and semantics
of this feature are certainly not set in stone yet, so please voice your
thoughts on that ticket!)

### Expectations: Fully composable matchers

In RSpec 2.13, we [added
support](/n/dev-blog/2013/02/rspec-2-13-is-released#_matcher_can_accept_a_list_of_matchers)
for the `include` matcher to accept a list of matchers to match against.
This kind of composability is quite useful and we plan to extend
it to all matchers in RSpec 3. For example, you could use an expression
like:

{% codeblock my_spec.rb %}
expect { |b|
  some_object.do_something(&b)
}.to yield_with_args(include(match(/foo/), match(/bar/)))
{% endcodeblock %}

This expresses a detailed expectation: "I expect
`some_object.do_something` to yield with a collection that
includes a string matching `/foo/` and a string matching `/bar/`".

We're also considering adding matcher aliases that read better when
composed in this fashion, so that you could write this as:

{% codeblock my_spec.rb %}
expect { |b|
  some_object.do_something(&b)
}.to yield_with_args(a_collection_including(a_string_matching(/foo/),
                                            a_string_matching(/bar/)))
{% endcodeblock %}

For more details, or to weigh in on this issue, take a look at the
[github issue](https://github.com/rspec/rspec-expectations/issues/280).

### Core: Formatter API improvements

The current API for notifying formatters of test suite progress has proved to
be a bit inflexible when it comes to adding in new notifications and changing
existing notifications.  We're planning to change it in a couple ways:

* Rather than requiring that all formatters implement all notification methods,
  formatters will be able to subscribe to specific notifications. This will
  allow you to implement the minimum set your formatter needs, and will allow
  us to add new notifications without worrying about breaking existing formatters.
* Notification arguments will change from an ordered list of arguments
  to a single value object, which will allow us to easily add additional data
  to specific notifications without changing the method signature.

These changes will allow us to make further improvements that we have been unable
to make in the 2.x releases. We also plan to provide a compatibility layer in
RSpec 3 that wraps formatters written against the old API and adapts
them to the new API so that users can more easily upgrade when they rely
upon old formatters.

For more details, take a look at the [github
issue](https://github.com/rspec/rspec-core/issues/944).

### Core: DSL methods will yield the example

In RSpec 2, the current running example is exposed as `example`.
It can be used to [access the example's
metadata](https://relishapp.com/rspec/rspec-core/v/2-14/docs/metadata/user-defined-metadata#define-group-metadata-using-a-hash).
This has occasionally [caused
problems](https://github.com/rspec/rspec-core/issues/663)
when users inadvertently define their own `example` method. In RSpec 3,
we're removing the `example` method, opting to yield the example from
each DSL method that runs in the context of an example:

{% codeblock my_spec.rb %}
describe MyClass do
  before(:each) { |example| }
  subject       { |ex| }
  let(:user)    { |ex| User.find(ex.metadata[:user_id]) }

  # before(:all) will NOT yield an example

  it "can access the current example using a block local" do |example|
    # do something with `example`
  end
end
{% endcodeblock %}

We're aware that this may cause upgrade headaches for users who
rely on gems that use the `example` API (such as Capybara).
We're discussing ways to make the upgrade smoother, both for users
of gem authors. For more information, see the [github
issue](https://github.com/rspec/rspec-core/pull/666).

### Expectations: Matcher protocol and custom matcher API changes

While RSpec has been moving away from its `should`-based syntax,
the matcher protocol and custom matcher API have not changed
accordingly. The matcher protocol still relies upon methods like
`failure_message_for_should` and `failure_message_for_should_not`,
and the custom matcher API has methods like `match_for_should`
and `match_for_should_not`.

In RSpec 3, we'd like to change the matcher protocol and custom matcher
API to no longer speak in terms of `should` while still retaining
a backwards compatibility layer so that existing matchers will
continue to work, with the plan to remove that compatibility
layer in RSpec 4. We're not sure what the new APIs will be yet; if
you have thoughts, please [chime in on the github
issue](https://github.com/rspec/rspec-expectations/issues/270).

### Mocks: `any_instance` block implementations will yield the receiver

When stubbing a method using `any_instance` you can pass a block
implementation just like a normal stub. However, if you wanted to
access the receiver (i.e. the instance receiving the message) in
the block, there was no way to accomplish this.  In RSpec 3, we're
correcting this oversight, and the receiver will be yielded as
the first block argument:

{% codeblock my_spec.rb %}
allow_any_instance_of(User).to receive(:age) do |user|
  ((Date.today - user.birthdate) / 365).floor
end
{% endcodeblock %}

For backwards compatibility, we'll be adding a config option to disable
this behavior.

## The Upgrade Path

Even though RSpec 3.0 will be a major release that allows
us to make intentional breaking changes for the first time since 2010,
it's important to us that the upgrade path for existing
test suites be as easy as possible. To that end, we're planning
a 2.99 release that will exist purely to help users upgrade.
Here's what we have in mind:

* RSpec 2.99 will be RSpec 2.14 plus some extra deprectation warnings
  for things that will be removed in 3.0.
* You should be able to take your existing RSpec 2.x test suite and
  upgrade to 2.99 _without_ needing to make any changes.
* RSpec 2.99 will give you deprecation notices for anything we're
  removing or somehow breaking in 3.0. You should address those
  warnings. Once you're warning-free on 2.99, you should be able
  to upgrade to 3.0 without needing to make any further changes.

The 2.99 release will be an important step that shouldn't be skipped
in the upgrade process. It'll give you an upgrade checklist that
is specifically tailored to _your_ test suite's usage of RSpec,
giving you a much simpler and more efficient way to upgrade than
combing through changelogs trying to figure out what all is changing
in RSpec 3.

## The Development and Release Plan

We've already began working on RSpec 3 in the master branches of
each of the RSpec repos. We also have a 2-14-maintenance branch
for 2.14 changes (i.e. for possible patch releases)
and a 2-99-maintenance branch for the changes
that will be going in to 2.99. We're planning to do multiple
release candidates (and potentially some beta releases) as we
make progress towards the final 3.0 release.

I won't venture a guess for when we might release RSpec 3.
Experience has taught me that software release date estimates
are always wrong :(.

## "How can I help?"

The current RSpec core team ([David](https://twitter.com/dchelimsky),
[Andy](https://twitter.com/alindeman), [Jon](https://twitter.com/JonRowe),
[Sam](https://twitter.com/samphippen), [Bradley](https://twitter.com/soulcutter)
and [myself](https://twitter.com/myronmarston)) will be driving the work
for the 3.0 release...but as always, we love to get help from the community.
Here are some specific ways you can help out:

* As mentioned above, we plan to extract some of RSpec's functionality
  into an external gem (`its`, `have` matchers and the autotest integration).
  It would be great to find folks in the community who can step forward
  and take over maintenance (and maybe even do the initial extraction,
  if you're so inclined) for these gems.
* We value community feedback about the direction RSpec is going, so please
  comment on the issues I've linked to above (and any other issues, really --
  there will be more in RSpec 3 than I've covered here!)
  if you have thoughts or ideas.
* If you'd like to help contribute code to RSpec, that's great! However,
  during this period, there's going to be more churn than usual in the
  codebases of the various RSpec gems, creating more merge conflicts
  with pull requests, and making it more difficult for us to integrate
  contributions from users. So, if you want to contribute, please get
  in touch (either by commenting on github issues and/or chatting with
  us on the #rspec channel on irc.freenode.net) before putting extensive
  effort into a PR. A little bit of communication up front will go a long
  way towards making it easy for us to integrate your contribution.
* One of the most important ways you can help is to try out out the
  pre-release versions of 2.99 and 3.0 and give us feedback. Stay tuned
  for release announcements.
* [rspec.info](http://rspec.info/) is badly in need of a refresh, and it
  would be great to launch a new version of that site in tandem with the
  release of RSpec 3.  However, it's very hard for the RSpec core team to
  find time to work on the website, and most of us focus more on backend
  than frontend dev. It would be great if some community members would
  step forward and help in this area!

