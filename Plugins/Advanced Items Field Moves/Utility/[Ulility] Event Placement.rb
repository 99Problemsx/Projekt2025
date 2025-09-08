def eventInfo(get_self = @event_id)
  event_id = get_self
  event = $game_map.events[event_id]

  if event

    puts "-----=[Event Info]=-------------------------"
    puts "Event ID: #{event.id}"
    puts "Event Name: #{event.name}"
    puts "Event X: #{event.x}"
    puts "Event Y: #{event.y}"
    puts "Tile ID: #{event.instance_variable_get(:@tile_id)}"
    puts "-----=[Graphic Info]=-----------------------"
    puts "Event Character Name: #{event.character_name}"
    puts "Event Character Hue: #{event.instance_variable_get(:@character_hue)}"
    puts "Event Direction: #{event.direction}"
    puts "Event Pattern: #{event.pattern}"
    puts "Event Blend Type: #{event.instance_variable_get(:@blend_type)}"
    puts "Event Opacity: #{event.instance_variable_get(:@opacity)}"
    puts "-----=[Autonomous Movement Info]=-----------"
    puts "Event Move Type: #{event.instance_variable_get(:@move_type)}"
    puts "Event Move Speed: #{event.instance_variable_get(:@move_speed)}"
    puts "Event Move Frequency: #{event.instance_variable_get(:@move_frequency)}"
    puts "-----=[Option Info]=------------------------"
    puts "Event walk_anime: #{event.instance_variable_get(:@walk_anime)}"
    puts "Event step_anime: #{event.instance_variable_get(:@step_anime)}"
    puts "Event direction_fix: #{event.instance_variable_get(:@direction_fix)}"
    puts "Event through: #{event.through}"
    puts "Event always_on_top: #{event.instance_variable_get(:@always_on_top)}"
    puts "-----=[Trigger Info]=-----------------------"
    puts "Event trigger: #{event.instance_variable_get(:@trigger)}"
    puts "-----=[Event Conditions]=-------------------"
    if event.instance_variable_get(:@page)
      c = event.instance_variable_get(:@page).condition
      puts "Switch 1 Valid: #{c.switch1_valid}"
      puts "Switch 1 ID: #{c.switch1_id}"
      puts "Switch 2 Valid: #{c.switch2_valid}"
      puts "Switch 2 ID: #{c.switch2_id}"
      puts "Variable Valid: #{c.variable_valid}"
      puts "Variable ID: #{c.variable_id}"
      puts "Variable Value: #{c.variable_value}"
      puts "Self Switch Valid: #{c.self_switch_valid}"
      puts "Self Switch: #{c.self_switch_ch}"
    else
      puts "No conditions"
    end
    puts "-----=[Event Commands]=---------------------"
    puts "Event list: #{event.instance_variable_get(:@list)}"

  else
    puts "Event not found"
  end
end
