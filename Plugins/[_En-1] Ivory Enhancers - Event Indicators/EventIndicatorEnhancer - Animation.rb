#|
#| Ivory's Animated Indicators
#|

# Script for letting players dictate what Indicators they use

# --------------------------------------------------------------------------------------------------------------
# wrigty12 told me what code to change in his script, so all the credit there goes to him
# If you'd like to use the indicators I included, copy `EventIndicatorEnhancer - Graphics` to wrigty12's script
# --------------------------------------------------------------------------------------------------------------

module Settings
    
	# Set to true to allow the player turn off the icons
	ALLOW_EVENT_INDICATORS_VISIBLE_OFF = true

	# Set to true to allow the player to choose whether the Event Indicators have the option for simplification.
	# If false, the option to choose does not appear and indicators will default to bubble unless you change @event_icons_style  = 0
	ALLOW_EVENT_INDICATORS_ALLOW_SIMPLE = true

	# Set to true to allow the player to choose whether the Event Indicators have animated objects or not
	# If false, the option to choose does not appear and indicators will default to float style unless you change @event_icons_move   = 0
	ALLOW_EVENT_INDICATORS_ANIMATED_OBJECTS = true

	# Set to true to allow the player to choose whether the Event Indicators are .pngs or .gifs.
	# If false, the option to choose does not appear and indicators will default to .gifs unless you change @event_icons_type   = 0
	ALLOW_EVENT_INDICATORS_TURN_OFF_ANIMATION = true
end


class EventIndicator
    
	alias event_indicator_animated_icons initialize
    def initialize(params, event, viewport, map)
		event_indicator_animated_icons(params, event, viewport, map)
        @type = params[0]
        @event = event
        @viewport = viewport
        @map = map

        data = Settings::EVENT_INDICATORS[@type]
        if !data
            @disposed = true
            return
        end
		
        graphic = data[:graphic]

# ----------------------------------------------------------------------------------------------------------------------

# BEGIN FILE EDITS

# NOTE - the order matters
# If you name it "Indicator_s_a" instead of "Indicator_a_s" it won't be able to load unless you flip these around
# You can add as many options as you want but ALWAYS leave the File Extension at the end of this script section

# you can change what the below means but that will require the Option Descriptions to be updated

# "_a" means the object, such as a Pokeball or Egg is animated as well as the floating bubble
    graphic += "_a" if $PokemonSystem.event_icons_move == 1
            
    # "_s" means that instead of a solid speech bubble there's an object outline with a pointer
    graphic += "_s" if $PokemonSystem.event_icons_style == 1
    
    _image = "_i.png" if Settings::ALLOW_EVENT_INDICATORS_TURN_OFF_ANIMATION
    _image = ".gif" if $PokemonSystem.event_icons_type == 1 || !Settings::ALLOW_EVENT_INDICATORS_TURN_OFF_ANIMATION
    
    graphic += _image if $PokemonSystem.event_icons_exist == 0

    

# ----------------------------------------------------------------------------------------------------------------------
    
        @indicator.setBitmap(graphic)
        @disposed = true if $PokemonSystem.event_icons_exist == 1 && Settings::ALLOW_EVENT_INDICATORS_VISIBLE_OFF

   end
end

    alias event_indicator_off initialize
    def addEventIndicator(new_sprite, forced = false)
        event_indicator_off(new_sprite, forced = false)
        @event_indicator_sprites.clear if $PokemonSystem.event_icons_exist == 1
        return false if $PokemonSystem.event_icons_exist == 1
    end

class PokemonSystem

  attr_accessor :event_icons_exist
  attr_accessor :event_icons_style
  attr_accessor :event_icons_move
  attr_accessor :event_icons_type

  alias indicator_initialize initialize
  def initialize
    indicator_initialize
    @event_icons_exist  = 0
    @event_icons_style  = 0
    @event_icons_move   = 0
    @event_icons_type   = 0
  end

end

if Settings::ALLOW_EVENT_INDICATORS_VISIBLE_OFF
    MenuHandlers.add(:options_menu, :event_icons_exist, {
    "name"        => _INTL("Indicator Exist"),
    "order"       => 84,
    "type"        => EnumOption,
    "parameters"  => [_INTL("On"), _INTL("Off")],
    "description" => _INTL("Change view of the indicator icons that NPCs use."),
    "get_proc"    => proc { next $PokemonSystem.event_icons_exist },
    "set_proc"    => proc { |value, _scene| 
        $PokemonSystem.event_icons_exist = value
        $game_map&.refresh
    }
    })
end

if Settings::ALLOW_EVENT_INDICATORS_ALLOW_SIMPLE
    MenuHandlers.add(:options_menu, :event_icons_style, {
    "name"        => _INTL("Indicator Style"),
    "order"       => 85,
    "type"        => EnumOption,
    "parameters"  => [_INTL("Standard"), _INTL("Simple")],
    "description" => _INTL("Change the indicator icons that NPCs use."),
    "get_proc"    => proc { next $PokemonSystem.event_icons_style },
    "set_proc"    => proc { |value, _scene| 
        $PokemonSystem.event_icons_style = value
        $game_map&.refresh
    }
    })
end

if Settings::ALLOW_EVENT_INDICATORS_ANIMATED_OBJECTS
    MenuHandlers.add(:options_menu, :event_icons_move, {
    "name"        => _INTL("Indicator Movement"),
    "order"       => 86,
    "type"        => EnumOption,
    "parameters"  => [_INTL("Float"), _INTL("Object")],
    "description" => _INTL("Set NPC indicator icons to an extra animation or not."),
    "get_proc"    => proc { next $PokemonSystem.event_icons_move },
    "set_proc"    => proc { |value, _scene| 
        $PokemonSystem.event_icons_move = value
        $game_map&.refresh
    }
    })
end

if Settings::ALLOW_EVENT_INDICATORS_TURN_OFF_ANIMATION
    MenuHandlers.add(:options_menu, :event_icons_type, {
		"name"        => _INTL("Indicator Type"),
		"order"       => 87,
		"type"        => EnumOption,
		"parameters"  => [_INTL("Static"), _INTL("Animated")],
		"description" => _INTL("Choose to animate NPC indicator icons or make them static."),
		"get_proc"    => proc { next $PokemonSystem.event_icons_type },
		"set_proc"    => proc { |value, _scene| 
			$PokemonSystem.event_icons_type = value
			$game_map&.refresh
		}
    })
end