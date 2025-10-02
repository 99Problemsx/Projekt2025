#===============================================================================
# Custom Dirty Water Battle Background - Backdrop Override
#===============================================================================
# This file overrides the backdrop selection to properly handle the DirtyWater
# environment so that the correct battle background and message bar are used.
#===============================================================================

module BattleCreationHelperMethods
  module_function
  
  BattleCreationHelperMethods.singleton_class.alias_method :dirtywater_prepare_battle, :prepare_battle
  
  def prepare_battle(battle)
    BattleCreationHelperMethods.dirtywater_prepare_battle(battle)
    
    # Debug output
    echoln "=== DirtyWater Plugin Debug ==="
    echoln "Environment: #{battle.environment}"
    echoln "Backdrop BEFORE: #{battle.backdrop}"
    echoln "BackdropBase BEFORE: #{battle.backdropBase}"
    echoln "Surfing: #{$PokemonGlobal.surfing}"
    
    # Check if we're in the DirtyWater environment
    if battle.environment == :DirtyWater
      echoln ">> DirtyWater environment detected! Changing backdrop..."
      # Override the backdrop to use dirtywater instead of the default
      # This handles both surfing cases (where it defaults to "water")
      # and cave fishing cases (where it might use the cave backdrop)
      battle.backdrop = "dirtywater"
      
      # The backdropBase is already set correctly from the environment's battle_base
      # but we can ensure it here as well
      battle.backdropBase = "dirtywater"
      
      echoln "Backdrop AFTER: #{battle.backdrop}"
      echoln "BackdropBase AFTER: #{battle.backdropBase}"
    else
      echoln ">> NOT DirtyWater environment, no changes made"
    end
    echoln "==============================="
  end
end
