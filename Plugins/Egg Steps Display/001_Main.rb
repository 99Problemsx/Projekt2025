#===============================================================================
# Egg Steps Display EX
# Shows exact step counts for eggs in party and summary screens
#===============================================================================

module EggStepsDisplay
  # Plugin version
  VERSION = "1.0"
  
  # Configuration
  SHOW_IN_PARTY = true          # Show steps in party screen
  SHOW_IN_SUMMARY = true        # Show steps in summary screen  
  SHOW_PROGRESS_BAR = true      # Show progress bar
  SHOW_LIVE_OVERLAY = false     # Show overlay while walking (optional)
  
  # Colors for progress bar
  PROGRESS_BAR_EMPTY = Color.new(100, 100, 100)    # Gray
  PROGRESS_BAR_FULL = Color.new(50, 200, 50)       # Green
  PROGRESS_BAR_ALMOST = Color.new(255, 200, 0)     # Yellow when < 100 steps
  
  #-----------------------------------------------------------------------------
  # Get remaining steps for an egg
  #-----------------------------------------------------------------------------
  def self.get_remaining_steps(pokemon)
    return 0 if !pokemon.egg?
    return pokemon.steps_to_hatch
  end
  
  #-----------------------------------------------------------------------------
  # Get total steps needed for this egg species
  #-----------------------------------------------------------------------------
  def self.get_total_steps(pokemon)
    return 0 if !pokemon.egg?
    return pokemon.species_data.hatch_steps
  end
  
  #-----------------------------------------------------------------------------
  # Get progress percentage (0-100)
  #-----------------------------------------------------------------------------
  def self.get_progress_percentage(pokemon)
    return 0 if !pokemon.egg?
    total_steps = get_total_steps(pokemon)
    remaining_steps = get_remaining_steps(pokemon)
    return 0 if total_steps <= 0
    
    progress = ((total_steps - remaining_steps).to_f / total_steps * 100).round
    return [progress, 100].min
  end
  
  #-----------------------------------------------------------------------------
  # Format steps text for display
  #-----------------------------------------------------------------------------
  def self.format_steps_text(pokemon)
    return "" if !pokemon.egg?
    
    remaining = get_remaining_steps(pokemon)
    if remaining <= 0
      return _INTL("Ready to hatch!")
    elsif remaining == 1
      return _INTL("1 step remaining")
    else
      return _INTL("{1} steps remaining", remaining)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Get appropriate color for steps text
  #-----------------------------------------------------------------------------
  def self.get_steps_color(pokemon)
    return Color.new(0, 0, 0) if !pokemon.egg?
    
    remaining = get_remaining_steps(pokemon)
    if remaining <= 0
      return Color.new(0, 150, 0)     # Green - ready to hatch
    elsif remaining <= 100
      return Color.new(255, 150, 0)   # Orange - close
    elsif remaining <= 500
      return Color.new(200, 100, 0)   # Yellow - getting there
    else
      return Color.new(100, 100, 100) # Gray - still a while
    end
  end
  
  #-----------------------------------------------------------------------------
  # Draw progress bar
  #-----------------------------------------------------------------------------
  def self.draw_progress_bar(bitmap, x, y, width, height, pokemon)
    return if !pokemon.egg? || !SHOW_PROGRESS_BAR
    
    # Background
    bitmap.fill_rect(x, y, width, height, Color.new(0, 0, 0))
    bitmap.fill_rect(x + 1, y + 1, width - 2, height - 2, PROGRESS_BAR_EMPTY)
    
    # Progress fill
    progress = get_progress_percentage(pokemon)
    fill_width = ((width - 2) * progress / 100).to_i
    
    if progress >= 100
      color = PROGRESS_BAR_FULL
    elsif get_remaining_steps(pokemon) <= 100
      color = PROGRESS_BAR_ALMOST
    else
      color = PROGRESS_BAR_FULL
    end
    
    bitmap.fill_rect(x + 1, y + 1, fill_width, height - 2, color)
  end
end

#===============================================================================
# Live step counter overlay (optional)
#===============================================================================
class EggStepsOverlay
  def initialize
    @visible = false
    @egg_pokemon = nil
    create_sprites
  end
  
  def create_sprites
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Bitmap.new(200, 60)
    @sprites["background"].bitmap.fill_rect(0, 0, 200, 60, Color.new(0, 0, 0, 180))
    @sprites["background"].x = Graphics.width - 210
    @sprites["background"].y = 10
    @sprites["background"].visible = false
    
    @sprites["text"] = Sprite.new(@viewport)
    @sprites["text"].bitmap = Bitmap.new(180, 40)
    @sprites["text"].x = Graphics.width - 200
    @sprites["text"].y = 20
    @sprites["text"].visible = false
  end
  
  def update
    return if !@visible || !EggStepsDisplay::SHOW_LIVE_OVERLAY
    
    # Find first egg in party
    current_egg = nil
    $player.party.each do |pokemon|
      if pokemon.egg?
        current_egg = pokemon
        break
      end
    end
    
    if current_egg != @egg_pokemon
      @egg_pokemon = current_egg
      refresh_display
    end
  end
  
  def refresh_display
    return if !@sprites["text"].bitmap
    
    @sprites["text"].bitmap.clear
    
    if @egg_pokemon
      text = EggStepsDisplay.format_steps_text(@egg_pokemon)
      color = EggStepsDisplay.get_steps_color(@egg_pokemon)
      @sprites["text"].bitmap.font.size = 18
      @sprites["text"].bitmap.font.color = color
      @sprites["text"].bitmap.draw_text(0, 0, 180, 20, text, 1)
      
      # Progress bar
      EggStepsDisplay.draw_progress_bar(@sprites["text"].bitmap, 10, 25, 160, 8, @egg_pokemon)
    end
  end
  
  def show
    @visible = true
    @sprites["background"].visible = true if @sprites["background"]
    @sprites["text"].visible = true if @sprites["text"]
    refresh_display
  end
  
  def hide
    @visible = false
    @sprites["background"].visible = false if @sprites["background"]
    @sprites["text"].visible = false if @sprites["text"]
  end
  
  def dispose
    @sprites.each_value { |sprite| sprite.dispose }
    @viewport.dispose
  end
end

# Global overlay instance
$egg_steps_overlay = nil

#===============================================================================
# Initialize overlay when game starts
#===============================================================================
EventHandlers.add(:on_game_map_setup, :egg_steps_overlay_setup,
  proc { |map_id|
    $egg_steps_overlay = EggStepsOverlay.new if !$egg_steps_overlay
  }
)

#===============================================================================
# Update overlay during gameplay
#===============================================================================
EventHandlers.add(:on_step_taken, :egg_steps_overlay_update,
  proc {
    $egg_steps_overlay.update if $egg_steps_overlay
    $egg_steps_overlay.refresh_display if $egg_steps_overlay
  }
) 