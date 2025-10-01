#-------------------------------------------------------------------------------
# Aliased Surf call to not shown Following Pokemon Field move animation
# when surfing
#-------------------------------------------------------------------------------
alias __followingpkmn__pbSurf pbSurf unless defined?(__followingpkmn__pbSurf)
def pbSurf(*args)
  $game_temp.no_follower_field_move = true
  old_surfing = $PokemonGlobal.current_surfing
  pkmn = $player.get_pokemon_with_move(:SURF)
  $PokemonGlobal.current_surfing = pkmn
  ret = __followingpkmn__pbSurf(*args)
  $PokemonGlobal.current_surfing = old_surfing if !ret || !pkmn
  $game_temp.no_follower_field_move = false
  return ret
end

#-------------------------------------------------------------------------------
# Aliaseds surf starting method to refresh Following Pokemon when the player
# jumps to surf
#-------------------------------------------------------------------------------
alias __followingpkmn__pbStartSurfing pbStartSurfing unless defined?(__followingpkmn__pbStartSurfing)
def pbStartSurfing(*args)
  return __followingpkmn__pbStartSurfing(*args) if !FollowingPkmn.can_check?
  
  # Execute the actual surf command first
  ret = __followingpkmn__pbStartSurfing(*args)
  
  # Only refresh sprite if follower is active and can surf
  if FollowingPkmn.active? && FollowingPkmn.waterborne_follower?
    FollowingPkmn.refresh(false)  # Refresh to swimming sprite
    # Force follower to follow immediately after surf
    event = FollowingPkmn.get_event
    if event
      # Force immediate follow
      event.follow_leader($game_player, true)
    end
  end
  
  return ret
end

#-------------------------------------------------------------------------------
# Aliased surf ending method to queue a refresh after the player jumps to stop
# surfing
#-------------------------------------------------------------------------------
alias __followingpkmn__pbEndSurf pbEndSurf unless defined?(__followingpkmn__pbEndSurf)
def pbEndSurf(*args)
  return __followingpkmn__pbEndSurf(*args) if !FollowingPkmn.can_check?
  
  # Execute the actual end surf command
  ret = __followingpkmn__pbEndSurf(*args)
  return false if !ret
  
  # Clear surfing state
  $PokemonGlobal.current_surfing = nil
  
  # Refresh sprite back to normal if follower is active
  if FollowingPkmn.active?
    FollowingPkmn.get_event&.calculate_bush_depth
    FollowingPkmn.refresh(false)  # Refresh to normal sprite
  end
  
  return ret
end

#-------------------------------------------------------------------------------
# Aliased Diving method to not show new HM Animation when diving
#-------------------------------------------------------------------------------
alias __followingpkmn__pbDive pbDive unless defined?(__followingpkmn__pbDive)
def pbDive(*args)
  $game_temp.no_follower_field_move = true
  old_diving = $PokemonGlobal.current_diving
  pkmn = $player.get_pokemon_with_move(:DIVE)
  $PokemonGlobal.current_diving = pkmn
  ret = __followingpkmn__pbDive(*args)
  $PokemonGlobal.current_diving = old_diving if !ret || !pkmn
  $game_temp.no_follower_field_move = false
  # Fix dive animation immediately by recalculating bush depth
  FollowingPkmn.get_event&.calculate_bush_depth if ret
  return ret
end

#-------------------------------------------------------------------------------
# Aliased surfacing method to not show new HM Animation when surfacing
#-------------------------------------------------------------------------------
alias __followingpkmn__pbSurfacing pbSurfacing unless defined?(__followingpkmn__pbSurfacing)
def pbSurfacing(*args)
  $game_temp.no_follower_field_move = true
  old_diving = $PokemonGlobal.current_diving
  $PokemonGlobal.current_diving = nil
  ret = __followingpkmn__pbSurfacing(*args)
  $PokemonGlobal.current_diving = old_diving if !ret
  $game_temp.no_follower_field_move = false
  # Fix surfacing animation immediately by recalculating bush depth
  FollowingPkmn.get_event&.calculate_bush_depth if ret
  return ret
