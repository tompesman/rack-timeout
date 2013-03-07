require RUBY_VERSION < '1.9' && RUBY_PLATFORM != "java" ? 'system_timer' : 'timeout'
SystemTimer ||= Timeout

module Rack
  class Timeout
    @timeout = 15
    class << self
      attr_accessor :timeout
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = SystemTimer.timeout(self.class.timeout, ::Timeout::Error) { @app.call(env) }
      Rails.logger.info "Timeout::Error env: #{env}" if status == 500
      [status, headers, response]
    end

  end
end
