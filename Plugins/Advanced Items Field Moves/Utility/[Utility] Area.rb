def infront(range = 1, adjust_for_size = false, skip_name = nil)
  x = $game_player.x + ($game_player.direction == 6 ? range : ($game_player.direction == 4 ? -(range + (adjust_for_size ? 1 : 0)) : 0))
  y = $game_player.y + ($game_player.direction == 2 ? range : ($game_player.direction == 8 ? -(range + (adjust_for_size ? 1 : 0)) : 0))
  terrain_tag = $game_map.terrain_tag(x, y)
  ledge = terrain_tag.ledge
  passable = $game_map.playerPassable?(x, y, $game_player.direction) && !ledge
  front_event = $game_map.events.values.find { |event| event.x == x && event.y == y }
  if front_event && skip_name && front_event.character_name && front_event.character_name.include?(skip_name)
    event_free = true
  else
    event_free = front_event.nil? || front_event == $game_player.lifted_event || (front_event.character_name.nil? || front_event.character_name.empty?)
  end
  return { x: x, y: y, passable: passable, event_free: event_free, ledge: ledge }
end
