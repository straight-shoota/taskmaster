class Taskmaster::Queue
  include Taskmaster::Adapter

  def initialize
    @queue = Deque(Taskmaster::Job).new
    @logger = Logger.new(STDOUT)
  end

  def enqueue(job : Job, **options)
    @queue << job

    @logger.info "Enqueued #{job} (queue: #{@queue.size})"
  end

  def run
    while job = next_job
      log "Performing #{job} (queue size: #{@queue.size})"
      begin
        Raven::Context.clear!
        Raven.tags_context({"job:name" => job.class.to_s, "job:args" => job.to_json})

        job.perform
      rescue exc
        Raven.capture(exc)
        error "#{exc.class}: #{exc}\n#{exc.backtrace.join("\n")}"
      ensure
        log "Finished job #{job}"

        Fiber.yield
      end
    end
  end

  def next_job
    @queue.shift?
  end

  def log(message, worker_number = 0)
    @logger.info message, "worker[#{worker_number}]"
  end

  def error(message, worker_number = 0)
    @logger.info message, "worker[#{worker_number}]"
  end
end
