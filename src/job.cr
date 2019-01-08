require "json"

module Taskmaster::Job
  macro included
    include JSON::Serializable

    class_property? queue_adapter : ::Taskmaster::Adapter? = nil
  end

  abstract def perform

  def perform_later(**options)
    Taskmaster.enqueue(self, **options)
  end
end
