class Tournament < Map
  extend Forwardable

  attr_reader :machine, :timer

  class TournamentMachine
    include Celluloid::FSM

    default_state :waiting

    state :waiting, :to => :running
    state :running, :to => :game_over do
      actor.async.run
    end
  end

  def_delegator :machine, :transition
  def_delegator :machine, :state

  def initialize(options={})
    @machine = TournamentMachine.new
    super options
  end

  def start
    @clients.each { |c| c.broadcast_participants(@clients) }
    transition(:running)
  end

  def handle_death(victim, killer=nil)
    remaining = @clients - [victim]

    if remaining.count == 1
      terminate
    end
  end

end