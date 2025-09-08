#===============================================================================
# Shortcut
#===============================================================================
AIFM_Option                               = AdvancedItemsFieldMoves::MENU_CONFIG
AIFM_Option_Boot                          = AdvancedItemsFieldMoves::OPTION_BOOT
#Obstacle Smash
AIFM_RockSmash      = Show_RockSmash      = AdvancedItemsFieldMoves::ROCKSMASH_CONFIG
AIFM_Cut            = Show_Cut            = AdvancedItemsFieldMoves::CUT_CONFIG
AIFM_IceSmash       = Show_IceSmash       = AdvancedItemsFieldMoves::ICESMASH_CONFIG
#Enocunters
AIFM_Headbutt       = Show_Headbutt       = AdvancedItemsFieldMoves::HEADBUTT_CONFIG
AIFM_SweetScent     = Show_SweetScent     = AdvancedItemsFieldMoves::SWEETSCENT_CONFIG
#Environment Interactions
AIFM_Strength       = Show_Strength       = AdvancedItemsFieldMoves::STRENGTH_CONFIG
AIFM_Flash          = Show_Flash          = AdvancedItemsFieldMoves::FLASH_CONFIG
AIFM_Defog          = Show_Defog          = AdvancedItemsFieldMoves::DEFOG_CONFIG
AIFM_WPush                                = AdvancedItemsFieldMoves::WEATHERPUSH_CONFIG
AIFM_Weather        = Show_Weather        = AdvancedItemsFieldMoves::WEATHER_CONFIG
AIFM_Camouflage     = Show_Camouflage     = AdvancedItemsFieldMoves::CAMOUFLAGE_CONFIG
#Water Movement
AIFM_Surf           = Show_Surf           = AdvancedItemsFieldMoves::SURF_CONFIG
AIFM_Dive           = Show_Dive           = AdvancedItemsFieldMoves::DIVE_CONFIG
AIFM_Waterfall      = Show_Waterfall      = AdvancedItemsFieldMoves::WATERFALL_CONFIG
AIFM_Whirlpool      = Show_Whirlpool      = AdvancedItemsFieldMoves::WHIRLPOOL_CONFIG
#Other Movement
AIFM_Fly            = Show_Fly            = AdvancedItemsFieldMoves::FLY_CONFIG
AIFM_Dig            = Show_Dig            = AdvancedItemsFieldMoves::DIG_CONFIG
AIFM_Teleport       = Show_Teleport       = AdvancedItemsFieldMoves::TELEPORT_CONFIG
AIFM_RockClimb      = Show_RockClimb      = AdvancedItemsFieldMoves::ROCKCLIMB_CONFIG
#Other Items
AIFM_LavaSurf       = Show_LavaSurf       = AdvancedItemsFieldMoves::LAVASURF_CONFIG
AIFM_Lavafall       = Show_Lavafall       = AdvancedItemsFieldMoves::LAVAFALL_CONFIG
AIFM_LavaSwirl      = Show_LavaSwirl      = AdvancedItemsFieldMoves::LAVASWIRL_CONFIG
#Zelda Items
AIFM_Lift           = Show_Lift           = AdvancedItemsFieldMoves::LIFT_CONFIG
AIFM_SenseTruth     = Show_SenseTruth     = AdvancedItemsFieldMoves::SENSETRUTH_CONFIG
AIFM_Bomb           = Show_Bomb           = AdvancedItemsFieldMoves::BOMB_CONFIG
#Music Pockets
AIFM_Pocket1        = Show_WP1            = AdvancedItemsFieldMoves::WEATHER_P1_CONFIG
AIFM_Pocket2        = Show_WP2            = AdvancedItemsFieldMoves::WEATHER_P2_CONFIG
AIFM_Pocket3        = Show_WP3            = AdvancedItemsFieldMoves::WEATHER_P3_CONFIG
#Debug
AIFM_Debug                                = AdvancedItemsFieldMoves::DEBUG_MENU

#===============================================================================
# Utility
#===============================================================================
class MoveHandlerHash
  def delete(sym)
    @hash.delete(sym) if sym && @hash[sym]
  end
end

def pbCheckForBadge(badge = -1)
  return true if badge < 0   # No badge requirement
  if (AdvancedItemsFieldMoves::BADGE_COUNT) ? $player.badge_count >= badge : $player.badges[badge-1]
    return true
  end
end

def pbCheckForSwitch(required_switches)
  return true if required_switches.length <= 0
  required_switches.each { |switch|
    return false unless $game_switches[switch]
  }
  true
end

