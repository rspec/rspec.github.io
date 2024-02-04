# Helper generator spec

## Helper generator

_When_ I run `bundle exec rails generate helper posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/helpers/posts_helper.rb
      invoke  rspec
      create    spec/helpers/posts_helper_spec.rb
```

## Helper generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate helper posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/helpers/posts_helper.rb
      invoke  rspec
      create    behaviour/helpers/posts_helper_spec.rb
```
