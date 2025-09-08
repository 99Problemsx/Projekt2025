#===============================================================================
# => Quick Menu Moves
#===============================================================================
def pbUseKeyItem
  moves = []
  moves.concat(AIFM_RockSmash[:move_name])
  moves.concat(AIFM_Cut[:move_name])
  moves.concat(AIFM_IceSmash[:move_name])
  moves.concat(AIFM_Headbutt[:move_name])
  moves.concat(AIFM_SweetScent[:move_name])
  moves.concat(AIFM_Strength[:move_name])
  moves.concat(AIFM_Flash[:move_name])
  moves.concat(AIFM_Defog[:move_name])
  moves.concat(AIFM_Weather[:move_name])
  moves.concat(AIFM_Camouflage[:move_name])
  moves.concat(AIFM_Surf[:move_name])
  moves.concat(AIFM_Dive[:move_name])
  moves.concat(AIFM_Waterfall[:move_name])
  moves.concat(AIFM_Whirlpool[:move_name])
  moves.concat(AIFM_Fly[:move_name])
  moves.concat(AIFM_Dig[:move_name])
  moves.concat(AIFM_Teleport[:move_name])
  moves.concat(AIFM_RockClimb[:move_name])
  moves.concat(AIFM_LavaSurf[:move_name])
  moves.concat(AIFM_Lavafall[:move_name])
  moves.concat(AIFM_LavaSwirl[:move_name])
  moves.concat(AIFM_Lift[:move_name])
  moves.concat(AIFM_SenseTruth[:move_name])
  moves.concat(AIFM_Bomb[:move_name])
  moves.concat(AIFM_SecretBase[:move_name]) if PluginManager.installed?("Secret Bases Remade")
  moves.sort!
  real_moves = []
  moves.each do |move|
    $player.party.each_with_index do |pkmn, i|
      next if pkmn.egg? || !pkmn.hasMove?(move)
      real_moves.push([move, i]) if pbCanUseHiddenMove?(pkmn, move, false)
    end
  end
  real_items = []
  $bag.registered_items.each do |i|
    itm = GameData::Item.get(i).id
    real_items.push(itm) if $bag.has?(itm)
  end
  if real_items.length == 0 && real_moves.length == 0
    pbMessage(_INTL("An item in the Bag can be registered to this key for instant use."))
  else
    $game_temp.in_menu = true
    $game_map.update
    sscene = PokemonReadyMenu_Scene.new
    sscreen = PokemonReadyMenu.new(sscene)
    sscreen.pbStartReadyMenu(real_moves, real_items)
    $game_temp.in_menu = false
  end
end

#===============================================================================
# Select Move Menu Button
#===============================================================================
class SelectMoveMenuButton < Sprite
  attr_reader :index   # ID of button
  attr_reader :selected
  attr_reader :side

  def initialize(index, command, selected, viewport = nil, pp_check = nil)
    super(viewport)
    @index = index
    @command = command   # Item/move ID, name, mode (T move/F item), pkmnIndex
    @selected = selected
    @pp_check = pp_check # Flag to determine if PP display is needed
    @button = AnimatedBitmap.new("Graphics/UI/Ready Menu/icon_movesbutton")
    @contents = Bitmap.new(@button.width, @button.height / 2)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    @icon = PokemonIconSprite.new($player.party[@command[2]], viewport)
    @icon.setOffset(PictureOrigin::CENTER)
    @icon.z = self.z + 1
    puts ("Quick Menu pp_check ? #{@pp_check}") if $DEBUG
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    @icon.dispose
    super
  end

  def visible=(val)
    @icon.visible = val
    super(val)
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    sel = (@selected == @index)
    self.y = ((Graphics.height - (@button.height / 2)) / 2) - ((@selected - @index) * ((@button.height / 2) + 4))
    self.x = (sel) ? Graphics.width - @button.width : Graphics.width + 16 - @button.width
    @icon.x = self.x + 52
    @icon.y = self.y + 32
    self.bitmap.clear
    rect = Rect.new(0, (sel ? @button.height / 2 : 0), @button.width, @button.height / 2)
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    # Add PP display if pp_check is true and @command[3] contains data
    if @pp_check && @command[3]
      pp_data = @command[3] # PP data passed in @command[3]
      current_pp = pp_data[:pp]
      max_pp = pp_data[:max_pp]
      # Define PP color thresholds
      ppBase   = [Color.new(248, 248, 248),  # More than 1/2 of total PP
                  Color.new(248, 192, 0),    # 1/2 of total PP or less
                  Color.new(248, 136, 32)]   # 1/4 of total PP or less
      ppShadow = [Color.new(40, 40, 40),     # More than 1/2 of total PP
                  Color.new(144, 104, 0),    # 1/2 of total PP or less
                  Color.new(144, 72, 24)]    # 1/4 of total PP or less
      # Determine PP fraction
      ppfraction = 0
      if current_pp * 4 <= max_pp
        ppfraction = 2
      elsif current_pp * 2 <= max_pp
        ppfraction = 1
      end
      # Add move name and PP text with dynamic colors
      textpos = [
        [@command[1], 150, 10, :center, Color.new(248, 248, 248), Color.new(40, 40, 40), :outline],
        [_INTL("{1}/{2}", current_pp, max_pp), 150, 38, :center, ppBase[ppfraction], ppShadow[ppfraction], :outline]
      ]
    else
      # Draw the move name
      textpos = [[@command[1], 150, 24, :center, Color.new(248, 248, 248), Color.new(40, 40, 40), :outline]]
    end
    pbDrawTextPositions(self.bitmap, textpos)
  end

  def update
    @icon&.update
    super
  end
