---
title: Constant Stubbing in RSpec 2.11
author: Myron Marston
---

In the 2.11 release, rspec-mocks is gaining a significant new
capability that, as far as I know, isn't provided by any other
ruby mocking library: constant stubbing[^foot_1].

Let's look at the API, and then talk a bit about some of
the use cases for it.

## The API

The main API is `stub_const`:

~~~ ruby
describe "stub_const" do
  it "changes the constant value for the duration of the example" do
    stub_const("Foo::SIZE", 10)
    expect(Foo::SIZE).to eq(10)
  end
end
~~~

This works for both defined and undefined constants; you
could stub `A::B::C::D::E::F` even if none of the intermediary
constants exist. When the example completes, the constants will
be restored to their original states: any newly defined constants
will be undefined, and any modified constants will be restored
to their original values.

Note that constant names must be fully qualified; the current
module nesting is not considered:

~~~ ruby
module MyGem
  class SomeClass; end
end

module MyGem
  describe "Something" do
    let(:fake_class) { Class.new }

    it "accidentally stubs the wrong constant" do
      # this stubs ::SomeClass (in the top-level namespace),
      # not MyGem::SomeClass like you probably mean.
      stub_const("SomeClass", fake_class)
    end

    it "stubs the right constant" do
      stub_const("MyGem::SomeClass", fake_class)
    end
  end
end
~~~

`stub_const` also supports a `:transfer_nested_constants` option.
Consider a case where you have nested constants:

~~~ ruby
class CardDeck
  SUITS = [:spades, :diamonds, :clubs, :hearts]
  NUM_CARDS = 52
end
~~~

`stub_const("CardDeck", fake_class)` cuts off access to the
nested constants (`CardDeck::SUITS` and `CardDeck::NUM_CARDS`),
unless you manually assign `fake_class::SUITS` and
`fake_class::NUM_CARDS`. The `:transfer_nested_constants`
option is provided to take care of this for you:

~~~ ruby
# Default behavior:
fake_class = Class.new
stub_const("CardDeck", fake_class)
CardDeck # => fake_class
CardDeck::SUITS # => raises uninitialized constant error
CardDeck::NUM_CARDS # => raises uninitialized constant error

# `:transfer_nested_constants => true` transfers all nested constants:
stub_const("CardDeck", fake_class, :transfer_nested_constants => true)
CardDeck::SUITS # => [:spades, :diamonds, :clubs, :hearts]
CardDeck::NUM_CARDS # => 52

# Or you can specify a list of constants to transfer:
stub_const("CardDeck", fake_class, :transfer_nested_constants => [:SUITS])
CardDeck::SUITS # => [:spades, :diamonds, :clubs, :hearts]
CardDeck::NUM_CARDS # => raises uninitialized constant error
~~~

## Use Cases

I've found this useful in a few different situations:

* It provides a simple way to change a class setting expressed as
  a constant for one test. In the past, I've often defined static
  class methods just so they could be stubbed, even though it
  made more sense to use a constant. Now you can just use a constant!
* It makes dependency injection easy when the class-under-test
  depends on a collaborator's class method (e.g. when the collaborator
  is stateless). You can easily stub the collaborator's class constant
  with a test double.
* It makes stubbing unloaded dependencies dead-simple. Gary
  Bernhardt discussed this situation at length in [Destroy all
  Software #46](https://www.destroyallsoftware.com/screencasts/catalog/stubbing-unloaded-dependencies).
  He mentioned mutating constants as a possible way of stubbing unloaded
  dependencies, but recommended against it because of the complexity
  of safely managing this. Now that rspec-mocks can do it for you, it's
  far less complex, and much, much safer.

If you're curious how it all works, check out the [source on
github](https://github.com/rspec/rspec-mocks/blob/master/lib/rspec/mocks/stub_const.rb).

[^foot_1]: Actually, this has been available in [rspec-fire](https://github.com/xaviershay/rspec-fire) for a good four months or so. But it's not really a full mocking library...it builds on top of rspec-mocks, and now this functionality has been ported over to rspec-mocks.

