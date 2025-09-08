#===============================================================================
# UI Integration for Egg Steps Display
# Adds egg step display to party screen and summary screen using MUI system
#===============================================================================

# Party Screen Integration - DISABLED
# All party screen integration has been disabled per user request

#===============================================================================
# MUI Summary Screen Integration - extending existing handlers
#===============================================================================

# Replace the existing egg page layout with step display
class PokemonSummary_Scene
  alias __egg_steps__drawPageOneEgg drawPageOneEgg unless method_defined?(:__egg_steps__drawPageOneEgg)
  
  def drawPageOneEgg
    return if !EggStepsDisplay::SHOW_IN_SUMMARY
    
    # Draw the basic page without the egg state text
    red_text_tag = shadowc3tag(RED_TEXT_BASE, RED_TEXT_SHADOW)
    black_text_tag = shadowc3tag(BLACK_TEXT_BASE, BLACK_TEXT_SHADOW)
    memo = ""
    if @pokemon.timeReceived
      date  = @pokemon.timeReceived.day
      month = pbGetMonthName(@pokemon.timeReceived.mon)
      year  = @pokemon.timeReceived.year
      memo += black_text_tag + _INTL("{1} {2}, {3}", date, month, year) + "\n"
    end
    mapname = pbGetMapNameFromId(@pokemon.obtain_map)
    mapname = @pokemon.obtain_text if @pokemon.obtain_text && !@pokemon.obtain_text.empty?
    if mapname && mapname != ""
      mapname = red_text_tag + mapname + black_text_tag
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg received from {1}.", mapname) + "\n"
    else
      memo += black_text_tag + _INTL("A mysterious Pokémon Egg.") + "\n"
    end
    memo += "\n"
    memo += black_text_tag + _INTL("\"The Egg Watch\"") + "\n"
    
    # Replace the standard egg state with exact step count
    remaining = EggStepsDisplay.get_remaining_steps(@pokemon)
    
    if remaining <= 0
      memo += black_text_tag + _INTL("This Egg is ready to hatch!")
    elsif remaining == 1
      memo += black_text_tag + _INTL("This Egg needs just 1 more step to hatch!")
    elsif remaining <= 100
      memo += black_text_tag + _INTL("This Egg is very close to hatching! Only {1} steps remain.", remaining)
    elsif remaining <= 500
      memo += black_text_tag + _INTL("This Egg is getting close to hatching. {1} steps remain.", remaining)
    else
      memo += black_text_tag + _INTL("This Egg still needs {1} steps to hatch.", remaining)
    end
    
    drawFormattedTextEx(@sprites["overlay"].bitmap, 232, 86, 268, memo)
  end
end

# For non-MUI systems with eggs on info page - add minimal display
class PokemonSummary_Scene
  alias __egg_steps__drawPageOne drawPageOne unless method_defined?(:__egg_steps__drawPageOne)
  
  def drawPageOne
    __egg_steps__drawPageOne
    
    # Add minimal egg step display for eggs on info page (fallback for non-MUI)
    return if !EggStepsDisplay::SHOW_IN_SUMMARY || !@pokemon.egg?
    
    overlay = @sprites["overlay"].bitmap
    
    # Add simple egg step info at bottom
    remaining = EggStepsDisplay.get_remaining_steps(@pokemon)
    
    # Position at bottom of screen
    y_pos = Graphics.height - 40
    
    # Simple text display
    text = EggStepsDisplay.format_steps_text(@pokemon)
    color = EggStepsDisplay.get_steps_color(@pokemon)
    overlay.font.size = 16
    overlay.font.color = color
    overlay.draw_text(20, y_pos, Graphics.width - 40, 20, text, 1)
  end
end





#===============================================================================
# Commands to toggle overlay
#===============================================================================
def pbToggleEggStepsOverlay
  if $egg_steps_overlay
    if $egg_steps_overlay.instance_variable_get(:@visible)
      $egg_steps_overlay.hide
      pbMessage(_INTL("Egg steps overlay hidden."))
    else
      $egg_steps_overlay.show
      pbMessage(_INTL("Egg steps overlay shown."))
    end
  end
end

# Debug command
def pbShowEggStepsInfo
  if $player.party.any? { |p| p.egg? }
    text = []
    $player.party.each_with_index do |pokemon, i|
      if pokemon.egg?
        remaining = EggStepsDisplay.get_remaining_steps(pokemon)
        total = EggStepsDisplay.get_total_steps(pokemon)
        progress = EggStepsDisplay.get_progress_percentage(pokemon)
        text.push(_INTL("Slot {1}: {2} steps ({3}%)", i + 1, remaining, progress))
      end
    end
    pbMessage(text.join("\\n"))
  else
    pbMessage(_INTL("No eggs in party."))
  end
end 