def pbCheckForMove(moves)
  move_names = moves[:move_name]
  uses_pp = moves[:uses_pp]
  # Variables to track Pokémon with moves
  pkmn_with_move = []
  pkmn_move_pp = {}
  pkmn_with_zero_pp = []
  # Iterate through the player's party
  $player.party.each do |pkmn|
    next unless pkmn&.moves # Skip invalid Pokémon or those without moves
    puts " #{"\e[35mTesting\e[0m".ljust(20)} #{pkmn.name.ljust(15)} \e[35mfor moves\e[0m #{move_names}" if $DEBUG
    # Check each move
    pkmn.moves.each do |move|
      next unless move && move_names.include?(move.id)
      move_name = GameData::Move.get(move.id).name
      move_pp = move.pp
      total_pp = move.total_pp
      if move_pp > 0 || !uses_pp
        # Pokémon has the move with sufficient PP (or PP is not required)
        pkmn_with_move << pkmn unless pkmn_with_move.include?(pkmn)
        pkmn_move_pp[pkmn] ||= {}
        pkmn_move_pp[pkmn][move.id] = move_pp
        puts " └►#{"\e[32m[Valid]\e[0m".ljust(18)} #{pkmn.name.ljust(15)} has \e[33m#{move_name}\e[0m with \e[32m#{move_pp}\e[0m/#{total_pp} PP" if $DEBUG
      else
        # Pokémon has the move but insufficient PP
        pkmn_with_zero_pp << pkmn unless pkmn_with_zero_pp.include?(pkmn)
        puts " └►#{"\e[31m[Zero PP]\e[0m".ljust(15)} #{pkmn.name.ljust(15)} has \e[33m#{move_name}\e[0m with \e[31m#{move_pp}\e[0m/#{total_pp} PP" if $DEBUG
      end
    end
  end
  # Handle results
  if !pkmn_with_move.empty?
    # Return Pokémon with valid moves and their PP
    $aifm_move = 1
    return (pkmn_with_move.size == 1 ? pkmn_with_move.first : pkmn_with_move), pkmn_move_pp
  elsif pkmn_with_zero_pp.size == 1
    # Notify about a single Pokémon with insufficient PP
    pkmn = pkmn_with_zero_pp.first
    #pbMessage(_INTL("{1} doesn't have enough PP to use this move!", pkmn.name))
    puts "Return False: Only one Pokémon with insufficient PP" if $DEBUG
    $aifm_move = 2
    return false
  elsif pkmn_with_zero_pp.size > 1
    # Notify about multiple Pokémon with insufficient PP
    #pbMessage(_INTL("None of your Pokémon have enough PP left!"))
    puts "Return False: Multiple Pokémon with insufficient PP" if $DEBUG
    $aifm_move = 2
    return false
  else
    # No valid Pokémon or moves found
    vaild_move_names = move_names.map { |move_id| "[#{GameData::Move.get(move_id).name}]" }.join(" ")
    puts "No Pokémon found with the required move#{move_names.size > 1 ? 's' : ''}: #{vaild_move_names}" if $DEBUG
    $aifm_move = 0
    return nil
  end
end

def pbCanUseMove(move)
  return true if move[:allow_move_debug] && $DEBUG
  pbCheckForBadge(move[:move_needed_badge]) && pbCheckForSwitch(move[:move_needed_switches])
end

def pbCheckForItem(item)
  pbCheckForBadge(item[:item_needed_badge]) && pbCheckForSwitch(item[:item_needed_switches])
end

def pbCanUseItem(item)
  return true if item[:allow_item_debug] && $DEBUG
  $bag.has?(item[:internal_name]) && pbCheckForBadge(item[:item_needed_badge]) && pbCheckForSwitch(item[:item_needed_switches])
end

def ow_mount(pkmn)
  return {pkmn: pkmn, species: pkmn.species, form: pkmn.form, gender: pkmn.gender, shiny: pkmn.shiny?, shadow: pkmn.shadow}
end

#==============================[Global Variable]================================
$animation_item_skip    = false
$animation_move_skip    = false
$ask_text_skip          = false
$aifm_move              = 0      # Move Found within PKMN

#===============================================================================
# Rock Smash Effect
#===============================================================================
def pbRockSmashRandomEncounter
  if $PokemonEncounters.encounter_triggered?(:RockSmash, false, false)
    $stats.rock_smash_battles += 1
    pbEncounter(:RockSmash)
  end
end

def pbRockSmash
  config_name = AIFM_RockSmash
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      if $PokemonSystem.animation_type == 0
        pbRockSmashAnimation
        pbWait(0.2)
      elsif $PokemonSystem.animation_type == 1
        pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      end
      $stats.rock_smash_count += 1
      $stats.item_rock_smash_count += 1
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))  unless $PokemonSystem.ask_text == 1
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.rock_smash_count += 1
        $stats.move_rock_smash_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Cut
#===============================================================================
def pbCut
  config_name = AIFM_Cut
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCutAnimation
      pbWait(0.2)
      #pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      #pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.cut_count += 1
      $stats.item_cut_count += 1
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          #pkmn = pkmn.first if moves.length > 1
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.cut_count += 1
        $stats.move_cut_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Ice Block
#===============================================================================
def pbIceSmash
  config_name = AIFM_IceSmash
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.ice_count += 1
      $stats.item_ice_count += 1
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.ice_count += 1
        $stats.move_ice_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Smash Event - [Rock Smash || Cut || Ice Smash]
#===============================================================================
#Overwrites Essentials Stuff
def pbSmashEvent(event)
  return if !event
  if event.name[/cuttree/i]
    pbSEPlay("Cut", 80)
  elsif event.name[/smashrock/i]
    pbSEPlay("Rock Smash")
  elsif event.name[/BreakIce/i]
    pbSEPlay("Ice Smash")
    if AIFM_IceSmash[:allow_drop]
      roll_and_loot(ICE_SMASH_MAIN, 1, 0)
    end
  end
  pbMoveRoute(event, [PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_LEFT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_RIGHT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_UP, PBMoveRoute::WAIT, 2])
  pbWait(0.42)
  event.erase
  $PokemonMap&.addErasedEvent(event.id)
end

#===============================================================================
# Headbutt
#===============================================================================
def pbHeadbutt(event = nil)
  config_name = AIFM_Headbutt
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.headbutt_count += 1
      $stats.item_headbutt_count += 1
      pbHeadbuttEffect(event)
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.headbutt_count += 1
        $stats.move_headbutt_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbHeadbuttEffect(event)
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

def pbHeadbuttEffect(event = nil)
  pbSEPlay("Headbutt")
  pbShakeEvent if AIFM_Headbutt[:allow_shake]
  pbWait(1.0)
  event = $game_player.pbFacingEvent(true) if !event
  a = (event.x + (event.x / 24).floor + 1) * (event.y + (event.y / 24).floor + 1)
  a = (a * 2 / 5) % 10   # Even 2x as likely as odd, 0 is 1.5x as likely as odd
  b = $player.public_ID % 10   # Practically equal odds of each value
  chance = 1                 # ~50%
  if a == b                    # 10%
    chance = 8
  elsif a > b && (a - b).abs < 5   # ~30.3%
    chance = 5
  elsif a < b && (a - b).abs > 5   # ~9.7%
    chance = 5
  end
  if rand(10) >= chance
    pbMessage(_INTL("Nope. Nothing..."))
  else
    enctype = (chance == 1) ? :HeadbuttLow : :HeadbuttHigh
    if pbEncounter(enctype)
      $stats.headbutt_battles += 1
    else
      pbMessage(_INTL("Nope. Nothing..."))
    end
  end
end

#===============================================================================
# Shake Event - [Headbutt Tree]
#===============================================================================
def pbShakeEvent
  event = get_self
  puts "#{event}"
  pbMoveRoute(event, [PBMoveRoute::DIRECTION_FIX_OFF, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_LEFT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_UP, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_RIGHT, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::TURN_DOWN, PBMoveRoute::WAIT, 2,
                      PBMoveRoute::DIRECTION_FIX_ON]) if event
end

#===============================================================================
# Sweet Scent - Not Needed - Everything need are in 02_Handler
#===============================================================================

#===============================================================================
# Strength
#===============================================================================
def pbStrength
  return if $PokemonMap.strengthUsed
  config_name = AIFM_Strength
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.strength_count += 1
      $stats.item_strength_count += 1
      $PokemonMap.strengthUsed = true
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.strength_count += 1
        $stats.move_strength_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        $PokemonMap.strengthUsed = true
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Flash
#====================================[Area]====================================#
def pbFlashArea
  darkness = $game_temp.darkness_sprite
  $PokemonGlobal.flashUsed = true
  $stats.flash_count += 1
  duration = 0.7
  pbWait(duration) do |delta_t|
    darkness.radius = lerp(darkness.radiusMin, darkness.radiusMax, duration, delta_t)
  end
end

#===============================================================================
# Defog
#===============================================================================
def pbDefog
  if $game_screen.weather_type==:Fog
    $game_screen.weather(:None, 9, 20)
    Graphics.update
    Input.update
    pbUpdateSceneMap
    return true
  end
  return false
end

#===============================================================================
# Weather Push
#===============================================================================
def pbWeatherCheck(weather)
  if ($DEBUG && Input.press?(Input::CTRL))
    $game_player.through = false
    return false
  end
  if $game_screen.weather_type == weather
    if !$bag.has?(weather.to_s.upcase + "ITEM")
      if pbWeatherMessage(weather)
        return if weather == :None
        case $game_player.direction
        when 2 # facing down, player came from up
          pbMoveRoute($game_player, [PBMoveRoute::UP])
        when 4 # facing left, player came from right
          pbMoveRoute($game_player, [PBMoveRoute::RIGHT])
        when 6 # facing right, player came from left
          pbMoveRoute($game_player, [PBMoveRoute::LEFT])
        when 8 # facing up, player came from down
          pbMoveRoute($game_player, [PBMoveRoute::DOWN])
        end
      end
    end
    return true
  end
end

def pbWeatherMessage(weather)
  pbMessage(_INTL("{1}", AIFM_WPush[weather]))
end

#===============================================================================
# [Auto Weather]
# Weatername(Enable weather distance, Disable weather distance +1, Looking for player directional)
#===============================================================================
class Game_Map
  alias weather_update update
  def update
    weather_update
    $game_map.events.each_value do |event|
      match = event.name.match(/(\w+)\((\d+),(\d+),(\w+)\)/)
      if match
        weather_type = match[1].to_sym
        start_distance = match[2].to_i
        end_distance = match[3].to_i
        direction = match[4].downcase.to_sym
        # Calculate distance between event and player
        case direction
        when :up
          distance = event.y - $game_player.y
          in_range = ($game_player.x == event.x && distance >= 0 && distance <= start_distance)
          out_of_range = ($game_player.x == event.x && [end_distance, end_distance + 1].include?(distance.abs) && $game_player.direction == 8)
        when :left
          distance = event.x - $game_player.x
          in_range = ($game_player.y == event.y && distance >= 0 && distance <= start_distance)
          out_of_range = ($game_player.y == event.y && [end_distance, end_distance + 1].include?(distance.abs) && $game_player.direction == 4)
        when :right
          distance = $game_player.x - event.x
          in_range = ($game_player.y == event.y && distance >= 0 && distance <= start_distance)
          out_of_range = ($game_player.y == event.y && [end_distance, end_distance + 1].include?(distance.abs) && $game_player.direction == 6)
        when :down
          distance = $game_player.y - event.y
          in_range = ($game_player.x == event.x && distance >= 0 && distance <= start_distance)
          out_of_range = ($game_player.x == event.x && [end_distance, end_distance + 1].include?(distance.abs) && $game_player.direction == 2)
        end
        # Trigger weather effect
        if in_range
          if $game_screen.weather_type != weather_type
            $old_weather = [$game_screen.weather_type, $game_screen.weather_max, $game_screen.weather_type == :None ? 0 : 100]
            $game_screen.weather(weather_type,1,0)
          end
        elsif out_of_range
          # Restore weather if player is facing away from event
          $game_screen.weather($old_weather[0], $old_weather[1], 1) if $old_weather
          $old_weather = nil
        end
      end
    end
  end
end

#===============================================================================
# Weather Flutes / Gadget
#===============================================================================
def pbWeatherMoveUse(move)
  move_index = AIFM_Weather[:move_name].index(move)
  if move_index
    weather_type = AIFM_Weather[:weather_type][move_index]
    $game_screen.weather(weather_type, 9, 20)
  end
end

#===============================================================================
# Camouflage
#===============================================================================
def pbVanishCheck
  wait_time = 1
  percentage = $PokemonSystem.camouflaged
  stage_count = 9
  opacity_step = (100.0 - percentage) / stage_count
  opacities = (1..stage_count).map do |i|
    (100 - (opacity_step * i)).to_i
  end
  opacities.map! { |percentage| (percentage / 100.0) * 255 }
  opacities = $PokemonGlobal.camouflage ? opacities.reverse : opacities

  # Set the opacity of the player and following Pokémon
  pbMoveRoute($game_player, opacities.map { |opacity| [PBMoveRoute::OPACITY, opacity, PBMoveRoute::WAIT, wait_time] }.flatten)
  pbMoveRoute(FollowingPkmn.get_event, opacities.map { |opacity| [PBMoveRoute::OPACITY, opacity, PBMoveRoute::WAIT, wait_time] }.flatten) if PluginManager.installed?("Following Pokemon EX")

  # Toggle camouflage
  $PokemonGlobal.camouflage = !$PokemonGlobal.camouflage
  pbWait(0.01 * stage_count)
end

def turnVisible
  pbVanishCheck
end

#===============================================================================
# Surf
#===============================================================================
def pbSurf
  config_name = AIFM_Surf
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_surf_count += 1
      pbStartSurfing
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_surf_count += 1
        mount = ow_mount(pkmn)
        $PokemonGlobal.base_pkmn_surf = mount
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbStartSurfing
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

def pbSurfing
  pbCancelVehicles
  turnVisible
  surfbgm = GameData::Metadata.get.surf_BGM
  pbCueBGM(surfbgm, 0.5) if surfbgm
  pbStartSurfing
end

#===============================================================================
# Dive - Descend
#===============================================================================
def pbDive
  config_name = AIFM_Dive
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  map_metadata = $game_map.metadata
  return false if !map_metadata || !map_metadata.dive_map_id
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm_descend], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.dive_descend_count += 1
      $stats.item_dive_descend_count += 1
      #Transfer the player to new map
      pbFadeOutIn do
        $game_temp.player_new_map_id    = map_metadata.dive_map_id
        $game_temp.player_new_x         = $game_player.x
        $game_temp.player_new_y         = $game_player.y
        $game_temp.player_new_direction = $game_player.direction
        $PokemonGlobal.surfing = false
        $PokemonGlobal.diving  = true
        $stats.dive_count += 1
        pbUpdateVehicle
        $scene.transfer_player(false)
        $game_map.autoplay
        $game_map.refresh
      end
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus_descend]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm_descend], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.dive_descend_count += 1
        $stats.move_dive_descend_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        #Transfer the player to new map
        pbFadeOutIn do
          $game_temp.player_new_map_id    = map_metadata.dive_map_id
          $game_temp.player_new_x         = $game_player.x
          $game_temp.player_new_y         = $game_player.y
          $game_temp.player_new_direction = $game_player.direction
          $PokemonGlobal.surfing = false
          $PokemonGlobal.diving  = true
          $PokemonGlobal.divingpkmn = false
          $stats.dive_count += 1
          mount = ow_mount(pkmn)
          $PokemonGlobal.base_pkmn_dive = mount
          pbUpdateVehicle
          $scene.transfer_player(false)
          $game_map.autoplay
          $game_map.refresh
        end
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name, nil, "descend")
end

