# taskmaster

**Taskmaster** provides a simple API for declaring background jobs in [Crystal](https://crystal-lang.org).
It can be used with different backends for managing the job queue and workers.

This decouples the basic features of declaring and using jobs from specific
queue implementations.

It's essentially [Active Job](https://edgeguides.rubyonrails.org/active_job_basics.html)
for Crystal, maybe a bit less cluttered.

**The API design is in an early preview state. Contributions are welcome.**

## Why?

Without such a common API it would be difficult to combine shard A depending on
job queue X and shard B depending on job queue Y. If all A, B, X and Y implement
the Taskmaster API, A and B can be used together with either X or Y, whatever fits
best for the specific use case.

Besides, I want good testability for background jobs. The `Test` adapter makes
this really easy for any user of the Taskmaster API.

## Installation

1. Add the dependency to your `shard.yml`:
```yaml
dependencies:
  taskmaster:
    github: straight-shoota/taskmaster
```
2. perform `shards install`

## Usage

A job is any type (class or struct) that includes the `Taskmaster::Job`, implementing
an abstract method `#perform`.

```crystal
require "taskmaster"

struct HelloWorldJob
  include Taskmaster::Job

  def initialize(@name : String = "World")
  end

  def perform
    puts "Hello, #{@name}!"
  end
end

GreeterJob.new("Crystal").perform_later
```

## Backends

`Taskmaster` allows using different backends by implementing the `Taskmaster::Adapter`
interface which consists of only two methods: `#enqueue` and `#enqueue_at`.

### Included

This shard comes with two built-in adapters that provide backends only meant
for developing and testing:

* `Taskmaster::Adapter::Inline`: Executes the job immediately when it is enqueued. Blocks execution.
* `Taskmaster::Adapter::Test`: Collects enqueued jobs in an array for testing purposes.

* `Taskmaster::Adapter::Async` (TODO): Executes the job immediately in a new fiber when it is enqueued.

### Third-Party Job Queues

Adapters to third party job queues should be provided by the respecitve shards
implementing the backend, or in a separate connecting shard.

There are a number of shards providing background job queues in Crystal:

* [Dispatch](https://github.com/bmulvihill/dispatch) - in memory asynchronous job processing
* [faktory.cr](https://github.com/calebuharrison/faktory.cr) - A Faktory Worker library for Crystal
* [Mosquito](https://github.com/robacarp/mosquito) - A generic background task runner for crystal applications supporting periodic (CRON) and manually queued jobs
* [Onyx::Background](https://github.com/onyxframework/background/) - Fast background job processing
* [Ost](https://github.com/microspino/ost-crystal) - Ost (crystal lang port): Redis based queues and workers.
* [Sidekiq.cr](https://github.com/mperham/sidekiq.cr) - Simple, efficient job processing for Crystal

#### Feature Comparison

| Name             | Job Queue      | Worker implementation | Other features    |
|------------------|----------------|-----------------------|-------------------|
| Dispatch         | In memory      | Crystal               |                   |
| Faktory.cr       | Faktory Server | Faktory Client        | separate CLI, Web |
| Mosquito         | Redis          | Crystal               |                   |
| Onyx::Background | Redis          | Crystal               | CLI               |
| Ost              | Redis          | Crystal               |                   |
| Sidekiq.cr       | Redis          | Sidekiq Client        | CLI, Web          |
| *Async           | None           | Crystal               |                   |
| *Inline          | None           | Crystal               |                   |
| *Test            | In memory      | Crystal               |                   |


| Name             | Async | Queues | Delayed    | Priorities | Timeout | Retries |
|------------------|-------|--------|------------|------------|---------|---------|
| Dispatch         | Yes   | No     | Yes        | No         | No      | No      |
| Faktory.cr       | Yes   | Yes    | Yes        | Yes        | ?       | Yes     |
| Mosquito         | Yes   | Yes    | Yes        | ?          | ?       | Yes     |
| Onyx::Background | Yes   | Yes    | Yes        | No         | No      | ?       |
| Ost              | Yes   | Yes    | No         | No         | No      | ?       |
| Sidekiq.cr       | Yes   | Yes    | Yes        | ?          | ?       | ?       |
| *Async           | Yes   | Yes    | Yes        | No         | No      | No      |
| *Inline          | No    | N/A    | No         | No         | No      | No      |
| *Test            | N/A   | Yes    | Yes        | No         | No      | No      |

## Contributing

1. Fork it (<https://github.com/straight-shoota/taskmaster/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Johannes Müller](https://github.com/straight-shoota) - creator and maintainer