end

#-------------------------------------------------------------------------------
# Aliased hidden move usage method to not show new HM animation for certain
# moves
#-------------------------------------------------------------------------------
alias __followingpkmn__pbUseHiddenMove pbUseHiddenMove unless defined?(__followingpkmn__pbUseHiddenMove)
def pbUseHiddenMove(pokemon, move)
  $game_temp.no_follower_field_move = [:SURF, :DIVE, :FLY, :DIG, :TELEPORT, :WATERFALL, :STRENGTH].include?(move)
  if move == :SURF
    old_data = $PokemonGlobal.current_surfing
    $PokemonGlobal.current_surfing = pokemon
  elsif move == :DIVE
    old_data = $PokemonGlobal.current_diving
    $PokemonGlobal.current_diving = pokemon
  end
  ret = __followingpkmn__pbUseHiddenMove(pokemon, move)
  if move == :SURF
    $PokemonGlobal.current_surfing = old_data if !ret
  elsif move == :DIVE
    $PokemonGlobal.current_diving = old_data if !ret
  end
  $game_temp.no_follower_field_move = false
  return ret
end

#-------------------------------------------------------------------------------
# Aliased Headbutt method to properly load Headbutt event for new HM Animation
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHeadbutt pbHeadbutt unless defined?(__followingpkmn__pbHeadbutt)
def pbHeadbutt(*args)
  args[0] = $game_player.pbFacingEvent(true) if args[0].nil?
  return __followingpkmn__pbHeadbutt(*args)
end

#-------------------------------------------------------------------------------
# Aliased Waterfall methd to not show new HM Animation when interacting with
# waterfall
#-------------------------------------------------------------------------------
alias __followingpkmn__pbWaterfall pbWaterfall unless defined?(__followingpkmn__pbWaterfall)
def pbWaterfall(*args)
  $game_temp.no_follower_field_move = true
  $player.get_pokemon_with_move(:WATERFALL)
  ret = __followingpkmn__pbWaterfall(*args)
  $game_temp.no_follower_field_move = false
  return ret
end

#-------------------------------------------------------------------------------
# Aliased waterfall ascending method to make sure Following Pokemon properly
# ascends the Waterfall with the player
#-------------------------------------------------------------------------------
def pbAscendWaterfall
  return if $game_player.direction != 8   # Can't ascend if not facing up
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.waterfall && !terrain.waterfall_crest
  $stats.waterfall_count += 1
  oldthrough   = $game_player.through
  oldmovespeed = $game_player.move_speed
  $game_player.through    = true
  $game_player.move_speed = 2
  loop do
    $game_player.move_up
    terrain = $game_player.pbTerrainTag
    break if !terrain.waterfall && !terrain.waterfall_crest
    while $game_player.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $game_player.through    = oldthrough
  $game_player.move_speed = oldmovespeed
end

#-------------------------------------------------------------------------------
# Aliased waterfall descending method to make sure Following Pokemon properly
# descends the Waterfall with the player
#-------------------------------------------------------------------------------
def pbDescendWaterfall
  return if $game_player.direction != 2   # Can't descend if not facing down
  terrain = $game_player.pbFacingTerrainTag
  return if !terrain.waterfall && !terrain.waterfall_crest
  $stats.waterfalls_descended += 1
  oldthrough   = $game_player.through
  oldmovespeed = $game_player.move_speed
  $game_player.through    = true
  $game_player.move_speed = 2
  loop do
    $game_player.move_down
    terrain = $game_player.pbTerrainTag
    break if !terrain.waterfall && !terrain.waterfall_crest
    while $game_player.moving?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end
  $game_player.through    = oldthrough
  $game_player.move_speed = oldmovespeed
end