end

#===============================================================================
# SelectMoveMenu Scene
#===============================================================================
class SelectMoveMenu_Scene
  attr_reader :sprites

  def pbStartScene(commands, pp_check = false)
    @commands = commands
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # Create buttons
    @commands.each_with_index do |command, i|
      @sprites["button#{i}"] = SelectMoveMenuButton.new(i, command, @index, @viewport, pp_check)
    end
    pbSEPlay("GUI menu open")
  end

  def pbShowCommands
    loop do
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        @index = (@index - 1) % @commands.length
        refresh_buttons
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        @index = (@index + 1) % @commands.length
        refresh_buttons
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        return @index
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        return -1
      end
    end
  end

  def refresh_buttons
    @commands.each_index do |i|
      @sprites["button#{i}"].selected = @index
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# SelectMoveMenu Main
#===============================================================================
class SelectMoveMenu
  def initialize(scene)
    @scene = scene
  end

  # Accept two arguments: moves and pp_check
  def pbStartSelectMoveMenu(moves, pp_check = false)
    @scene.pbStartScene(moves, pp_check)
    command = @scene.pbShowCommands
    @scene.pbEndScene
    return nil if command < 0
    return moves[command]
  end
end

#===============================================================================
# Use Move from SelectMoveMenu
#===============================================================================
def pbSelectMoveMenu(moves, pp_check = false)
  if moves.empty?
    pbMessage(_INTL("None of your Pokémon have a usable move."))
    return nil
  end
  # Start the SelectMoveMenu
  sscene = SelectMoveMenu_Scene.new
  sscreen = SelectMoveMenu.new(sscene)
  result = sscreen.pbStartSelectMoveMenu(moves, pp_check) # Pass the pp_check as true
  return nil if result.nil? # Handle if the user cancels the menu
  # Extract selected move data
  move_id = result[0]
  user = $player.party[result[2]] # Pokémon index is stored in the third element
  #pbMessage(_INTL("Dude {1} used {2}!", user.name, GameData::Move.get(move_id).name))
  #pbUseHiddenMove(user, move_id)
  return user, move_id
end

#===============================================================================
# Option Menu Added
#===============================================================================
class PokemonSystem < PokemonSystem
  attr_accessor :animation_item
  attr_accessor :animation_type
  attr_accessor :animation_move
  attr_accessor :ask_text
  attr_accessor :moves_option
  attr_accessor :camouflaged
  attr_accessor :surf_option

  alias aifm_initialize initialize
  def initialize
    aifm_initialize
    @animation_item       = AIFM_Option_Boot[:item_animation]
    @animation_type       = AIFM_Option_Boot[:item_animation_type]
    @animation_move       = AIFM_Option_Boot[:move_animation]
    @ask_text             = AIFM_Option_Boot[:ask_text]
    @moves_option         = AIFM_Option_Boot[:moves_option]
    @camouflaged          = AIFM_Camouflage[:transpernt] - AIFM_Camouflage[:transpernt_min]
    @surf_option          = 0 # Not in use atm there is a bug with it
  end
end

