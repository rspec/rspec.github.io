# Channel generator spec

## Channel generator

_When_ I run `bundle exec rails generate channel group`

_Then_ the features should pass

_Then_ the output should contain:

```
      invoke  rspec
      create    spec/channels/group_channel_spec.rb
```

_Then_ the output should contain:

```
      create  app/channels/group_channel.rb
```

## Channel generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate channel group`

_Then_ the features should pass

_Then_ the output should contain:

```
      invoke  rspec
      create    behaviour/channels/group_channel_spec.rb
```

_Then_ the output should contain:

```
      create  app/channels/group_channel.rb
```
