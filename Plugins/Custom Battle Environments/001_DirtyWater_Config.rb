#===============================================================================
# Custom Dirty Water Battle Background Configuration
#===============================================================================
# This plugin adds support for custom DirtyWater environment with proper
# battle backgrounds and message bars.
#===============================================================================

# Register the terrain tag
GameData::TerrainTag.register({
  :id => :Dirty_Water,
  :id_number => 31,
  :can_surf => true,
  :can_fish => true,
  :battle_environment => :DirtyWater,
})

# Register the environment
GameData::Environment.register({
  :id => :DirtyWater,
  :name => _INTL("Dirty Water"),
  :battle_base => "dirtywater",
})