#===============================================================================
# Dive - Ascent
#===============================================================================
def pbSurfacing
  config_name = AIFM_Dive
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  return if !$PokemonGlobal.diving
  surface_map_id = nil
  GameData::MapMetadata.each do |map_data|
    next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
    surface_map_id = map_data.id
    break
  end
  return if !surface_map_id
  if !config_name[:ascend_require_element]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:ascend_require_element_text]))
      $stats.dive_ascend_count += 1
      #Transfer the player to new map
      pbFadeOutIn do
        $game_temp.player_new_map_id    = surface_map_id
        $game_temp.player_new_x         = $game_player.x
        $game_temp.player_new_y         = $game_player.y
        $game_temp.player_new_direction = $game_player.direction
        $PokemonGlobal.surfing = true
        $PokemonGlobal.diving  = false
        pbUpdateVehicle
        $scene.transfer_player(false)
        surfbgm = GameData::Metadata.get.surf_BGM
        (surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
        $game_map.refresh
      end
      return true
    end
    return false
  end
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm_ascend], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.dive_ascend_count += 1
      $stats.item_dive_ascend_count += 1
      #Transfer the player to new map
      pbFadeOutIn do
        $game_temp.player_new_map_id    = surface_map_id
        $game_temp.player_new_x         = $game_player.x
        $game_temp.player_new_y         = $game_player.y
        $game_temp.player_new_direction = $game_player.direction
        $PokemonGlobal.surfing = true
        $PokemonGlobal.diving  = false
        pbUpdateVehicle
        $scene.transfer_player(false)
        surfbgm = GameData::Metadata.get.surf_BGM
        (surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
        $game_map.refresh
      end
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name) || !config_name[:ascend_require_element]
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus_ascend]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm_ascend], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.dive_ascend_count += 1
        $stats.move_dive_ascend_count += 1
        #Transfer the player to new map
        pbFadeOutIn do
          $game_temp.player_new_map_id    = surface_map_id
          $game_temp.player_new_x         = $game_player.x
          $game_temp.player_new_y         = $game_player.y
          $game_temp.player_new_direction = $game_player.direction
          $PokemonGlobal.surfing = true
          $PokemonGlobal.diving  = false
          pbUpdateVehicle
          $scene.transfer_player(false)
          surfbgm = GameData::Metadata.get.surf_BGM
          (surfbgm) ? pbBGMPlay(surfbgm) : $game_map.autoplayAsCue
          $game_map.refresh
        end
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name, nil, "ascend")
end

#===============================================================================
# Waterfall
#===============================================================================
# Starts the ascending of a waterfall.
def pbAscendWaterfall
  return if $game_player.direction != 8   # Can't ascend if not facing up
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.waterfall && !terrain.waterfall_crest
  $stats.waterfall_count += 1
  $game_player.always_on_top = true
  $PokemonGlobal.ascending_waterfall = true
  $game_player.through = true
end

# Triggers after finishing each step while ascending/descending a waterfall.
def pbTraverseWaterfall
  if $game_player.direction == 2   # Facing down; descending
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
      (!terrain.waterfall && !terrain.waterfall_crest)
      $game_player.always_on_top = false
      $PokemonGlobal.descending_waterfall = false
      $game_player.through = false
      return
    end
    $stats.waterfalls_descended += 1 if !$PokemonGlobal.descending_waterfall
    $PokemonGlobal.descending_waterfall = true
    $game_player.through = true
  elsif $PokemonGlobal.ascending_waterfall
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
      (!terrain.waterfall && !terrain.waterfall_crest)
      $game_player.always_on_top = false
      $PokemonGlobal.ascending_waterfall = false
      $game_player.through = false
      return
    end
    $PokemonGlobal.ascending_waterfall = true
    $game_player.through = true
  end
end

def spritWhirlpool
  case $game_player.direction
  when 2
    $scene.spriteset.addUserAnimation(AIFM_Whirlpool[:MoveIdDown],$game_player.x, $game_player.y - 1 ,true,3)
  when 4
    $scene.spriteset.addUserAnimation(AIFM_Whirlpool[:MoveIdLeft],$game_player.x + 0.8, $game_player.y,true,3)
  when 6
    $scene.spriteset.addUserAnimation(AIFM_Whirlpool[:MoveIdRight],$game_player.x - 0.6, $game_player.y,true,3)
  when 8
    $scene.spriteset.addUserAnimation(AIFM_Whirlpool[:MoveIdUp],$game_player.x, $game_player.y + 0.8 ,true,0)
  end
end

def pbWaterfall
  config_name = AIFM_Waterfall
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_waterfall_count += 1
      pbAscendWaterfall
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_waterfall_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbAscendWaterfall
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Whirlpool
#===============================================================================
def pbWhirlpoolMove
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.whirlpool
  $stats.whirlpool_cross_count += 1
  $PokemonGlobal.crossing_whirlpool = true
  $game_player.through = true
  if $game_player.direction == 8
    $game_player.always_on_top = true
  end
end

def pbTraverseWhirlpool
  terrain = $game_player.pbTerrainTag
  if ($DEBUG && Input.press?(Input::CTRL)) || !terrain.whirlpool
    $PokemonGlobal.crossing_whirlpool = false
    $game_player.through = false
    return
  end
  terrain = $game_player.pbTerrainTag
  if terrain.whirlpool
    $PokemonGlobal.crossing_whirlpool = true
    $game_player.through = true
  else
    $PokemonGlobal.crossing_whirlpool = false
    $game_player.through = false
    $game_player.always_on_top = false if pbWait(0.12)
  end
end

def pbWhirlpool
  config_name = AIFM_Whirlpool
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_whirlpool_cross_count += 1
      pbWhirlpoolMove
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_whirlpool_cross_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbWhirlpoolMove
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Fly
#===============================================================================
def pbFlyToNewLocation(user = nil, element = nil)
  return false if $game_temp.fly_destination.nil?
  if !$DEBUG && !pkmn
    $game_temp.fly_destination = nil
    yield if block_given?
    return false
  end
  if user.name == $player.name
    $stats.item_fly_count += 1
    pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, element)) unless $PokemonSystem.animation_item == 1
    pbCallItemAnimation(AIFM_Fly) unless $PokemonSystem.animation_item == 1
  else
    move_name = GameData::Move.get(element).name
    if AIFM_Fly[:uses_pp]
      move_index = user.moves.find_index { |m| m.id == element }
      user.moves[move_index].pp -= 1
    end
    $stats.move_fly_count += 1
    pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", user.name, GameData::Move.get(element).name)) unless $PokemonSystem.animation_move == 1
    pbCallMoveAnimation(user) unless $PokemonSystem.animation_move == 1
  end
  $stats.fly_count += 1
  pbFadeOutIn do
    pbSEPlay("Fly")
    $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
    $game_temp.player_new_x         = $game_temp.fly_destination[1]
    $game_temp.player_new_y         = $game_temp.fly_destination[2]
    $game_temp.player_new_direction = 2
    $game_temp.fly_destination = nil
    pbDismountBike
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
    yield if block_given?
    pbWait(0.25)
  end
  pbEraseEscapePoint
  return true
