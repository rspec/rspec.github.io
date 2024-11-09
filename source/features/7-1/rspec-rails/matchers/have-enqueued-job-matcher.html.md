# `have_enqueued_job` matcher

The `have_enqueued_job` (also aliased as `enqueue_job`) matcher is used to check if given ActiveJob job was enqueued.

## Background

_Given_ active job is available.

## Checking job class name

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      UploadBackupsJob.perform_later
    }.to have_enqueued_job(UploadBackupsJob)
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
    expect {
      UploadBackupsJob.perform_later("users-backup.txt", "products-backup.txt")
    }.to have_enqueued_job.with("users-backup.txt", "products-backup.txt")
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.

## Checking passed arguments to job, using a block

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob do
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      UploadBackupsJob.perform_later('backups.txt', rand(100), 'uninteresting third argument')
    }.to have_enqueued_job.with { |file_name, seed|
      expect(file_name).to eq 'backups.txt'
      expect(seed).to be < 100
    }
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
    expect {
      UploadBackupsJob.set(:wait_until => Date.tomorrow.noon).perform_later
    }.to have_enqueued_job.at(Date.tomorrow.noon)
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
    expect {
      UploadBackupsJob.perform_later
    }.to have_enqueued_job.at(:no_wait)
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
    expect {
      UploadBackupsJob.perform_later
    }.to have_enqueued_job.on_queue("default")
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
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      UploadBackupsJob.perform_later
    }.to enqueue_job(UploadBackupsJob)
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the examples should all pass.