#===============================================================================
# Options AIFM Menu Integration
#===============================================================================
class ButtonOption
  include PropertyMixin

  def initialize(name, values, get_proc, set_proc)
    @name = name
    @values = [_INTL("")]
    @get_proc = get_proc
    @set_proc = set_proc
  end

  def values
    return @values
  end

  def next(current)
    return current
  end

  def prev(current)
    return current
  end

  def action(scene)
    @set_proc.call(0, scene)
  end

  def set(value, scene)
    # Do nothing when the value is changed
  end
end

module AIFMHandlers
  @@handlers = {}

  def self.add(category, option_name, hash)
    @@handlers[category] ||= {}
    @@handlers[category][option_name] = hash
  end

  def self.get_handlers(category)
    return @@handlers[category] || {}
  end

  def self.each(category)
    return if !@@handlers.has_key?(category)
    @@handlers[category].each { |option_name, hash| yield option_name, hash }
  end

  def self.each_sorted(category)
    return if !@@handlers.has_key?(category)
    @@handlers[category].sort_by { |option_name, hash| hash["order"] || @@handlers[category].keys.index(option_name) }.each do |option_name, hash|
      yield option_name, hash
    end
  end
end

class PokemonOption_Scene
  alias pbOptions_aifm pbOptions
  def pbOptions
    pbActivateWindow(@sprites, "option") do
      index = -1
      aifm_open = false
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if @sprites["option"].index != index && !aifm_open
          pbChangeSelection
          index = @sprites["option"].index
        end
        if !aifm_open
          if @options[index].is_a?(ButtonOption)
            # Do nothing
          else
            @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
            if (Input.trigger?(Input::USE) && @sprites["option"].index == @options.length)
              break
            end
          end
        end
        if Input.trigger?(Input::BACK) && !aifm_open
          break
        elsif Input.trigger?(Input::USE) && @options[index].is_a?(ButtonOption) && !aifm_open
          aifm_open = true
          pbPlayDecisionSE
          @options[index].instance_variable_get(:@set_proc).call(0, self)
          aifm_open = false
        end
      end
    end
  end

  def pbAIFMOptions
    $Back = true
    handlers = []
    options = []
    MenuHandlers.each(:aifm_menu) do |option_name, hash|
      handlers.push([option_name, hash])
    end
    handlers.sort_by! { |option_name, hash| hash["order"] || Float::INFINITY }
    handlers.each do |option_name, hash|
      option = case hash["type"].name
      when "EnumOption", "SliderOption"
        hash["type"].new(hash["name"], hash["parameters"], hash["get_proc"], hash["set_proc"])
      when "NumberOption"
        hash["type"].new(hash["name"], [hash["parameters"].begin, hash["parameters"].end], hash["get_proc"], hash["set_proc"])
      end
      options.push({ "option" => option, "set_proc" => hash["set_proc"], "description" => hash["description"], "value" => hash["get_proc"].call })
    end
    aifm_window = Window_PokemonOption.new(options.map { |o| o["option"] }, 0, @sprites["title"].y + @sprites["title"].height - 16, Graphics.width, Graphics.height - (@sprites["title"].y + @sprites["title"].height - 16) - @sprites["textbox"].height)
    options.each_with_index { |option, index| aifm_window.setValueNoRefresh(index, option["value"]) }
    aifm_window.refresh
    @sprites["sub_title"] = Window_UnformattedTextPokemon.newWithSize(
      _INTL("- Adavanced Items Fields Moves"), 86, -16, Graphics.width, 64, @viewport
    )
    @sprites["sub_title"].back_opacity = 0
    @sprites["option"].active = false
    @sprites["option"].visible = false
    aifm_window.viewport = @viewport
    aifm_window.visible = true
    aifm_window.active = true
    loop do
      Graphics.update
      Input.update
      pbUpdate
      aifm_window.update
      description = options[aifm_window.index] ? (options[aifm_window.index]["description"].is_a?(Proc) ? options[aifm_window.index]["description"].call : _INTL(options[aifm_window.index]["description"])) : _INTL("Close the screen.")
      @sprites["textbox"].text = description
      if Input.trigger?(Input::BACK) || (Input.trigger?(Input::USE) && aifm_window.index == aifm_window.itemCount - 1)
        options.each_with_index { |option, index| option["set_proc"].call(aifm_window[index], self) if option["set_proc"] }
        pbPlayCloseMenuSE if Input.trigger?(Input::BACK) || aifm_window.index == aifm_window.itemCount - 1
        @sprites["sub_title"].dispose
        $close = nil
        break
      elsif Input.repeat?(Input::LEFT) || Input.repeat?(Input::RIGHT)
        option = options[aifm_window.index]
        option["set_proc"].call(aifm_window[aifm_window.index], self) if option && option["set_proc"]
      end
    end
    aifm_window.dispose
    pbChangeSelection
    @sprites["option"].active = true
    @sprites["option"].visible = true
  end
