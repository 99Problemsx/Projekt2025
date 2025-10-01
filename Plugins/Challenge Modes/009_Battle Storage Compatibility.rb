#===============================================================================
# Battle Storage Compatibility Fix
# Ensures proper Pokemon storage for all battle types
#===============================================================================

class Battle
  # Override storage for all battle types compatibility
  alias challenge_modes_pbStorePokemon pbStorePokemon if method_defined?(:pbStorePokemon)
  def pbStorePokemon(pkmn)
    # Force normal party storage behavior for all battles
    # Check if party has space
    if $player.party.length < Settings::MAX_PARTY_SIZE
      return true  # Allow storage in party
    else
      return false # Party full, will go to PC
    end
  end
end
