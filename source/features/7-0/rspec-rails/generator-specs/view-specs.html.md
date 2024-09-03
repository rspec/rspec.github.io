# View generator spec

## View generator

_When_ I run `bundle exec rails generate rspec:view posts index`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  spec/views/posts
      create  spec/views/posts/index.html.erb_spec.rb
```

## View generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate rspec:view posts index`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  behaviour/views/posts
      create  behaviour/views/posts/index.html.erb_spec.rb
```