end

def pbFlyEvent
  config_name = AIFM_Fly
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartFlyScreen
      if ret
        $game_temp.fly_destination = ret
      end
      pbFlyToNewLocation($player, item_name)
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        scene = PokemonRegionMap_Scene.new(-1, false)
        screen = PokemonRegionMapScreen.new(scene)
        ret = screen.pbStartFlyScreen
        if ret
          $game_temp.fly_destination = ret
        end
        pbFlyToNewLocation(pkmn, move_id)
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Dig
#===============================================================================
def pbAllowDig
  escape = ($PokemonGlobal.escapePoint rescue nil)
  if escape
    pbFadeOutIn do
      $game_temp.player_new_map_id    = escape[0]
      $game_temp.player_new_x         = escape[1]
      $game_temp.player_new_y         = escape[2]
      $game_temp.player_new_direction = escape[3]
      pbDismountBike
      $scene.transfer_player
      $game_map.autoplay
      $game_map.refresh
    end
    pbEraseEscapePoint
    return true
  end
  return false
end

#===============================================================================
# Teleport
#===============================================================================
def pbAllowTeleport
  healing = $PokemonGlobal.healingSpot
  healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
  healing = GameData::Metadata.get.home if !healing   # Home
  return false if !healing
  pbFadeOutIn do
    $game_temp.player_new_map_id    = healing[0]
    $game_temp.player_new_x         = healing[1]
    $game_temp.player_new_y         = healing[2]
    $game_temp.player_new_direction = 2
    pbDismountBike
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  end
  pbEraseEscapePoint
  return true
end

#===============================================================================
# Rock Climbing
#===============================================================================
def pbStartRockClimb
  pbCancelVehicles
  $PokemonGlobal.rockclimb = true
  $game_player.through = true
  $stats.rockclimb_count += 1
  pbUpdateVehicle
  if $game_player.direction == 2
    $game_player.always_on_top = true
  end
  $game_temp.rockclimb_base_coords = $map_factory.getFacingCoords($game_player.x, $game_player.y, $game_player.direction)
  $game_player.jumpForward
end

def pbTraverseRockClimb?
  terrain = $game_player.pbTerrainTag
  if ($DEBUG && Input.press?(Input::CTRL)) || !terrain.rockclimb
    $PokemonGlobal.rockclimb = false
    $game_player.through = false
    $game_temp.ending_rockclimb = false
    pbWait(0.12)
    $game_player.always_on_top = false
    return
  end
  x_offset = ($game_player.direction == 4) ? -1 : ($game_player.direction == 6) ? 1 : 0
  y_offset = ($game_player.direction == 8) ? -1 : ($game_player.direction == 2) ? 1 : 0
  case $game_player.direction
  when 2
    if terrain.rockclimb && $game_map.terrain_tag($game_player.x, $game_player.y + 1).rockclimb
      $game_player.move_down
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdDown], $game_player.x, $game_player.y - 1.3, true, 0)
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:DebrisId], $game_player.x, $game_player.y - 0.7, true, 0)
    else
      pbEndRockClimb(x_offset, y_offset)
    end
  when 4
    if $game_map.terrain_tag($game_player.x - 1, $game_player.y).rockclimb || $game_map.terrain_tag($game_player.x - 1, $game_player.y - 1).rockclimb || $game_map.terrain_tag($game_player.x - 1, $game_player.y + 1).rockclimb
      if $game_map.terrain_tag($game_player.x - 1, $game_player.y).rockclimb
        $game_player.move_left
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdLeft], $game_player.x + 0.8, $game_player.y, true, 1)
      elsif $game_map.terrain_tag($game_player.x - 1, $game_player.y - 1).rockclimb
        $game_player.move_upper_left
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdLeft], $game_player.x + 0.8, $game_player.y, true, 1)
      elsif $game_map.terrain_tag($game_player.x - 1, $game_player.y + 1).rockclimb
        $game_player.move_lower_left
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdLeft], $game_player.x + 1, $game_player.y - 0.5, true, 1)
      end
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:DebrisId], $game_player.x + 0.5, $game_player.y, true, 1)
    else
      pbEndRockClimb(x_offset, y_offset)
    end
    if terrain.rockclimb && $game_player.pbFacingTerrainTag.rockclimb
    end
  when 6
    if $game_map.terrain_tag($game_player.x + 1, $game_player.y).rockclimb || $game_map.terrain_tag($game_player.x + 1, $game_player.y - 1).rockclimb || $game_map.terrain_tag($game_player.x + 1, $game_player.y + 1).rockclimb
      if $game_map.terrain_tag($game_player.x + 1, $game_player.y).rockclimb
        $game_player.move_right
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdRight], $game_player.x - 0.8, $game_player.y, true, 1)
      elsif $game_map.terrain_tag($game_player.x + 1, $game_player.y - 1).rockclimb
        $game_player.move_upper_right
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdRight], $game_player.x - 0.8, $game_player.y, true, 1)
      elsif $game_map.terrain_tag($game_player.x + 1, $game_player.y + 1).rockclimb
        $game_player.move_lower_right
        $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdRight], $game_player.x - 1, $game_player.y - 0.5, true, 1)
      end
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:DebrisId], $game_player.x - 0.5, $game_player.y , true, 1)
    else
      pbEndRockClimb(x_offset, y_offset)
    end
  when 8
    if terrain.rockclimb && $game_map.terrain_tag($game_player.x, $game_player.y - 1).rockclimb
      $game_player.move_up
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:MoveIdUp], $game_player.x, $game_player.y + 1.3, true, 1)
      $scene.spriteset.addUserAnimation(AIFM_RockClimb[:DebrisId], $game_player.x, $game_player.y + 0.7, true, 1)
    else
      pbEndRockClimb(x_offset, y_offset)
    end
  end
end

def pbTraverseRockClimb
  terrain = $game_player.pbTerrainTag
  if ($DEBUG && Input.press?(Input::CTRL)) || !terrain.rockclimb
    $PokemonGlobal.rockclimb = false
    $game_player.through = false
    return
  end
  terrain = $game_player.pbTerrainTag
  if terrain.rockclimb
    $PokemonGlobal.rockclimb = true
    $game_player.through = true
  else
    $PokemonGlobal.rockclimb = false
    $game_player.through = false
    $game_temp.ending_rockclimb = false
    pbWait(0.12)
    $game_player.always_on_top = false
  end
end

def pbEndRockClimb(_xOffset, _yOffset)
  return false if !$PokemonGlobal.rockclimb
  return false if $game_player.pbFacingTerrainTag.can_climb
  base_coords = [$game_player.x, $game_player.y]
  if $game_player.jumpForward
        $game_temp.rockclimb_base_coords = base_coords
    $game_temp.ending_rockclimb = true
    $game_player.always_on_top = false
    return true
  end
  return false
end

def pbRockClimb
  config_name = AIFM_RockClimb
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_rockclimb_count += 1
      pbStartRockClimb
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        mount = ow_mount(pkmn)
        $PokemonGlobal.base_pkmn_rockclimb = mount
        $stats.move_rockclimb_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbStartRockClimb
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# LavaFishing
#===============================================================================
GameData::EncounterType.register({
  :id             => :LavaRod,
  :type           => :LavaFishing
})

#===============================================================================
# Lavasurf
#===============================================================================
def pbLavaSurf
  config_name = AIFM_LavaSurf
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_lavasurf_count += 1
      pbStartLavaSurfing
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_lavasurf_count += 1
        mount = ow_mount(pkmn)
        $PokemonGlobal.base_pkmn_lavasurf = mount
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbStartLavaSurfing
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

def pbStartLavaSurfing
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.lavasurfing = true
  $stats.lavasurf_count += 1
  pbUpdateVehicle
  $game_temp.lavasurf_base_coords = $map_factory.getFacingCoords($game_player.x, $game_player.y, $game_player.direction)
  $game_player.jumpForward
end

def pbEndLavaSurf(_xOffset, _yOffset)
  return false if !$PokemonGlobal.lavasurfing
  return false if $game_player.pbFacingTerrainTag.can_lavasurf
  base_coords = [$game_player.x, $game_player.y]
  if $game_player.jumpForward
    $game_temp.lavasurf_base_coords = base_coords
    $game_temp.ending_lavasurf = true
    return true
  end
  return false
end

#===============================================================================
# Lavafall
#===============================================================================
# Starts the ascending of a lavafall.
def pbAscendLavafall
  return if $game_player.direction != 8   # Can't ascend if not facing up
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.lavafall && !terrain.lavafall_crest
  $stats.lavafall_count += 1
  $game_player.always_on_top = true
  $PokemonGlobal.ascending_lavafall = true
  $game_player.through = true
