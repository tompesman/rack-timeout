require RUBY_VERSION < '1.9' && RUBY_PLATFORM != 'java' ? 'system_timer' : 'timeout'
Timeout ||= SystemTimer

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
      t, path, req_id = self.class.timeout, env['REQUEST_PATH'], env['HTTP_HEROKU_REQUEST_ID']
      begin
        retval = ::Timeout.timeout(self.class.timeout, ::Timeout::Error) { @app.call(env) }
      rescue ::Timeout::Error
        log req_id, "request for %s aborted after a timeout of %d seconds. env: %s", path, t, env.inspect
        raise
      end
      retval
    end

    def log(req_id, s, *vs)
      $stderr.puts "rack-timeout:#{" request_id=#{req_id}" if req_id} #{s}" % vs
    end
  end
end