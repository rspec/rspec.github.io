# `have_been_performed` matcher

The `have_been_performed` matcher is used to check if given ActiveJob job was performed.

## Background

_Given_ active job is available.

## Checking job class name

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with performed job" do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    UploadBackupsJob.perform_later
    expect(UploadBackupsJob).to have_been_performed
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
  it "matches with performed job" do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    UploadBackupsJob.perform_later("users-backup.txt", "products-backup.txt")
    expect(UploadBackupsJob).to(
      have_been_performed.with("users-backup.txt", "products-backup.txt")
    )
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking job performed time

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with performed job" do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
    UploadBackupsJob.set(:wait_until => Date.tomorrow.noon).perform_later
    expect(UploadBackupsJob).to have_been_performed.at(Date.tomorrow.noon)
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
  it "matches with performed job" do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    UploadBackupsJob.perform_later
    expect(UploadBackupsJob).to have_been_performed.on_queue("default")
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.
