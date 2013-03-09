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
      t0, t, path = Time.now.utc, self.class.timeout, env['REQUEST_PATH']
      begin
        log "about to start handling request for %s with a timeout of %d seconds.", path, t
        retval = ::Timeout.timeout(self.class.timeout, ::Timeout::Error) { @app.call(env) }
        t1 = Time.now.utc
      rescue ::Timeout::Error
        log "request for %s aborted after a timeout of %d seconds.", path, t
        log "request env: %s", env.inspect
        raise
      end
      log "request for %s completed in about %0.2f seconds.", path, (t1 - t0)
      retval
    end

    def log(s, *vs)
      $stderr.puts "rack-timeout: #{s}" % vs
    end

  end
end