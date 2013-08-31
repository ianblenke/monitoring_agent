require 'bundler/setup'
Bundler.require(:default, (ENV['RACK_ENV'] || :development))
require 'ostruct'

require 'agent/runner'
require 'agent/relation_proxy'
require 'agent/host'
require 'agent/check_agent'

module Agent
  class << self
    def runner
      @runner
    end

    def start
      cleanup_runner
      @runner ||= Runner.run
    end

    def start!
      cleanup_runner
      @runner ||= Runner.run!
    end


    def stop
      @runner.terminate
    ensure
      cleanup_runner
    end

  private

    def cleanup_runner
      if @runner && !@runner.alive?
        @runner = nil
      end
    end

  end
end
