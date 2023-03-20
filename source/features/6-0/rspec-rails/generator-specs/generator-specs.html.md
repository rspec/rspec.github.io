# Generator spec

RSpec spec(s) can be generated when generating application components. For instance, `rails generate model` will also generate an RSpec spec file for the model but you can also write your own generator. See [customizing your workflow](https://guides.rubyonrails.org/generators.html#customizing-your-workflow)

## Use custom generator

_When_ I run `bundle exec rails generate generator my_generator`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  lib/generators/my_generator
      create  lib/generators/my_generator/my_generator_generator.rb
      create  lib/generators/my_generator/USAGE
      create  lib/generators/my_generator/templates
      invoke  rspec
      create    spec/generator/my_generators_generator_spec.rb
```

## Use custom generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate generator my_generator`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  lib/generators/my_generator
      create  lib/generators/my_generator/my_generator_generator.rb
      create  lib/generators/my_generator/USAGE
      create  lib/generators/my_generator/templates
      invoke  rspec
      create    behaviour/generator/my_generators_generator_spec.rb
```
