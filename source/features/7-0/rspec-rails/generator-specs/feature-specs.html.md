# Feature generator spec

## Feature generator

_When_ I run `bundle exec rails generate rspec:feature posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  spec/features/posts_spec.rb
```

## Feature generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate rspec:feature posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  behaviour/features/posts_spec.rb
```
