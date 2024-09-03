# `have_performed_job` matcher

The `have_performed_job` (also aliased as `perform_job`) matcher is used to check if given ActiveJob job was performed.

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
    expect {
      UploadBackupsJob.perform_later
    }.to have_performed_job(UploadBackupsJob)
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
    expect {
      UploadBackupsJob.perform_later("users-backup.txt", "products-backup.txt")
    }.to have_performed_job.with("users-backup.txt", "products-backup.txt")
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
    expect {
      UploadBackupsJob.set(:wait_until => Date.tomorrow.noon).perform_later
    }.to have_performed_job.at(Date.tomorrow.noon)
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
    expect {
      UploadBackupsJob.perform_later
    }.to have_performed_job.on_queue("default")
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Using alias method

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with performed job" do
    ActiveJob::Base.queue_adapter = :test
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    expect {
      UploadBackupsJob.perform_later
    }.to perform_job(UploadBackupsJob)
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.
