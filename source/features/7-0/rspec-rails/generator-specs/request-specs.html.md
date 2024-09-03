# Request generator spec

## Request generator

_When_ I run `bundle exec rails generate rspec:request posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  spec/requests/posts_spec.rb
```

## Request generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate rspec:request posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  behaviour/requests/posts_spec.rb
```
