# Job specs

Job specs provide alternative assertions to those available in `ActiveJob::TestHelper` and help assert behaviour of the jobs themselves and that other entities correctly enqueue them.

  Job specs are marked by `type: :job` or if you have set `config.infer_spec_type_from_file_location!` by placing them in `spec/jobs`.

  With job specs, you can:

  * specify the job class which was enqueued
  * specify the arguments passed to the job
  * specify when the job was enqueued until
  * specify the queue which the job was enqueued to

  Check the documentation on
  [`have_been_enqueued`](../matchers/have-been-enqueued-matcher),
  [`have_enqueued_job`](../matchers/have-enqueued-job-matcher),
  [`have_been_performed`](../matchers/have-been-performed-matcher), and
  [`have_performed_job`](../matchers/have-performed-job-matcher)
  for more information.

## Background

_Given_ active job is available.

## Specify that job was enqueued

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UploadBackupsJob.perform_later('backup')
      }.to have_enqueued_job
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## Specify that job was enqueued for the correct date and time

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UploadBackupsJob.set(wait_until: Date.tomorrow.noon, queue: "low").perform_later('backup')
      }.to have_enqueued_job.with('backup').on_queue("low").at(Date.tomorrow.noon)
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## Specify that job was enqueued with no wait

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UploadBackupsJob.set(queue: "low").perform_later('backup')
      }.to have_enqueued_job.with('backup').on_queue("low").at(:no_wait)
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## Specify that job was enqueued with alias block syntax

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        UploadBackupsJob.perform_later('backup')
      }.to enqueue_job
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## Specify that job was enqueued with imperative syntax

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      UploadBackupsJob.perform_later('backup')
      expect(UploadBackupsJob).to have_been_enqueued
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## Specify that job was enqueued with imperative syntax and a chained expectation

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :test
      UploadBackupsJob.perform_later('backup')
      expect(UploadBackupsJob).to have_been_enqueued.exactly(:once)
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should pass.

## The test adapter must be set to `:test`

_Given_ a file named "spec/jobs/upload_backups_job_spec.rb" with:

```ruby
require "rails_helper"

RSpec.describe UploadBackupsJob, type: :job do
  describe "#perform_later" do
    it "uploads a backup" do
      ActiveJob::Base.queue_adapter = :development
    end
  end
end
```

_When_ I run `rspec spec/jobs/upload_backups_job_spec.rb`

_Then_ the example should fail.