end

# Triggers after finishing each step while ascending/descending a lavafall.
def pbTraverseLavafall
  if $game_player.direction == 2 # Facing down; descending
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
      (!terrain.lavafall && !terrain.lavafall_crest)
      $game_player.always_on_top = false
      $PokemonGlobal.descending_lavafall = false
      $game_player.through = false
      return
    end
    $stats.lavafalls_descended += 1 if !$PokemonGlobal.descending_lavafall
    $PokemonGlobal.descending_lavafall = true
    $game_player.through = true
  elsif $PokemonGlobal.ascending_lavafall
    terrain = $game_player.pbTerrainTag
    if ($DEBUG && Input.press?(Input::CTRL)) ||
      (!terrain.lavafall && !terrain.lavafall_crest)
      $game_player.always_on_top = false
      $PokemonGlobal.ascending_lavafall = false
      $game_player.through = false
      return
    end
    $PokemonGlobal.ascending_lavafall = true
    $game_player.through = true
  end
end

def pbLavafall
  config_name = AIFM_Lavafall
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_lavafall_count += 1
      pbAscendLavafall
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_lavafall_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbAscendLavafall
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#===============================================================================
# Lava Swirl
#===============================================================================
def pbLavaSwirlMove
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.lavaswirl
  $stats.lavaswirl_cross_count += 1
  $PokemonGlobal.crossing_lavaswirl = true
  $game_player.through = true
  if $game_player.direction == 8
    $game_player.always_on_top = true
  end
end

def pbTraverseLavaSwirl
  terrain = $game_player.pbTerrainTag
  if ($DEBUG && Input.press?(Input::CTRL)) || !terrain.lavaswirl
    $PokemonGlobal.crossing_lavaswirl = false
    $game_player.through = false
    return
  end
  terrain = $game_player.pbTerrainTag
  if terrain.lavaswirl
    $PokemonGlobal.crossing_lavaswirl = true
    $game_player.through = true
  else
    $PokemonGlobal.crossing_lavaswirl = false
    $game_player.through = false
    $game_player.always_on_top = false if pbWait(0.12)
  end
end

def spritLavaSwirl
  case $game_player.direction
  when 2
    $scene.spriteset.addUserAnimation(AIFM_LavaSwirl[:MoveIdDown],$game_player.x, $game_player.y - 1 ,true,3)
  when 4
    $scene.spriteset.addUserAnimation(AIFM_LavaSwirl[:MoveIdLeft],$game_player.x + 0.8, $game_player.y,true,3)
  when 6
    $scene.spriteset.addUserAnimation(AIFM_LavaSwirl[:MoveIdRight],$game_player.x - 0.6, $game_player.y,true,3)
  when 8
    $scene.spriteset.addUserAnimation(AIFM_LavaSwirl[:MoveIdUp],$game_player.x, $game_player.y + 0.8 ,true,0)
  end
end

def pbLavaSwirl
  config_name = AIFM_LavaSwirl
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.item_lavaswirl_cross_count += 1
      pbLavaSwirlMove
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.move_lavaswirl_cross_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        pbLavaSwirlMove
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name)
end

#==================================[LoZ ITEMS]==================================
# Lifting Object
#===============================================================================
def pbCanLift
  event = $game_player.pbFacingEvent
  if $PokemonMap.liftUsed
    pbLiftEffect(event)
  else
    pbLift(event)
  end
end

def pbPushEvent
  return if $PokemonGlobal.lifting && $game_player.lifted_event && $game_player.lifted_event.id == get_self.id
  if !$PokemonMap.strengthUsed
    pbStrength
  else
    pbPushThisBoulder
  end
end

def pbLiftEffect(event = nil)
  event = $game_player.pbFacingEvent(true) if !event
  return if !event
  if $game_player.lifted_event && event.name[/pickup/i]
    pbMessage("You're already lifting something!")
  elsif event.name[/size/i]
    pbMessage("This rock is to heavy to be lifted!")
  elsif $PokemonMap.liftUsed == true
    $PokemonGlobal.lifting = true
    $game_player.lifted_event = event
    $game_player.lifted_event_opacity = event.opacity
    $game_player.lifted_event_always_on_top = event.always_on_top
    $game_player.lifted_event_through = event.through
    $game_player.lifted_event_heavy = event.name[/heavy/i] ? true : false
    event.opacity = 0
    event.through = true
    event.always_on_top = true
    $game_player.lifted_event_sprite_name = event.character_name
    pbUpdateVehicle
  end
end

def pbLift(event = nil)
  config_name = AIFM_Lift
  item = config_name[:internal_name]
  item_name = GameData::Item.get(item).name
  move_basic = config_name[:move_name]
  pp_check = config_name[:uses_pp]
  event = get_self if event.nil?
  match = event.name.match(/pickup\(([^)]+)\)/i)
  if match
    params = match[1].split(",")
    params.map!(&:strip)
    event_name = params.shift
  end
  # Check if the player can use the required item
  if pbCanUseItem(config_name) && config_name[:item]
    if $PokemonSystem.ask_text == 1 || pbConfirmMessage(_INTL("{1}", config_name[:text_item_comfirm], item_name, event_name))
      pbCallItemAnimation(config_name) unless $PokemonSystem.animation_item == 1
      pbMessage(_INTL("\\c[1]{1}\\c[0] used the \\c[1]{2}\\c[0]!", $player.name, item_name)) unless $PokemonSystem.animation_item == 1
      $stats.lift_count += 1
      $stats.item_lift_count += 1
      $PokemonMap.liftUsed = true
      pbLiftEffect(event)
      return true
    end
    return false
    # Check if the player can use the required move
  elsif config_name[:move]
    moves = []
    pkmn, moves_and_pp, = pbCheckForMove(config_name)
    if pkmn
      moves_and_pp.each do |pkmn, move_data|
        move_data.each do |move_id, pp|
          next unless move_id
          move_name = GameData::Move.get(move_id).name
          max_pp = GameData::Move.get(move_id).total_pp
          moves.push([move_id, move_name, $player.party.index(pkmn), { pp: pp, max_pp: max_pp }])
        end
      end
      if pbCanUseMove(config_name)
        # If there are multiple moves, use SelectMoveMenu
        if moves.length > 1 && ($PokemonSystem.moves_option == 0 || config_name[:uses_pp])
          pbMessage(_INTL("{1}", config_name[:text_move_comfirm_plus]))
          # Call pbSelectMoveMenu and store the result in selected_move
          selected_pokemon, selected_move = pbSelectMoveMenu(moves, pp_check)
          # If no move is selected, return false
          return false unless selected_move
          # Extract the Pokémon and move ID from selected_move
          pkmn = selected_pokemon
          move_id = selected_move
          move_name = GameData::Move.get(move_id).name
        else
          # Handle the case where there is only one move available
          pkmn = pkmn.is_a?(Array) ? pkmn.first : pkmn
          move_id = moves.first[0]
          move_name = GameData::Move.get(move_id).name
          return false unless pbConfirmMessage(_INTL("{1}", config_name[:text_move_comfirm], move_name , event_name))
        end
        pbCallMoveAnimation(pkmn) unless $PokemonSystem.animation_move == 1
        pbMessage(_INTL("\\c[1]{1}\\c[0] used \\c[1]{2}\\c[0]!", pkmn.name, move_name)) unless $PokemonSystem.animation_move == 1
        $stats.lift_count += 1
        $stats.move_lift_count += 1
        move = pkmn.moves.find { |m| m.id == move_id}
        move.pp -= 1 if pp_check && move
        $PokemonMap.liftUsed = true
        pbLiftEffect(event)
        return true
      end
    end
  end
  move_id = ((moves.any? unless moves.nil?) ? moves.first[0] : move_basic[0])
  move_name = GameData::Move.get(move_id).name
  failMessage(config_name, item_name, move_name, event_name)
end

