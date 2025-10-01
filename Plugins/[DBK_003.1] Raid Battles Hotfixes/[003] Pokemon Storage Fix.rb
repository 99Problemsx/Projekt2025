#===============================================================================
# Pokemon Storage Parameter Fix
# Fixes parameter mismatch errors in raid pokemon storage methods
#===============================================================================

class Battle
  # Fix dx_pbStorePokemon to accept pkmn parameter
  alias hotfix_dx_pbStorePokemon dx_pbStorePokemon if method_defined?(:dx_pbStorePokemon)
  def dx_pbStorePokemon(pkmn)
    if respond_to?(:hotfix_dx_pbStorePokemon)
      hotfix_dx_pbStorePokemon(pkmn)
    else
      # Fallback implementation
      return false if !pkmn
      stored = pbStorePokemon(pkmn)
      return stored
    end
  end
  
  # Fix raid_pbStorePokemon to accept pkmn parameter  
  alias hotfix_raid_pbStorePokemon raid_pbStorePokemon if method_defined?(:raid_pbStorePokemon)
  def raid_pbStorePokemon(pkmn)
    if respond_to?(:hotfix_raid_pbStorePokemon)
      hotfix_raid_pbStorePokemon(pkmn)
    else
      # Fallback implementation
      return false if !pkmn
      stored = pbStorePokemon(pkmn)
      return stored
    end
  end
end