# `have_been_enqueued` matcher

The `have_been_enqueued` matcher is used to check if given ActiveJob job was enqueued.

## Background

_Given_ active job is available.

## Checking job class name

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    UploadBackupsJob.perform_later
    expect(UploadBackupsJob).to have_been_enqueued
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking passed arguments to job

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    UploadBackupsJob.perform_later("users-backup.txt", "products-backup.txt")
    expect(UploadBackupsJob).to(
      have_been_enqueued.with("users-backup.txt", "products-backup.txt")
    )
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking job enqueued time

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    UploadBackupsJob.set(:wait_until => Date.tomorrow.noon).perform_later
    expect(UploadBackupsJob).to have_been_enqueued.at(Date.tomorrow.noon)
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking job enqueued with no wait

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    UploadBackupsJob.perform_later
    expect(UploadBackupsJob).to have_been_enqueued.at(:no_wait)
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking job queue name

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    UploadBackupsJob.perform_later
    expect(UploadBackupsJob).to have_been_enqueued.on_queue("default")
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.
