require "./MicroMachine/*"

module MicroMachine
  class InvalidEvent < Exception
  end

  class InvalidState < Exception
  end

  class MicroMachine

    # Properties v. Attributes: getter replaces _attr_reader
    getter transitions_for, state

    def initialize(initial_state)
      @state = initial_state
      # In Crystal, Duck typing works to a certain point.
      # This can be originally irritating, until you realize that forcing
      # us to specify types means that most type confusions will cause the
      # program to fail at compile time rather than in production.
      @transitions_for = {} of Symbol => Hash(Symbol, Symbol)
      @callbacks = Hash(Symbol, Array(Proc(Void))).new { [] of Proc(Void) }
    end

    def on(key, &block)
      # Added this default initialization as the block passed in the
      # constructor would not be invoked upon a "set" operation
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
      # Ruby allows you to use "and" and "or" as you would in Bash, to mark
      # success/failure conditions. Using "if" and "unless" instead.
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
      # Note how we can also invoke a mapped function. In Ruby, we would use
      # "&:" as long as our object responds to to_proc
      # In Crystal, we use "&." which is syntactic sugar for an actual block.
      transitions_for.values.map(&.to_a).flatten.uniq
    end

    private def change(event)
      @state = transitions_for[event][@state]
      callbacks = @callbacks[@state] + @callbacks[:any]
      # The Ruby code would not compile "as is" as it did not seem to know
      # whether to expect a parameter (event) or not. Opting for the latter,
      # which seem cleaner in a state machine.
      callbacks.each { |callback| callback.call }
      true
    end
  end
end
