# System generator spec

## System generator

_When_ I run `bundle exec rails generate rspec:system posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  spec/system/posts_spec.rb
```

## System generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate rspec:system posts`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  behaviour/system/posts_spec.rb
```