end

#MAIN Menu in aifm_menu
MenuHandlers.add(:options_menu, :aifm_menu, {
  "name" => _INTL("Advanced Items Field Moves Options"),
  "order" => 99999,
  "condition" => proc { next AIFM_Option[:option] == true },
  "type" => ButtonOption,
  "description" => _INTL("Choose how multiple Hidden moves would work."),
  "get_proc" => proc { next 0 },
  "set_proc" => proc { |value, scene| scene.pbAIFMOptions }
})

#SUB Menu in aifm_menu
MenuHandlers.add(:aifm_menu, :itemanimation, {
  "name"        => _INTL("Item Animations"),
  "parent"      => :aifm_menu,
  "order"       => 1,
  "condition"   => proc { next AIFM_Option[:animation_option] == true },
  "type"        => EnumOption,
  "parameters"  => [_INTL("Always"), _INTL("Disable")],
  "description" => proc { next _INTL("#{([
    "Item animation is Always shown when used.",
    "Disable both animation and text and wont shown when used ",
    ][$PokemonSystem.animation_item])}") },
  "get_proc"    => proc { next $PokemonSystem.animation_item },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.animation_item == value
    $PokemonSystem.animation_item = value
    animation_item_value = $PokemonSystem.animation_item
    puts "Item Animations = #{animation_item_value}" if $DEBUG
  }
})

MenuHandlers.add(:aifm_menu, :itemtypeanimation, {
  "name"        => _INTL("Type Animations"),
  "parent"      => :aifm_menu,
  "order"       => 2,
  "condition"   => proc { next AIFM_Option[:text_option] == true },
  "type"        => EnumOption,
  "parameters"  => [_INTL("New"), _INTL("Old")],
  "description" => proc { next _INTL("#{([
    "New Item animation type, Rock Smash or Cut.",
    "Old Item animation type.",
    ][$PokemonSystem.animation_type])}") },
  "get_proc"    => proc { next $PokemonSystem.animation_type },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.animation_type == value
    $PokemonSystem.animation_type = value
    animation_type_value = $PokemonSystem.animation_type
    puts "Item/Field text = #{animation_type_value}" if $DEBUG
  }
})

#SUB Menu in aifm_menu
MenuHandlers.add(:aifm_menu, :moveanimation, {
  "name"        => _INTL("Move Animations"),
  "parent"      => :aifm_menu,
  "order"       => 5,
  "condition"   => proc { next AIFM_Option[:animation_option] == true },
  "type"        => EnumOption,
  "parameters"  => [_INTL("Always"), _INTL("Disable")],
  "description" => _INTL("Move animation shown when used."),
  "description" => proc { next _INTL("#{([
    "Move animation is Always shown when used.",
    "Disable both animation and text and wont shown when used ",
    ][$PokemonSystem.animation_move])}") },
  "get_proc"    => proc { next $PokemonSystem.animation_move },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.animation_move == value
    $PokemonSystem.animation_move = value
    animation_move_value = $PokemonSystem.animation_move
    puts "Move Animations = #{animation_move_value}" if $DEBUG
  }
})

#SUB Menu in aifm_menu
MenuHandlers.add(:aifm_menu, :ask_text, {
  "name"        => _INTL("Ask to Use Item/Move"),
  "parent"      => :aifm_menu,
  "order"       => 10,
  "condition"   => proc { next AIFM_Option[:text_option] == true },
  "type"        => EnumOption,
  "parameters"  => [_INTL("Normal"), _INTL("Disable")],
  "description" => proc { next _INTL("#{([
    "Ask if you like to use Item or Move.",
    "Disable asking, just use if can."
    ][$PokemonSystem.ask_text])}") },
  "get_proc"    => proc { next $PokemonSystem.ask_text },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.ask_text == value
    $PokemonSystem.ask_text = value
    aifm_text_value = $PokemonSystem.ask_text
    puts "Item/Field text = #{aifm_text_value}" if $DEBUG
  }
})

