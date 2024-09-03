# Mailbox generator spec

## Mailbox generator

_When_ I run `bundle exec rails generate mailbox forwards`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/mailboxes/forwards_mailbox.rb
      invoke  rspec
      create    spec/mailboxes/forwards_mailbox_spec.rb
```

## Mailbox generator with customized `default-path`

_Given_ a file named ".rspec" with:

```
--default-path behaviour
```

_And_ I run `bundle exec rails generate mailbox forwards`

_Then_ the features should pass

_Then_ the output should contain:

```
      create  app/mailboxes/forwards_mailbox.rb
      invoke  rspec
      create    behaviour/mailboxes/forwards_mailbox_spec.rb
```
