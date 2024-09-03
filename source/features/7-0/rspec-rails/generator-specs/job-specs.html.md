# Job generator spec

## Job generator

_When_ I run `bundle exec rails generate job user`

_Then_ the features should pass

_Then_ the output should contain:

```
      invoke  rspec
      create    spec/jobs/user_job_spec.rb
      create  app/jobs/user_job.rb
```

## Job generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate job user`

_Then_ the features should pass

_Then_ the output should contain:

```
      invoke  rspec
      create    behaviour/jobs/user_job_spec.rb
      create  app/jobs/user_job.rb
```