#==================================[LoZ ITEMS]==================================
# Sense Truth || "Graphics/Weather/Aura" Credit to Drimer for "Lens of Truth"
#===============================================================================
# I was basing this on Dungeons & Dragons Sense Magic at first.
# But then i discovered Drimer's "Lens of Truth"
class Sprite_Character < RPG::Sprite
  class ShimmerSprite
    def initialize(viewport, character, event)
      @viewport  = viewport
      @character = character
      @event     = event
      @sprite    = Sprite.new(viewport)
      @sprite.bitmap = Bitmap.new("Graphics/Characters/truthshimmer")
      @hiddenKeywords    = AIFM_SenseTruth[:senseHidden]
      @frame_width = @sprite.bitmap.width / 4
      @frame_height = @sprite.bitmap.height / 4
    end

    def update
      @sprite.visible = visible?
      target_opacity = 154
      if !@opacity_counter
        @opacity_counter = 0
        @sprite.opacity = 0
      end
      @opacity_counter += 1

      if @opacity_counter >= 20
        @opacity_counter = 0
        if @sprite.opacity < target_opacity && @event.instance_variable_get(:@has_reveal_truth_effect)
          @sprite.opacity += 10
          @sprite.opacity = target_opacity if @sprite.opacity > target_opacity
        elsif @sprite.opacity > 0 && !@event.instance_variable_get(:@has_reveal_truth_effect)
          @sprite.opacity -= 10
          @sprite.opacity = 0 if @sprite.opacity < 0
        end
      end

      if !@frame_counter
        @directions = [0, 1, 2, 3, 3, 2, 1, 0] # Down, Left, Right, Up, Right, Left
        @direction_index = rand(@directions.size)
        @frame_counter = 0
        @frame = 0
      end
      @frame_counter += 1
      if @frame_counter >= 60
        @frame_counter = 0
        @direction_index = (@direction_index + 1) % @directions.size
        @frame = (@frame + 1) % 4
      end

      @sprite.x = @event.screen_x
      @sprite.y = @event.screen_y - 16
      @sprite.z = @character.z + 1
      @sprite.src_rect.x = 0
      @sprite.src_rect.y = @directions[@direction_index] * @frame_height
      @sprite.src_rect.width = @frame_width
      @sprite.src_rect.height = @frame_height
      @sprite.ox = @frame_width / 2
      @sprite.oy = @frame_height / 2
    end

    def visible=(value)
      return @sprite.visible = false unless value

      @sprite.visible = visible?
    end

    def dispose
      @sprite.dispose
    end

    def disposed?
      @sprite.disposed?
    end

    def visible?
      return false if @event.is_a?(Game_Player)
      return true if @sprite.opacity > 0 && @hiddenKeywords.any? { |keyword| @event.name[/#{keyword}/i] }
      return false unless @event.instance_variable_get(:@has_reveal_truth_effect)
      return true if @hiddenKeywords.any? { |keyword| @event.name[/#{keyword}/i] }
    end
  end

  alias aifm_initialize_shimmer initialize
  def initialize(viewport, character = nil)
    @shimmer = ShimmerSprite.new(viewport, self, character)
    aifm_initialize_shimmer(viewport, character)
  end

  alias aifm_shimmer_dispose dispose
  def dispose
    @shimmer&.dispose
    @shimmer = nil
    aifm_shimmer_dispose
  end

  alias aifm_shimmer_update update
  def update
    aifm_shimmer_update
    @shimmer.update
  end
end

class Game_Event
  alias aifm_initialize_sensetruth initialize
  def initialize(map_id, event, map = nil)
    aifm_initialize_sensetruth(map_id, event, map)
    @original_character_name = @character_name
    @original_direction = self.direction
    @original_pattern = self.pattern
    @original_through = self.through
    @original_opacity = self.opacity
    @original_always_on_top = self.always_on_top
    @has_reveal_truth_effect = false
  end

  def set_character_name(name)
    self.character_name = name
  end

  alias aifm_sense_truth_update update
  def update
    aifm_sense_truth_update
    config_name = AIFM_SenseTruth
    hiddenKeywords    = config_name[:senseHidden]
    illusionKeywords  = config_name[:senseIllusion]
    pkmnKeyword       = config_name[:sensePKMN]
    disable           = config_name[:senseDisable]
    disableMatch = self.name.downcase.include?(disable.downcase)
    if $PokemonGlobal.revealstepcount > 0 && inRange?(self, config_name[:senseRange]) && $PokemonGlobal.revealtruth
      @animation_speed = 60
      match = self.name.match(/#{pkmnKeyword}\(:([^,]+)(?:,\s*(\d+))?\)/i)
      if match && !disableMatch
        @has_reveal_truth_effect = true
        self.through = false
        truthpkmn = match[1]
        if truthpkmn
          pokemon = truthpkmn.capitalize
          self.character_name = "Followers/#{pokemon}"
          target_opacity = match[2] ? match[2].to_i : 255 # Set default opacity to 255 if not specified
          @opacity_counter ||= 0
          @opacity_counter += 1
          if @opacity_counter >= 20 # Update opacity every 20 frames
            @opacity_counter = 0
            if self.opacity < target_opacity
              self.opacity += 10
              self.opacity = target_opacity if self.opacity > target_opacity
            elsif self.opacity > target_opacity
              self.opacity -= 10
              self.opacity = target_opacity if self.opacity < target_opacity
            end
          end
          if !@frame_counter
            @frame_counter = 0
          end
          @frame_counter += 1
          if @frame_counter >= @animation_speed
            @frame_counter = 0
            self.pattern = (self.pattern + 1) % 4
          end
        end
      elsif hiddenKeywords.any? { |keyword| self.name[/#{keyword}/i] } && !disableMatch
        if !$game_self_switches[[self.map_id, self.id, "A"]] && !$game_temp.in_menu
          @has_reveal_truth_effect = true
        end
      elsif illusionKeywords.any? { |keyword| self.name[/#{keyword}/i] } && !disableMatch
        @has_reveal_truth_effect = true
        self.through = true
        self.always_on_top = ($game_player.x == self.x && $game_player.y == self.y) ? true : @original_always_on_top
        match = self.name.match(/Illusion(?:\((\d+)\))?/i)
        target_opacity = match && match[1] ? match[1].to_i : 51 #80% Opacity
        @opacity_counter ||= 0
        @opacity_counter += 1
        if @opacity_counter >= 20
          @opacity_counter = 0
          if self.opacity < target_opacity
            self.opacity += 10
            self.opacity = target_opacity if self.opacity > target_opacity
          elsif self.opacity > target_opacity
            self.opacity -= 10
            self.opacity = target_opacity if self.opacity < target_opacity
          end
        end
      end
    elsif @has_reveal_truth_effect
      # Reset the event's appearance
      return false if $game_player.x == self.x && $game_player.y == self.y && !$PokemonGlobal.revealtruth && illusionKeywords.any? { |keyword| self.name[/#{keyword}/i] }
      target_opacity = @original_opacity
      @opacity_counter ||= 0
      @opacity_counter += 1
      if @opacity_counter >= 20
        @opacity_counter = 0
        if self.opacity < target_opacity
          self.opacity += 10
          self.opacity = target_opacity if self.opacity > target_opacity
        elsif self.opacity > target_opacity
          self.opacity -= 10
          self.opacity = target_opacity if self.opacity < target_opacity
        end
      end
      if self.opacity == target_opacity
        self.direction = @original_direction if @original_direction != nil if self.character_name == "Truth Shine"
        self.pattern = @original_pattern if @original_pattern != nil
        self.through = @original_through if @original_through != nil
        self.character_name = @original_character_name if @original_character_name != nil
        self.always_on_top = @original_always_on_top if @original_always_on_top != nil
        @has_reveal_truth_effect = false
      end
    end
  end

  def inRange?(event, distance)
    dx = (event.x - $game_player.x).abs
    dy = (event.y - $game_player.y).abs
    return true if dx**2 + dy**2 <= distance**2
    return false
  end
end

module Graphics
  class << self
    alias aifm_senstruth_update update
    def update
      aifm_senstruth_update
      if $scene.is_a?(Scene_Map) && $PokemonGlobal.revealstepcount > 0
        if !@senseTruthRing1 || @senseTruthRing1.disposed? || !@senseTruthRing2 || @senseTruthRing2.disposed?
          @senseTruthRing1 = Sprite.new
          @senseTruthRing1.z = 100
          @senseTruthRing1.bitmap = AnimatedBitmap.new("Graphics/UI/AIFM/Aura Outer").bitmap
          @senseTruthRing1.ox = @senseTruthRing1.bitmap.width/2
          @senseTruthRing1.oy = @senseTruthRing1.bitmap.height/2
          @senseTruthRing1.x = $game_player.screen_x
          @senseTruthRing1.y = $game_player.screen_y
          @senseTruthRing1.opacity = 0
          @senseTruthRing2 = Sprite.new
          @senseTruthRing2.z = 101
          @senseTruthRing2.bitmap = AnimatedBitmap.new("Graphics/UI/AIFM/Aura Inner").bitmap
          @senseTruthRing2.ox = @senseTruthRing2.bitmap.width/2
          @senseTruthRing2.oy = @senseTruthRing2.bitmap.height/2
          @senseTruthRing2.x = $game_player.screen_x
          @senseTruthRing2.y = $game_player.screen_y
          @senseTruthRing2.opacity = 0
          @senseTruthFrame = 0
          @shockwaveFrame = 0
          @shockwaveCooldown = 0
          @firstPulseDone = false
        end
        if @firstPulseDone && (!@senseTruthRing3 || @senseTruthRing3.disposed?)
          @senseTruthRing3 = Sprite.new
          @senseTruthRing3.z = 102
          @senseTruthRing3.bitmap = AnimatedBitmap.new("Graphics/UI/AIFM/Aura Middel").bitmap
          @senseTruthRing3.ox = @senseTruthRing3.bitmap.width/2
          @senseTruthRing3.oy = @senseTruthRing3.bitmap.height/2
          @senseTruthRing3.x = $game_player.screen_x
          @senseTruthRing3.y = $game_player.screen_y
          @senseTruthRing3.opacity = 255
          @ring3FadeOut = true
          @ring3FadeOutTimer = 0
        end
        @senseTruthRing1.x = $game_player.screen_x
        @senseTruthRing1.y = $game_player.screen_y - 16
        @senseTruthRing2.x = $game_player.screen_x
        @senseTruthRing2.y = $game_player.screen_y - 16
        if @senseTruthRing3 && !@senseTruthRing3.disposed?
          @senseTruthRing3.x = $game_player.screen_x
          @senseTruthRing3.y = $game_player.screen_y - 16
        end
        @senseTruthFrame += 1
        @senseTruthRing1.angle += 1 if @senseTruthFrame % 16 == 0 #clockwise Outer Ring
        @senseTruthRing2.angle -= 1 if @senseTruthFrame % 12 == 0 #anti-clockwise Inner Ring
        if @firstPulseDone
          @senseTruthRing1.opacity += 5 if @senseTruthFrame % 8 == 0
          @senseTruthRing2.opacity += 5 if @senseTruthFrame % 8 == 0
          @senseTruthRing1.opacity = 255 if @senseTruthRing1.opacity >= 255
          @senseTruthRing2.opacity = 255 if @senseTruthRing1.opacity >= 255
        end
        if @shockwaveCooldown > 0
          @shockwaveCooldown -= 1
        elsif !@senseTruthPulse || @senseTruthPulse.disposed?
          @senseTruthPulse = Sprite.new
          @senseTruthPulse.z = 103
          @senseTruthPulse.bitmap = AnimatedBitmap.new("Graphics/UI/AIFM/Aura Middel").bitmap
          @senseTruthPulse.ox = @senseTruthPulse.bitmap.width/2
          @senseTruthPulse.oy = @senseTruthPulse.bitmap.height/2
          @senseTruthPulse.x = $game_player.screen_x
          @senseTruthPulse.y = $game_player.screen_y - 16
          @senseTruthPulse.zoom_x = 0
          @senseTruthPulse.zoom_y = 0
          @shockwaveFrame = 0
        end
        if @ring3FadeOut && @senseTruthRing3
          @ring3FadeOutTimer += 1
          if @ring3FadeOutTimer >= 60
            @senseTruthRing3.opacity -= 10
            @ring3FadeOutTimer = 0
            if @senseTruthRing3.opacity <= 0
              @ring3FadeOut = false
            end
          end
        end
        if @senseTruthPulse && !@senseTruthPulse.disposed?
          @senseTruthPulse.x = $game_player.screen_x
          @senseTruthPulse.y = $game_player.screen_y - 16
          @shockwaveFrame += 1
          if @shockwaveFrame % 4 == 0
            @senseTruthPulse.zoom_x += 0.008
            @senseTruthPulse.zoom_y += 0.008
          end
          if @senseTruthPulse.zoom_x >= 1
            @senseTruthPulse.dispose
            @senseTruthPulse = nil
            @shockwaveCooldown = 360 # wait for 360 frames before creating a new shockwave
            @firstPulseDone = true
            if @senseTruthRing3
              @senseTruthRing3.opacity = 255
              @ring3FadeOut = true
              @ring3FadeOutTimer = 0
            end
          end
        end
      else
        if @senseTruthRing1
          @senseTruthRing1.opacity -= 5 if @senseTruthFrame % 8 == 0
          @senseTruthRing1.angle += 1 if @senseTruthFrame % 8 == 0
          @senseTruthRing1.x = $game_player.screen_x
          @senseTruthRing1.y = $game_player.screen_y - 16
          if @senseTruthRing1.opacity <= 0
            @senseTruthRing1.dispose
            @senseTruthRing1 = nil
          end
        end
        if @senseTruthRing2
          @senseTruthRing2.opacity -= 5 if @senseTruthFrame % 8 == 0
          @senseTruthRing2.angle -= 1 if @senseTruthFrame % 8 == 0
          @senseTruthRing2.x = $game_player.screen_x
          @senseTruthRing2.y = $game_player.screen_y - 16
          if @senseTruthRing2.opacity <= 0
            @senseTruthRing2.dispose
            @senseTruthRing2 = nil
          end
        end
        if @senseTruthRing3
          @senseTruthRing3.opacity -= 5 if @senseTruthFrame % 8 == 0
          @senseTruthRing3.x = $game_player.screen_x
          @senseTruthRing3.y = $game_player.screen_y - 16
          if @senseTruthRing3.opacity <= 0
            @senseTruthRing3.dispose
            @senseTruthRing3 = nil
          end
        end
        if @senseTruthPulse
          @senseTruthPulse.opacity -= 5 if @senseTruthFrame % 8 == 0
          @senseTruthPulse.x = $game_player.screen_x
          @senseTruthPulse.y = $game_player.screen_y - 16
          if @senseTruthPulse.opacity <= 0
            @senseTruthPulse.dispose
            @senseTruthPulse = nil
          end
        end
        if !@senseTruthRing1 && !@senseTruthRing2 && !@senseTruthRing3 && !@senseTruthPulse
          @senseTruthFrame = 0
        else
          @senseTruthFrame += 1
        end
      end
    end
  end
end

def pbRevealTruth
  config_name = AIFM_SenseTruth
  if $PokemonGlobal.revealtruth
    if pbConfirmMessage(_INTL("{1}", config_name[:disableSenseTruth]))
      $PokemonGlobal.revealtruth = false
      $PokemonGlobal.revealstepcount = 0
    end
  else
    if !config_name[:senseCooldown] || !$PokemonGlobal.revealtruthcooldown || Time.now - $PokemonGlobal.revealtruthcooldown > config_name[:senseCooldownTime]
      $PokemonGlobal.revealtruth = true
      $PokemonGlobal.revealstepcount = config_name[:senseSteps]
      $PokemonGlobal.revealtruthcooldown = Time.now unless !config_name[:senseCooldown]
    else
      remaining_time = config_name[:senseCooldownTime] - (Time.now - $PokemonGlobal.revealtruthcooldown).to_i
      pbMessage(_INTL("You need to wait {1} seconds before using Reveal Truth again.", remaining_time))
    end
  end
end

def pbRevealTruthEnd
  $PokemonGlobal.revealtruth = false
  $PokemonGlobal.revealstepcount = 0
end

def pbRevealTruthCDR
  $PokemonGlobal.revealtruthcooldown = nil
end

#==================================[LoZ ITEMS]==================================
# Bomb
#===============================================================================
class Game_Event
  attr_accessor :blend_type

  alias aifm_initialize_bomb update
  def update
    aifm_initialize_bomb
    update_bomb
  end

  def update_bomb
    if $PokemonGlobal.bombs && $PokemonGlobal.bombs.key?(self.id)
      bomb = $PokemonGlobal.bombs[self.id]
      update_bomb_stage(bomb) if !bomb[:explosion]
      update_bomb_explosion(bomb) if bomb[:explosion] && !bomb[:delete]
      update_bomb_effect(bomb) if bomb[:aoe] && !bomb[:delete]
      update_bomb_remove(bomb) if bomb[:delete]
    end
  end

  def update_bomb_stage(bomb)
    return if $game_temp.in_menu
    bomb[:time_left] ||= bomb[:duration]
    bomb[:time_left] -= 1 / Graphics.frame_rate.to_f
    bomb[:time_left] = [bomb[:time_left], 0].max
    #puts "Bomb #{self.id} time left: #{bomb[:time_left]} seconds"
    procent = bomb[:duration] / 100.0
    @frame_counter ||= 0
    @frame_counter += 1
    bomb[:frame_counter] = @frame_counter
    if bomb[:time_left] == 0
      $game_self_switches[[$game_map.map_id, self.id, "A"]] = true
      $game_map.events[self.id].moveto(bomb[:x], bomb[:y] + 1)
      bomb[:explosion] = true
      $game_map.need_refresh = true
    elsif bomb[:time_left] <= procent * 100
      if bomb[:pokemon]
        @bomb_blend ||= 0
        @bomb_blend += 1
        bomb[:bomb_blend] = @bomb_blend

        timer = case (bomb[:time_left] / procent).to_i
          when 0..7 then 10
          when 8..14 then 20
          when 15..21 then 30
          when 22..30 then 35
          else 60
        end

        blend_types = [0, 0, 1, 0, 0, 2]
        blend_index = (@bomb_blend / (timer)) % blend_types.size
        $game_map.events[self.id].blend_type = blend_types[blend_index] unless timer >= 60
        pattern_index = (@frame_counter / 40) % 4
      else
        direction = case (bomb[:time_left] / procent).to_i
                      when 0..30 then 8
                      when 31..54 then 6
                      when 55..77 then 4
                      else 2
                    end
        pattern_index = (bomb[:time_left] != 0 ? ((@frame_counter / 40) % 3) + 1 : 0)
        $game_map.events[self.id].direction = direction
      end
    end
    $game_map.events[self.id].pattern = pattern_index
  end

  def update_bomb_explosion(bomb)
    $game_map.events[self.id].always_on_top = false if $game_map.terrain_tag($game_map.events[self.id].x, $game_map.events[self.id].y - 1, true).bridge
    animation_speed = 30
    @frame_boom_counter ||= 0
    direction = case @frame_boom_counter
    when 0..(animation_speed*4)-1 then 2
    when (animation_speed*4)..(animation_speed*8)-1 then 4
    else 8
    end
    @frame_boom_counter += 1 unless @frame_boom_counter >= (animation_speed * 8) + 2
    pattern_index = (@frame_boom_counter / animation_speed) % 4
    $game_map.events[self.id].direction = direction
    $game_map.events[self.id].pattern = pattern_index
    bomb[:aoe] = true if direction == 2 && pattern_index == 2
    if direction == 8
      $game_self_switches[[$game_map.map_id, self.id, "B"]] = true
      $game_map.need_refresh = true
    end
    if @frame_boom_counter >= (animation_speed * 8) + 2
      bomb[:delete] = true if $game_self_switches[[$game_map.map_id, self.id, "B"]]
    end
  end

  def update_bomb_effect(bomb)
    $PokemonGlobal.bombs.each do |other_bomb_id, other_bomb|
      if other_bomb_id != @event.id && $game_map.events.key?(other_bomb_id) &&
        (other_bomb[:x] - bomb[:x]).abs <= 1 && (other_bomb[:y] - bomb[:y] + (bomb[:lifted] ? -1 : 0 ) ).abs <= AIFM_Bomb[:explosion_radius]
        $PokemonGlobal.bombs[other_bomb_id][:time_left] = 0 if $PokemonGlobal.bombs[other_bomb_id][:time_left] != 0
      end
    end
    $game_map.events.each do |event_id, event|
      if event.name[/bombable/i] &&
        (event.x - bomb[:x]).abs <= 1 && (event.y - bomb[:y] + (bomb[:lifted] ? -1 : 0 ) ).abs <= AIFM_Bomb[:explosion_radius]
        event.start if !event.instance_variable_get(:@explosion_triggered_hidden)
        event.instance_variable_set(:@explosion_triggered_hidden, true)
      end
    end
  end

  def update_bomb_remove(bomb)
    @delete_counter ||= 0
    @delete_counter += 1
    if @delete_counter == 40
      $game_self_switches[[$game_map.map_id, self.id, "A"]] = false
      $game_self_switches[[$game_map.map_id, self.id, "B"]] = false
      $PokemonGlobal.bombs.delete(self.id)
      self.erase
      $game_map.events.delete(self.id)
      $PokemonMap&.addErasedEvent(self.id)
      $game_map.need_refresh = true
      @delete_counter = 0
    end
  end
end

def pbPlaceBomb(pokemon = nil)
  $PokemonGlobal.bombs ||= {}
  front = $game_player.infront(1, false, "bomb explosion")
  if front[:passable] && front[:event_free]
    #puts "Creating bomb event at coordinates (#{front[:x]}, #{front[:y]})"
    event_id = $game_map.events.keys.max + 1
    @event_data = RPG::Event.new(front[:x], front[:y])
    @event_data.id = event_id
    @event_data.name = "Pickup(Bomb) Throw(3)"

    # Page 0
    @event_data.pages[0].condition.self_switch_valid = false
    @event_data.pages[0].condition.self_switch_ch = ""
    if pokemon
      graphic_name = "Followers#{pokemon.shiny? ? " shiny" : ""}/#{pokemon.name}"
      if File.exist?("Graphics/Characters/#{graphic_name}.png")
        @event_data.pages[0].graphic.character_name = graphic_name
      else
        @event_data.pages[0].graphic.character_name = "Object ball"
      end
      @event_data.pages[0].graphic.direction = $game_player.direction
      @event_data.pages[0].graphic.blend_type = 0
      @event_data.pages[0].direction_fix = true
    else
      @event_data.pages[0].graphic.character_name = "bomb"
      @event_data.pages[0].direction_fix = true
    end
    @event_data.pages[0].trigger = 0 # Action Button
    @event_data.pages[0].through = false
    if AIFM_Bomb[:allow_lifting]
      @event_data.pages[0].list.unshift(RPG::EventCommand.new(355, 0, ["pbCanLift"]))
    end

    # Page 1
    @event_data.pages[1] = RPG::Event::Page.new
    @event_data.pages[1].condition.self_switch_valid = true
    @event_data.pages[1].condition.self_switch_ch = "A"
    @event_data.pages[1].graphic.character_name = "bomb explosion"
    @event_data.pages[1].trigger = 2 # Action Button
    @event_data.pages[1].through = true
    @event_data.pages[1].direction_fix = true
    @event_data.pages[1].always_on_top = true

    # Page 2
    @event_data.pages[2] = RPG::Event::Page.new
    @event_data.pages[2].condition.self_switch_valid = true
    @event_data.pages[2].condition.self_switch_ch = "B"
    @event_data.pages[2].graphic.character_name = ""
    @event_data.pages[2].trigger = 2 # Action Button
    @event_data.pages[2].through = true
    @event_data.pages[2].direction_fix = true
    @event_data.pages[2].always_on_top = true

    @game_event = Game_Event.new($game_map.map_id, @event_data)
    $game_map.events[@event_data.id] = @game_event
    $game_map.events[@event_data.id].moveto(front[:x], front[:y])
    $game_map.events[@event_data.id].refresh
    $PokemonGlobal.bombs[event_id] = {   duration: AIFM_Bomb[:bomb_timer],
                                                x: front[:x],
                                                y: front[:y],
                                           lifted: false,
                                        explosion: false,
                                       pokemon: (pokemon == nil ? false : true) }
    $scene.disposeSpritesets
    $scene.createSpritesets
    return @game_event
  end
  return nil
end

def pbBombThisEvent
  event = get_self
  return false unless event.instance_variable_get(:@explosion_triggered_hidden)
  pbBombEvent(event) if event
  @index += 1
  return true
end

def pbBombEvent(event)
  return if !event
  if event.name[/bombable/i]
    pbSEPlay("Cut", 80)
  end
  $game_self_switches[[$game_map.map_id, event.id, "A"]] = true
  if event.name[/bombable/i]
    pbSEPlay("Mining found all", 80)
  end
  event.erase
  $game_map.events.delete(event.id)
  $PokemonMap&.addErasedEvent(event.id)
  $game_map.need_refresh = true
end

EventHandlers.add(:on_leave_map, :dispose_bomb_data,
  proc {
    $PokemonGlobal.bombs = nil
  }
)

#===============================================================================
# Error Message
#===============================================================================
def failMessage(config_name, item_name, move_name, event_name = nil, extra = nil)
  item_badge = config_name[:text_item_badge].to_s + (config_name[:item_needed_badge] > 1 ? "s" : "")
  move_badge = config_name[:text_move_badge].to_s + (config_name[:move_needed_badge] > 1 ? "s" : "")
  suffix = extra ? "_#{extra}" : ""
  # Both item and move required
  if config_name[:item] && config_name[:move]
    if !$bag.has?(config_name[:internal_name]) && !pbCheckForItem(config_name) && $aifm_move == 0
      puts "Fail (Both - 1)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:"missing_element_both#{suffix}"], item_name, move_name, event_name))
      $aifm_move = -1
    elsif ($bag.has?(config_name[:internal_name]) && !pbCheckForItem(config_name))
      puts "Fail (Both - 2)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_bagde_item], config_name[:item_needed_badge], item_badge, item_name))
    elsif $aifm_move == 1
      puts "Fail (Both - 3)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_bagde_move], config_name[:move_needed_badge], move_badge, move_name))
      $aifm_move = -1
    elsif $aifm_move == 2
      puts "Fail (Both - 4)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_PP]))
      $aifm_move = -1
    end
    return false
  end

  # Only item required
  if config_name[:item] && !config_name[:move]
    if !$bag.has?(config_name[:internal_name]) && !pbCheckForItem(config_name)
      puts "Fail (Item - 1)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:"missing_element_item#{suffix}"], item_name, event_name))
    else
      puts "Fail (Item - 2)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_bagde_item], config_name[:item_needed_badge], item_badge, item_name))
    end
    return false
  end

  # Only move required
  if !config_name[:item] && config_name[:move]
    if $aifm_move == 0
      puts "Fail (Move - 3)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:"missing_element_move#{suffix}"], move_name, event_name))
      $aifm_move = -1
    elsif $aifm_move == 1
      puts "Fail (Move - 1)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_bagde_move], config_name[:move_needed_badge], move_badge, move_name))
      $aifm_move = -1
    elsif $aifm_move == 2
      puts "Fail (Move - 2)" if $DEBUG
      pbMessage(_INTL("{1}", config_name[:missing_PP]))
      $aifm_move = -1
    end
    return false
  end
  puts "Fail (Nothing - 1)" if $DEBUG
  pbMessage(_INTL("{1}", config_name[:"both_disable#{suffix}"], event_name))
  return false # Default return value
end
