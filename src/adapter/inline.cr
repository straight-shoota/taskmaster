class Taskmaster::Adapter::Inline
  include Adapter

  record Task, id : Int32, name : String, arguments : String, options : String

  getter tasks = [] of Task

  def enqueue(job : Job, **options)
    # task = Task.new(next_id, job.class.to_s, job.to_json, options.to_json)
    # tasks << task
    job.perform
  end

  def enqueue_at(time : Time, job : Job, **options)
    raise "#enqueue_at is not supported by Inline adapter"
  end

  # @last_id = 0
  # def next_id
  #   @last_id += 1
  # end
end
