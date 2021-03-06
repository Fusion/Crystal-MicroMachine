require "../src/*"

fsm = MicroMachine::MicroMachine.new(:pending)

fsm.when(:confirm,  {:pending => :confirmed})
fsm.when(:ignore,   {:pending => :ignored})
fsm.when(:reset,    {:confirmed => :pending, :ignored => :pending})

puts "Should print Confirmed, Pending and Ignored:"

fsm.on(:any) do
  puts fsm.state
end

fsm.trigger(:confirm)

fsm.trigger(:ignore)

fsm.trigger(:reset)

fsm.trigger(:ignore)

puts "Should print all states: pending, confirmed, ignored"

puts fsm.states.join ", "

puts "Should print all events: confirm, ignore, reset"

puts fsm.events.join ", "
