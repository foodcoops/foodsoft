raise "Remove no-longer-needed #{__FILE__}!" if Rails::VERSION::MAJOR >= 6

require "weakref"

module ActiveRecord
  # Backport https://github.com/rails/rails/pull/36998 and https://github.com/rails/rails/pull/36999
  # to avoid `ThreadError: can't create Thread: Resource temporarily unavailable` issues
  module ConnectionAdapters
    class ConnectionPool
      class Reaper
        @mutex = Mutex.new
        @pools = {}
        @threads = {}

        class << self
          def register_pool(pool, frequency) # :nodoc:
            @mutex.synchronize do
              unless @threads[frequency]&.alive?
                @threads[frequency] = spawn_thread(frequency)
              end
              @pools[frequency] ||= []
              @pools[frequency] << WeakRef.new(pool)
            end
          end

          private

          def spawn_thread(frequency)
            Thread.new(frequency) do |t|
              running = true
              while running
                sleep t
                @mutex.synchronize do
                  @pools[frequency].select!(&:weakref_alive?)
                  @pools[frequency].each do |p|
                    p.reap
                    p.flush
                  rescue WeakRef::RefError
                  end

                  if @pools[frequency].empty?
                    @pools.delete(frequency)
                    @threads.delete(frequency)
                    running = false
                  end
                end
              end
            end
          end
        end

        def run
          return unless frequency && frequency > 0

          self.class.register_pool(pool, frequency)
        end
      end

      def reap
        stale_connections = synchronize do
          return unless @connections

          @connections.select do |conn|
            conn.in_use? && !conn.owner.alive?
          end.each(&:steal!)
        end

        stale_connections.each do |conn|
          if conn.active?
            conn.reset!
            checkin conn
          else
            remove conn
          end
        end
      end

      def flush(minimum_idle = @idle_timeout)
        return if minimum_idle.nil?

        idle_connections = synchronize do
          return unless @connections

          @connections.select do |conn|
            !conn.in_use? && conn.seconds_idle >= minimum_idle
          end.each do |conn|
            conn.lease

            @available.delete conn
            @connections.delete conn
          end
        end

        idle_connections.each(&:disconnect!)
      end
    end
  end
end
