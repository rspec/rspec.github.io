# Action mailbox specs

Mailbox specs provide alternative assertions to those available in `ActiveMailbox::TestHelper` and help assert behaviour of how the email
  are routed, delivered, bounced or failed.

  Mailbox specs are marked by `type: :mailbox` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/mailboxes`.

  With mailbox specs you can:
  * `process(mail_or_attributes)` - send mail directly to the mailbox under test for `process`ing.
  * `receive_inbound_email(mail_or_attributes)` - matcher for asserting whether incoming email would route to the mailbox under test.
  * `have_been_delivered` - matcher for asserting whether an incoming email object was delivered.
  * `have_bounced` - matcher for asserting whether an incoming email object has bounced.
  * `have_failed` - matcher for asserting whether an incoming email object has failed.

## Background

_Given_ action mailbox is available.

## Simple testing mail properly routed

_Given_ a file named "app/mailboxes/application_mailbox.rb" with:

```ruby
class ApplicationMailbox < ActionMailbox::Base
  routing (/^replies@/i) => :inbox
end
```

_And_ a file named "app/maiboxes/inbox_mailbox.rb" with:

```ruby
class InboxMailbox < ApplicationMailbox
  def process
    case mail.subject
    when (/^\[\d*\]/i)
      # ok
    when (/^\[\w*\]/i)
      bounced!
    else
      raise "Invalid email subject"
    end
  end
end
```

_And_ a file named "spec/mailboxes/inbox_mailbox_spec.rb" with:

```ruby
require 'rails_helper'

RSpec.describe InboxMailbox, type: :mailbox do
  it "route email to properly mailbox" do
    expect(InboxMailbox)
      .to receive_inbound_email(to: "replies@example.com")
  end

  it "marks email as delivered when number tag in subject is valid" do
    mail = Mail.new(
      from: "replies@example.com",
      subject: "[141982763] support ticket"
    )
    mail_processed = process(mail)

    expect(mail_processed).to have_been_delivered
  end

  it "marks email as bounced when number tag in subject is invalid" do
    mail = Mail.new(
      from: "replies@example.com",
      subject: "[111X] support ticket"
    )
    mail_processed = process(mail)

    expect(mail_processed).to have_bounced
  end

  it "marks email as failed when subject is invalid" do
    mail = Mail.new(
      from: "replies@example.com",
      subject: "INVALID"
    )

    expect {
      expect(process(mail)).to have_failed
    }.to raise_error(/Invalid email subject/)
  end
end
```

_When_ I run `rspec spec/mailboxes/inbox_mailbox_spec.rb`

_Then_ the example should pass.
