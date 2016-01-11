require "../src/*"

fsm = MicroMachine::MicroMachine.new(:pending)

fsm.when(:confirm,  {:pending => :confirmed})
fsm.when(:ignore,   {:pending => :ignored})
fsm.when(:reset,    {:confirmed => :pending, :ignored => :pending})

puts "Should print Confirmed, Reset and Ignored:"

if fsm.trigger(:confirm)
  puts "Confirmed"
end

if fsm.trigger(:ignore)
  puts "Ignored"
end

if fsm.trigger(:reset)
  puts "Reset"
end

if fsm.trigger(:ignore)
  puts "Ignored"
end
