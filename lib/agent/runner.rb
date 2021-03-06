require 'agent/worker'
require 'agent/scheduler'
require 'agent/work_schedule'

module Agent
  class Runner < Celluloid::SupervisionGroup

    supervise Agent::WorkSchedule, as: :work_schedule
    pool Agent::Worker, as: :worker, size: 10
    supervise Agent::Scheduler, as: :scheduler

    [:work_schedule, :scheduler, :worker].each do |actor|
      define_method actor do
        Actor[actor]
      end
    end
  end

end
