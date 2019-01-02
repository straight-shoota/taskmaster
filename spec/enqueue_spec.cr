require "spec"
require "../src/taskmaster"
require "../src/adapter/inline"
require "../src/adapter/test"

struct HelloJob
  include Taskmaster::Job

  class_getter values = [] of String

  def initialize(@name = "World")
  end

  def perform
    @@values << "Hello, #{@name}"
  end
end

Spec.before_each do
  if adapter = Taskmaster.adapter.as?(Taskmaster::Adapter::Test)
    adapter.clear
  end
end

describe Taskmaster do
  describe ".enqueue" do
    test_adapter = Taskmaster::Adapter::Test.new
    Taskmaster.adapter = test_adapter

    it "enqueues job" do
      HelloJob.new.perform_later

      test_adapter.queued_tasks.size.should eq 1
      test_adapter.queued_tasks.first.name.should eq "HelloJob"
      test_adapter.queued_tasks.first.arguments.should eq %({"name":"World"})
    end

    it "performs job with arguments" do
      HelloJob.new("David").perform_later

      test_adapter.queued_tasks.size.should eq 1
      test_adapter.queued_tasks.first.name.should eq "HelloJob"
      test_adapter.queued_tasks.first.arguments.should eq %({"name":"David"})
    end
  end

  describe "perform job" do
    Taskmaster.adapter = Taskmaster::Adapter::Inline.new

    it "performs job" do
      HelloJob.values.clear
      HelloJob.new.perform_later

      HelloJob.values.should eq ["Hello, World"]
    end

    it "performs job with arguments" do
      HelloJob.values.clear
      HelloJob.new("David").perform_later

      HelloJob.values.should eq ["Hello, David"]
    end
  end
end
