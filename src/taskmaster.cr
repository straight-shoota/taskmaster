require "./job"

module Taskmaster
  VERSION = "0.1.0"

  class_property! adapter : Adapter

  def self.enqueue(job : Job, **options)
    adapter = job.class.queue_adapter? || self.adapter
    adapter.enqueue(job, **options)
  end

  module Adapter
    abstract def enqueue(job : Job, **options)
  end
end
