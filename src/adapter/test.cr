class Taskmaster::Adapter::Test
  include Adapter

  record Task, id : Int32, perform_at : Time?, name : String, arguments : String, options : String

  getter queued_tasks = [] of Task

  def enqueue(job : Job, **options)
    task = Task.new(next_id, nil, job.class.to_s, job.to_json, options.to_json)
    @queued_tasks << task
  end

  def enqueue_at(time : Time, job : Job, **options)
    task = Task.new(next_id, time, job.class.to_s, job.to_json, options.to_json)
    @queued_tasks << task
  end

  @last_id = 0

  def next_id
    @last_id += 1
  end

  def clear
    @queued_tasks.clear
    @last_id = 0
  end
end
