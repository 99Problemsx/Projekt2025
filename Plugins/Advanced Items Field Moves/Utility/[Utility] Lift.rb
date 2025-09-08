def check_events(target_name)
  $game_map.events.values.each do |event|
    next unless event.name == target_name && event.opacity > 0

    x = event.x
    y = event.y
    events = $game_map.events.values

    # Check for events with the same name and opacity > 0
    left_event = events.find { |e| e.name == event.name && e.x == x - 1 && e.y == y && e.opacity > 0 }
    right_event = events.find { |e| e.name == event.name && e.x == x + 1 && e.y == y && e.opacity > 0 }
    up_event = events.find { |e| e.name == event.name && e.x == x && e.y == y - 1 && e.opacity > 0 }
    down_event = events.find { |e| e.name == event.name && e.x == x && e.y == y + 1 && e.opacity > 0 }

    # Set the frame based on the presence of events
    if left_event && right_event && up_event && down_event                      #6,3
      event.direction = 6
      event.pattern = 2
    elsif left_event && right_event && up_event                                 #8,3
      event.direction = 8
      event.pattern = 2
    elsif left_event && up_event && down_event                                  #6,4
      event.direction = 6
      event.pattern = 3
    elsif right_event && up_event && down_event                                 #6,2
      event.direction = 6
      event.pattern = 1
    elsif left_event && right_event && down_event                               #4,3
      event.direction = 4
      event.pattern = 2
    elsif left_event && up_event                                                #8,4
      event.direction = 8
      event.pattern = 3
    elsif left_event && down_event                                              #4,4
      event.direction = 4
      event.pattern = 3
    elsif right_event && up_event                                               #8,2
      event.direction = 8
      event.pattern = 1
    elsif right_event && down_event                                             #4,2
      event.direction = 4
      event.pattern = 1
    elsif left_event && right_event                                             #2,3
      event.direction = 2
      event.pattern = 2
    elsif up_event && down_event                                                #6,1
      event.direction = 6
      event.pattern = 0
    elsif right_event                                                           #2,2
      event.direction = 2
      event.pattern = 1
    elsif left_event                                                            #2,4
      event.direction = 2
      event.pattern = 3
    elsif up_event                                                              #8,1
      event.direction = 8
      event.pattern = 0
    elsif down_event                                                            #4,1
      event.direction = 4
      event.pattern = 0
    else                                                                        #2,1
      event.direction = 2
      event.pattern = 0
    end
  end
end
