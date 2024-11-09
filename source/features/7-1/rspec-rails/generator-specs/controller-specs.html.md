# Controller generator spec

## Controller generator

_When_ I run `bundle exec rails generate controller posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/controllers/posts_controller.rb
      invoke  erb
      create    app/views/posts
      invoke  rspec
      create    spec/requests/posts_spec.rb
      invoke  helper
      create    app/helpers/posts_helper.rb
      invoke    rspec
      create      spec/helpers/posts_helper_spec.rb
```

## Controller generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate controller posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/controllers/posts_controller.rb
      invoke  erb
      create    app/views/posts
      invoke  rspec
      create    behaviour/requests/posts_spec.rb
      invoke  helper
      create    app/helpers/posts_helper.rb
      invoke    rspec
      create      behaviour/helpers/posts_helper_spec.rb
```
