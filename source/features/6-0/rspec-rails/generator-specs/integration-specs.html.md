# Integration generator spec

## Integration generator

_When_ I run `bundle exec rails generate rspec:integration posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  spec/requests/posts_spec.rb
```

## Integration generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate rspec:integration posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  behaviour/requests/posts_spec.rb
```
