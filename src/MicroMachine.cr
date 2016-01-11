require "./MicroMachine/*"

module MicroMachine
  class InvalidEvent < Exception
  end

  class InvalidState < Exception
  end

  class MicroMachine

    getter transitions_for, state

    def initialize(initial_state)
      @state = initial_state
      @transitions_for = {} of Symbol => Hash(Symbol, Symbol)
      @callbacks = Hash(Symbol, Array(Proc(Void))).new { [] of Proc(Void) }
    end

    def on(key, &block)
      if !@callbacks.has_key?(key)
        @callbacks[key] = @callbacks[key]
      end
      @callbacks[key] << block
    end

    def when(event, transitions)
      transitions_for[event] = transitions
    end

    def trigger(event)
      change(event) if trigger?(event)
    end

    def trigger!(event)
      raise InvalidState.new("Event '#{event}' not valid from state '#{@state}'") unless
          trigger(event)
    end

    def trigger?(event)
      raise InvalidEvent.new unless transitions_for.has_key?(event)
      transitions_for[event].has_key?(state)
    end

    def events
      transitions_for.keys
    end

    def states
      transitions_for.values.map(&.to_a).flatten.uniq
    end

    private def change(event)
      @state = transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback| callback.call }
      true
    end
  end
end