#SUB Menu in aifm_menu
MenuHandlers.add(:aifm_menu, :moves_option, {
  "name"        => _INTL("Field Move Option"),
  "parent"      => :aifm_menu,
  "order"       => 15,
  "condition"   => proc { next AIFM_Option[:moves_option] == true },
  "type"        => EnumOption,
  "parameters"  => [_INTL("Choose"), _INTL("Quickest")],
  "description" => proc { next _INTL("#{([
    "Multiple Hidden moves?\nGet a Menu and Choose a move.",
    "Multiple Hidden moves?\nQuickest is the First available move."
    ][$PokemonSystem.moves_option])}") },
  "get_proc"    => proc { next $PokemonSystem.moves_option },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.moves_option == value
    $PokemonSystem.moves_option = value
    moves_option = $PokemonSystem.moves_option
    puts "Multiple Hidden Moves Value = #{moves_option}" if $DEBUG
  }
})

#SUB Menu in aifm_menu
MenuHandlers.add(:aifm_menu, :camouflage, {
  "name"        => _INTL("Camouflage Opacity"),
  "order"       => 20,
  "parent"      => :aifm_menu,
  "condition"   => proc { next AIFM_Option[:camouflage_option] == true },
  "type"        => SliderOption,
  "parameters"  => [AIFM_Camouflage[:transpernt_min], 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the camouflage opacity in %."),
  "get_proc"    => proc { next $PokemonSystem.camouflaged },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.camouflaged == value
    $PokemonSystem.camouflaged = value
    camouflaged_value = $PokemonSystem.camouflaged + AIFM_Camouflage[:transpernt_min]
    puts "Camouflaged value = #{camouflaged_value}" if $DEBUG
    setCamouflaged = ($PokemonSystem.camouflaged / 100.0) * 255
    if $PokemonGlobal && $PokemonGlobal.camouflage
      pbMoveRoute($game_player, [PBMoveRoute::OPACITY, setCamouflaged])
      pbMoveRoute(FollowingPkmn.get_event, [PBMoveRoute::OPACITY, setCamouflaged]) if PluginManager.installed?("Following Pokemon EX")
    end
  }
})


#===============================================================================
# => Weather Songs / Chips
# => Credit to [Yankas, Cony] for work on Radial Menu with it i would still be lost
#===============================================================================
module AIFMWeatherFluteMenu
  MENU_CONFIG = {
#   Allow option Sub Menu to show
    :menu_distance                      => 130,                    # Default: 130
    :icon_width                         => 50,                     # The width of the menu icon FILE
    :icon_height                        => 50,                     # The height of menu icon FILE
    :active_scale                       => 1.5,                    # Resize factor of the currently active icon.
    :active_opacity                     => 255,                    # Transparency of active icon; 0=fully transparent, 255=fully solid
    :active_tone                        => Tone.new(0,0,0,0),      # Tone (Red, Green, Blue, Grey) shift applied to active icon.
    :inactive_scale                     => 0.8,                    # This Cant be higher then 1
    :inactive_opacity                   => 204,                    # Transparency of inactive icons; 0=fully, 255=fully solid
    :inactive_tone                      => Tone.new(0,0,0,0),      # Tone (Red, Green, Blue, Grey) shift applied to inactive icon.
    :menu_textcolor                     => Color.new(244,244,244), # The text color of the menu icon's name/description.
    :menu_textoutline                   => Color.new(30,30,30),    # The highlight (outline) color of the text.
    :background_tint                    => Tone.new(0,0,0,150),    # Tone (Red, Green, Blue, Grey) applied to the background/map.

    :base_angle                         => Math::PI/2,
    :anim_turn_length                   => 8,
    :anim_start_length                  => 6,
  }
end
AIFM_Wfm                                = AIFMWeatherFluteMenu::MENU_CONFIG

class WfmComponent
  attr_accessor :viewport
  attr_accessor :sprites

  def initialize(viewport, spritehash)
    @viewport = viewport
    @sprites = spritehash
  end

  def dispose
    @sprites = nil
  end
end

class WeatherSong
  attr_reader :name, :icon, :weather_type, :condition, :effect
  attr_accessor :angle

  def initialize(options)
    @name = options["name"]
    @icon = options["icon"]
    @weather_type = options["weather_type"]
    @condition = options["condition"]
    @effect = options["effect"]
  end

  def available?
    @condition.call
  end

  def selected(menu)
    result = @effect.call(menu)
    menu.pbEndScene if result
  end
