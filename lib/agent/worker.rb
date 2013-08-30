module Agent
  class Worker
    class OptionError < StandardError; end

    include Celluloid

    attr_reader :work_class, :work_method, :work_arguments,
      :handler_class, :handler_method

    def perform(opts={})
      set_work_options(opts)

      output =  if work_arguments
                  perform_with_arguments
                else
                  perform_without_arguments
                end

      run_local_handler(output)
      run_global_handler(output)
    end

  private

    def set_work_options(opts={})
      [:work_class, :work_method].each do |opt|
        raise OptionError, "Missing option #{opt}" unless opts[opt]
      end

      @work_class = opts[:work_class]
      @work_method = opts[:work_method] || :perform
      @work_arguments = opts[:work_arguments]
      @handler_class = opts[:handler_class] || work_class
      @handler_method = opts[:handleer_method] || :handle
    end

    def run_local_handler(output)
      if handler_class.respond_to?(handler_method)
        handler_class.async.public_send(handler_method, output)
      end
    end

    def run_global_handler(output)
      Agent::Handler.async.call(output)
    end


    def perform_with_arguments
      work_class.public_send(work_method, *work_arguments)
    end

    def perform_without_arguments
      work_class.public_send(work_method)
    end
  end
end
