# Mailer generator spec

## Mailer generator

_When_ I run `bundle exec rails generate mailer posts index show`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/mailers/posts_mailer.rb
      invoke  erb
      create    app/views/posts_mailer
      create    app/views/posts_mailer/index.text.erb
      create    app/views/posts_mailer/index.html.erb
      create    app/views/posts_mailer/show.text.erb
      create    app/views/posts_mailer/show.html.erb
      invoke  rspec
      create    spec/mailers/posts_spec.rb
      create    spec/fixtures/posts/index
      create    spec/fixtures/posts/show
      create    spec/mailers/previews/posts_preview.rb
```

## Mailer generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate mailer posts index show`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/mailers/posts_mailer.rb
      invoke  erb
      create    app/views/posts_mailer
      create    app/views/posts_mailer/index.text.erb
      create    app/views/posts_mailer/index.html.erb
      create    app/views/posts_mailer/show.text.erb
      create    app/views/posts_mailer/show.html.erb
      invoke  rspec
      create    behaviour/mailers/posts_spec.rb
      create    behaviour/fixtures/posts/index
      create    behaviour/fixtures/posts/show
      create    behaviour/mailers/previews/posts_preview.rb
```