end

module WeatherMenuHandler
  @@entries = []

  def self.add_entry(entry)
    @@entries << entry
  end

  def self.entries
    @@entries
  end
end

class WeatherMenu < WfmComponent
  def initialize(viewport, spritehash, menu)
    super(viewport, spritehash)
    @menu = menu
    @entries = []
    @originX = Graphics.width / 2 - AIFM_Wfm[:icon_width] / 2
    @originY = Graphics.height / 2 - AIFM_Wfm[:icon_height] / 2
    @animationCounter = (AIFM_Wfm[:anim_start_length] > 0) ? AIFM_Wfm[:anim_start_length] : 1
    @currentSelection = 0
    @angleSize = 0
    @frameAngleShift = 0
    WeatherMenuHandler.entries.each do |entry|
      addMenuEntry(entry)
    end
    @sprites["entrytext"] = BitmapSprite.new(256,40,@viewport)
    @doingStartup = true
    refreshMenuText
  end

  def has_entries?
    @entries.any?
  end

  def addMenuEntry(entry)
    if entry.available?
      @entries << entry
      @sprites[entry.name] = IconSprite.new(0,0,@viewport)
      @sprites[entry.name].visible = false
      @sprites[entry.name].setBitmap(entry.icon)
      @sprites[entry.name].tone = AIFM_Wfm[:inactive_tone]
      @sprites[entry.name].opacity = AIFM_Wfm[:inactive_opacity]
    end
  end

  def update
    exit = false
    if(Input.trigger?(Input::BACK))
        @menu.shouldExit = true
        return
    end
    if(@animationCounter > 0)
      if(@doingStartup)
        @distance = 24 + (AIFM_Wfm[:anim_start_length] - @animationCounter) * ((AIFM_Wfm[:menu_distance] - 24) / AIFM_Wfm[:anim_start_length])
        positionMenuEntries
        @menu.pbHideMenu(false) if(AIFM_Wfm[:anim_start_length]== @animationCounter)
        transformIcon(@sprites[@entries[0].name], AIFM_Wfm[:active_scale], AIFM_Wfm[:active_tone], AIFM_Wfm[:active_opacity])
        @animationCounter -= 1
        @doingStartup = false if (@animationCounter < 1)
      else
        updateAnimation
        refreshMenuText
      end
    else
      if Input.repeat?(Input::RIGHT)
        startAnimation(1)
      elsif Input.repeat?(Input::LEFT)
        startAnimation(-1)
      elsif Input.trigger?(Input::USE)
        exit = @entries[@currentSelection].selected(@menu)
      end
    end
    @menu.shouldExit = exit
  end

  def startAnimation(direction)
    return if @entries.length <= 1
    @currentSelection = (@currentSelection - direction) % @entries.length
    if @currentSelection < 0
      @currentSelection += @entries.length
    end
    @currentAngle = AIFM_Wfm[:base_angle]
    @frameAngleShift = direction * @angleSize / AIFM_Wfm[:anim_turn_length]
    @frameScaleShift = ((AIFM_Wfm[:active_scale]-1) / AIFM_Wfm[:anim_turn_length])
    @animationCounter = AIFM_Wfm[:anim_turn_length]
    pbSEPlay("GUI sel cursor")
  end

  def updateAnimation
    @animationCounter -= 1
    @entries.each do |entry|
      entry.angle += @frameAngleShift
      repositionSprite(@sprites[entry.name], entry.angle)
    end
    newActive = @sprites[@entries[@currentSelection].name]
    if(@frameAngleShift > 0)
      oldActive = @sprites[@entries[(@currentSelection + 1) % @entries.length].name]
    else
      oldActive = @sprites[@entries[(@currentSelection - 1) % @entries.length].name]
    end
    scaleNew = 1 + @frameScaleShift * (AIFM_Wfm[:anim_turn_length] - @animationCounter)
    scaleOld = 1 + @frameScaleShift * @animationCounter
    transformIcon(newActive, scaleNew, AIFM_Wfm[:active_tone], AIFM_Wfm[:active_opacity])
    transformIcon(oldActive, scaleOld, AIFM_Wfm[:inactive_tone], AIFM_Wfm[:inactive_opacity])
    @entries.each do |entry|
      if entry != @entries[@currentSelection]
        transformIcon(@sprites[entry.name], AIFM_Wfm[:inactive_scale], AIFM_Wfm[:inactive_tone], AIFM_Wfm[:inactive_opacity])
      end
    end
  end

  def refreshMenuText
    if @entries[@currentSelection]
      @sprites["entrytext"].bitmap.clear
      text = @entries[@currentSelection].name
      text_width = @sprites["entrytext"].bitmap.text_size(text).width
      @sprites["entrytext"].x = @originX + 22 - (text_width / 2)
      @sprites["entrytext"].y = @originY + 64
      pbSetSystemFont(@sprites["entrytext"].bitmap)
      pbDrawTextPositions(@sprites["entrytext"].bitmap,[[text,0,0,0,AIFM_Wfm[:menu_textcolor],AIFM_Wfm[:menu_textoutline]]])
    end
  end

  def positionMenuEntries
    @currentAngle = AIFM_Wfm[:base_angle]
    @angleSize = (2*Math::PI) / @entries.length
    @entries.each do |entry|
      entry.angle = @currentAngle
      repositionSprite(@sprites[entry.name], entry.angle)
      transformIcon(@sprites[entry.name], AIFM_Wfm[:inactive_scale], AIFM_Wfm[:inactive_tone], AIFM_Wfm[:inactive_opacity])
      @currentAngle += @angleSize
    end
  end

  def repositionSprite(sprite, theta)
    sprite.y = (@distance * Math.sin(theta)) + @originY
    sprite.x = (@distance * Math.cos(theta)) + @originX
  end

  def transformIcon(sprite, scale, tone, opacity)
    width = sprite.bitmap.width
    height = sprite.bitmap.height
    sprite.zoom_x = scale
    sprite.zoom_y = scale
    sprite.x = sprite.x - (width*scale-width)/2
    sprite.y = sprite.y - (height*scale-height)/2
    sprite.tone = tone
    sprite.opacity = opacity
    if scale == AIFM_Wfm[:active_scale]
      sprite.z = 1
    else
      sprite.z = 0
    end
  end
