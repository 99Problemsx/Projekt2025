# This is a basic autosave plugin for Pokémon Essentials

# Define your autosave interval in seconds
AUTOSAVE_INTERVAL = 30 # Autosave every 30 seconds

# Define the filename for the save file
SAVE_FILE_NAME = "Game.rxdata"

# Extend Game_Temp to support autosave blocking
class Game_Temp
  attr_accessor :no_autosave
end

# Define the plugin module
module AutosavePlugin
  # Start the autosave loop
  def self.start_autosave
    # Create a new thread for the autosave loop
    Thread.new do
      loop do
        # Sleep for the defined autosave interval
        sleep AUTOSAVE_INTERVAL

        # Perform the autosave
        autosave
      end
    end
  end

  # Perform the autosave
  def self.autosave
    # Only save if player exists and game is in a valid state
    return if !$player
    return if !$scene
    return if $game_temp&.in_battle
    return if $game_temp&.in_menu
    return if $game_temp&.message_window_showing
    return if $game_temp&.transition_processing
    
    # Don't save during critical plugin operations
    return if $game_temp&.no_autosave
    
    begin
      # Save the game data to the file
      SaveData.save_to_file(SaveData::FILE_PATH)
      echoln("Autosave: Game saved successfully")
    rescue => e
      echoln("Autosave: Failed to save game - #{e.message}")
    end
  end
end

# Call the method to start the autosave loop
AutosavePlugin.start_autosave