end

class PokemonFluteMenu_Scene
  attr_accessor :shouldExit

  def initialize
    @background = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @sprites = {}
    @shouldExit = false
  end

  def pbStartScene
    @viewport.z = 99999
    @background.z = 99998
    @background.tone = AIFM_Wfm[:background_tint]
    @weatherMenu = WeatherMenu.new(@viewport, @sprites, self)
  end

  def pbHideMenu(hide)
    @sprites.each do |_,sprite|
      sprite.visible = !hide
    end
  end

  def update
    @hasTerminated = false
    pbSEPlay("GUI menu open")
    loop do
      if $game_player.direction != 2
        @playerOldDirection = $game_player.direction
        $game_player.turn_down
        Graphics.update
        Input.update
        pbUpdateSceneMap
        next
      end
      Graphics.update
      Input.update
      @weatherMenu.update
      if(@hasTerminated)
        return
      end
      pbUpdateSceneMap
      if(shouldExit)
        pbEndScene
        break
      end
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    @hasTerminated = true
    @background.dispose
    @weatherMenu.dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    $game_player.turn_generic(@playerOldDirection) if defined?(@playerOldDirection)
  end

  def has_entries?
    @weatherMenu.has_entries?
  end
end

def pbFluteMenu
  scene = PokemonFluteMenu_Scene.new
  scene.pbStartScene
  if !scene.has_entries?
    scene.pbEndScene
    pbMessage("You don't have any song to play.")
    return
  end
  scene.update
end

#==============================[Adding Weather]=================================
WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Clearing",
  "icon"          => "Graphics/UI/AIFM/SongClearing",
  "weather_type"  => :None,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetclearing])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it clears up?"))
      if pbCheckForBadge(config[:clearing_needed_badge]) && pbCheckForSwitch(config[:clearing_needed_switches])
        if $game_screen.weather_type != :None
          pbMessage(_INTL("It's already cloudless sky!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to clear up!"))
          $game_screen.weather(:None, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_clear_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Rainy",
  "icon"          => "Graphics/UI/AIFM/SongRain",
  "weather_type"  => :Rain,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetrain])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it is raining?"))
      if pbCheckForBadge(config[:rain_needed_badge]) && pbCheckForSwitch(config[:rain_needed_switches])
        if $game_screen.weather_type == :Rain || $game_screen.weather_type == :HeavyRain
          pbMessage(_INTL("It's already rainning!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to rain!"))
          $game_screen.weather(:Rain, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_rain_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Stormy",
  "icon"          => "Graphics/UI/AIFM/SongStorm",
  "weather_type"  => :Storm,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetstorm])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes storming?"))
      if pbCheckForBadge(config[:storm_needed_badge]) && pbCheckForSwitch(config[:storm_needed_switches])
        if $game_screen.weather_type == :Storm
          pbMessage(_INTL("It's already stormy!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a storm!"))
          $game_screen.weather(:Storm, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_storm_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Snowy",
  "icon"          => "Graphics/UI/AIFM/SongSnow",
  "weather_type"  => :Snow,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetsnow])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes snowing?"))
      if pbCheckForBadge(config[:snow_needed_badge]) && pbCheckForSwitch(config[:snow_needed_switches])
        if $game_screen.weather_type == :Snow || $game_screen.weather_type == :Blizzard
          pbMessage(_INTL("It's already snowing!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to snow!"))
          $game_screen.weather(:Snow, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_snow_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Blizzard",
  "icon"          => "Graphics/UI/AIFM/SongBlizzard",
  "weather_type"  => :Blizzard,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetblizzard])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes a blizzard?"))
      if pbCheckForBadge(config[:blizzard_needed_badge]) && pbCheckForSwitch(config[:blizzard_needed_switches])
        if $game_screen.weather_type == :Blizzard
          pbMessage(_INTL("It's already a blizzard!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a blizzard!"))
          $game_screen.weather(:Blizzard, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_blizzard_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Sandstorm",
  "icon"          => "Graphics/UI/AIFM/SongSandstorm",
  "weather_type"  => :sandstorm,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetsandstorm])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes a sandstorm?"))
      if pbCheckForBadge(config[:sandstorm_needed_badge]) && pbCheckForSwitch(config[:sandstrom_needed_switches])
        if $game_screen.weather_type == :Sandstorm
          pbMessage(_INTL("It's already a sandstorm!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a sandstorm!"))
          $game_screen.weather(:Sandstorm, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_sandstorm_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Stormy Rain",
  "icon"          => "Graphics/UI/AIFM/SongHeavyRain",
  "weather_type"  => :HeavyRain,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetheavyrain])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes a rain storm?"))
      if pbCheckForBadge(config[:heavyrain_needed_badge]) && pbCheckForSwitch(config[:heavyrain_needed_switches])
        if $game_screen.weather_type == :HeavyRain
          pbMessage(_INTL("It's already a Rain Storm!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a rain storm!"))
          $game_screen.weather(:HeavyRain, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_heavyrain_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Sunny",
  "icon"          => "Graphics/UI/AIFM/SongSun",
  "weather_type"  => :Sun,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetsun])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes a sunny?"))
      if pbCheckForBadge(config[:sun_needed_badge]) && pbCheckForSwitch(config[:sun_needed_switches])
        if $game_screen.weather_type == :Sun && !PBDayNight.isNight?
          pbMessage(_INTL("It's already sunny!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a sunny!"))
          $game_screen.weather(:Sun, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_sunny_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        if PBDayNight.isNight?
          pbMessage(_INTL("You can't alter to sunny when is night!"))
        else
          pbMessage(_INTL("You can't alter the current weather!"))
        end
        next false
      end
    else
      next false
    end
  }
))

WeatherMenuHandler.add_entry(WeatherSong.new(
  "name"          => "Song of Foggy",
  "icon"          => "Graphics/UI/AIFM/SongFog",
  "weather_type"  => :Fog,
  "condition"     => proc {
    $bag.music_book.has?(AIFM_Weather[:sheetfog])
  },
  "effect"        => proc { |menu|
    pbPlayDecisionSE
    config = AIFM_Weather
    if pbConfirmMessage(_INTL("Would you alter the weather so it becomes a foggy?"))
      if pbCheckForBadge(config[:fog_needed_badge]) && pbCheckForSwitch(config[:fog_needed_switches])
        if $game_screen.weather_type == :fog
          pbMessage(_INTL("It's already foggy!"))
        else
          pbMessage(_INTL("The weather have alter!\nIt started to turn into a foggy!"))
          $game_screen.weather(:Fog, 9, 20)
          $stats.weather_count += 1
          $stats.item_weather_count += 1
          $stats.weather_fog_count += 1
          Graphics.update
          Input.update
          pbUpdateSceneMap
          next true
        end
      else
        pbMessage(_INTL("You can't alter the current weather!"))
        next false
      end
    else
      next false
    end

  }
))
