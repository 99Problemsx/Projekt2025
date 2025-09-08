#===============================================================================
# Berry Tree System - Sword/Shield Style by Liszt
# Version: 1.0
# For: Pokemon Essentials 21.1
#===============================================================================
module BerryTree
  include BerryTreeConfig

  def self.format_item_list(item_array)
    counts = item_array.tally
    names = counts.map do |sym, count|
      item = GameData::Item.get(sym)
      name = item.name
      if count > 1
        name = if name.downcase.end_with?("berry")
                 name.sub(/berry$/i, "Berries")
               elsif !name.end_with?("s")
                 name + "s"
               else
                 name
               end
      end
      name = "\\c[1]#{name}\\c[0]"
      "#{count} #{name}"
    end

    return names[0] if names.length == 1
    return _INTL("{1} and {2}", names[0], names[1]) if names.length == 2
    _INTL("{1} and {2}", names[0..-2].join(', '), names[-1])
  end

  def self.handle_berry_theft(state, plural = false)
    if state[:collected].any?
      stolen_count = [(state[:collected].size * STEAL_RATIO).ceil, state[:collected].size].min
      stolen = state[:collected].shift(stolen_count)
      stolen.each { |b| $bag.remove(b) }

      msg = if plural
              _INTL("Other Pokémon nearby took {1} {2} away!",
                    stolen_count, stolen_count == 1 ? _INTL("berry") : _INTL("berries"))
            else
              _INTL("The Pokémon stole {1} {2}!",
                    stolen_count, stolen_count == 1 ? _INTL("berry") : _INTL("berries"))
            end
      pbMessage(msg)
    else
      msg = plural ? _INTL("Other Pokémon scared you off before you could get any berries!") :
                     _INTL("The Pokémon scared you off before you could get any berries!")
      pbMessage(msg)
    end
  end

  def self.reset_if_needed(tree_id)
    $game_variables[BERRY_TREE_VAR] = {} unless $game_variables[BERRY_TREE_VAR].is_a?(Hash)

    state = $game_variables[BERRY_TREE_VAR][tree_id]
    return true if state.nil?

    last_time = state[:last_used]
    return true if last_time.nil?

    elapsed = pbGetTimeNow.to_i - last_time.to_i
    threshold = case RESET_TYPE
                when :hours then RESET_TIME * 3600
                when :days  then RESET_TIME * 86400
                else 86400
                end

    if elapsed >= threshold
      $game_variables[BERRY_TREE_VAR][tree_id] = nil
      return true
    end

    return false
  end

  def self.pbResetBerryTree(tree_id)
    $game_variables[BerryTreeConfig::BERRY_TREE_VAR] ||= {}
    $game_variables[BerryTreeConfig::BERRY_TREE_VAR][tree_id] = nil
  end

  def self.pbBerryTree(tree_id)
    $game_variables[BERRY_TREE_VAR] ||= {}
    reset_if_needed(tree_id)

    $game_variables[BERRY_TREE_VAR][tree_id] ||= {
      last_used: nil,
      shakes: 0,
      collected: [],
      rare_items: []
    }

    state = $game_variables[BERRY_TREE_VAR][tree_id]
    berries = TREE_BERRIES[tree_id]

    unless berries&.any?
      pbMessage(_INTL("This tree doesn’t seem to have any berries right now."))
      return
    end

    if state[:shakes] > 0
      pbMessage(_INTL("There are no more berries on the tree."))
      return
    end

    unless pbConfirmMessage(_INTL("It's a Berry tree!\nDo you want to shake it?"))
      return
    end

    pbMessage("You shake the tree...")
    shakes = 0
    max_shakes = rand(MAX_SHAKES_RANGE)

    rare_item_dropped = false
    loop do
      shakes += 1

      if rand < ENCOUNTER_CHANCE
        pbSEPlay("BerryTreeShake")
        pbMessage(_INTL("The tree is shaking violently..."))
        pbMessage(_INTL("A Pokémon jumped out of the tree!"))

        battle_outcome_var = 1
        setBattleRule("outcome", battle_outcome_var)

        pbEncounter(ENCOUNTER_TYPE)

        if $game_switches[Settings::STARTING_OVER_SWITCH]
          state[:collected].clear
          state[:rare_items].clear
          state[:shakes] = shakes
          state[:last_used] = pbGetTimeNow.to_i
          return
        end

        outcome = $game_variables[battle_outcome_var]

        case outcome
        when 1, 4
          handle_berry_theft(state, true)
        when 3
          handle_berry_theft(state)
        when 2
          state[:collected] = []
          state[:rare_items] = []
        end

        state[:shakes] = shakes
        state[:last_used] = pbGetTimeNow.to_i
        break
      end

      berries_dropped = []
      rare_items_dropped = []

      rand(BERRIES_PER_SHAKE_RANGE).times do
        berry = berries.sample
        berries_dropped << berry
        $bag.add(berry)
        state[:collected] << berry
      end

      if !rare_item_dropped && rand < RARE_ITEM_CHANCE
        rare_item = RARE_ITEMS.sample
        rare_items_dropped << rare_item
        $bag.add(rare_item)
        state[:rare_items] << rare_item
        rare_item_dropped = true
      end

      unless berries_dropped.empty?
        pbSEPlay("BerryTreeShake")
        pbWait(0.8)
        message = _INTL("\\se[BerryTreeDrop]{1} fell from the tree!", format_item_list(berries_dropped))
        pbMessage("#{message}")
      end

      rare_items_dropped.each do |item|
        item_name = GameData::Item.get(item).name
        pbMessage(_INTL("A \\c[1]{1}\\c[0] also fell from the tree!", item_name))
      end

      count = state[:collected].length
      if count > 0
        choice = pbMessage(_INTL("There {1} {2} {3} on the ground.",
                                 count == 1 ? "is" : "are",
                                 count,
                                 count == 1 ? _INTL("berry") : _INTL("berries")),
                           ["Shake it more", "Quit"], 2)
        if choice != 0
          state[:shakes] = shakes
          break
        end
      end

      if shakes >= max_shakes
        pbMessage(_INTL("There are no more berries on the tree."))
        state[:shakes] = shakes
        break
      end
    end

    state[:last_used] = pbGetTimeNow.to_i

    if state[:collected].any?
      berry_list = format_item_list(state[:collected])
      pbMessage(_INTL("You picked up the berries that fell from the ground."))
      pbMessage("\\me[Item get]" + _INTL("You got {1}!", berry_list))

      first_berry = state[:collected].first
      pocket = GameData::Item.get(first_berry).pocket
      pocket_name = PokemonBag.pocket_names[pocket - 1]

      pbMessage(_INTL("You put the {1} in your Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                      berry_list, pocket, pocket_name))
    else
      pbMessage(_INTL("There are no berries left to collect."))
    end

    if state[:rare_items].any?
      state[:rare_items].each do |item|
        item_name = GameData::Item.get(item).name
        pocket = GameData::Item.get(item).pocket
        pocket_name = PokemonBag.pocket_names[pocket - 1]

        pbMessage("\\me[Item get]" + _INTL("You also picked up a \\c[1]{1}\\c[0]!", item_name))
        pbMessage(_INTL("You put the {1} in\nyour Bag's <icon=bagPocket{2}>\\c[1]{3}\\c[0] pocket.",
                        item_name, pocket, pocket_name))
      end
    end
  end
end

if !GameData::EncounterType.exists?(BerryTreeConfig::ENCOUNTER_TYPE)
  GameData::EncounterType.register({
    :id   => BerryTreeConfig::ENCOUNTER_TYPE,
    :type => :none
  })
end

def pbBerryTree(tree_id)
  BerryTree.pbBerryTree(tree_id)
end

def pbResetBerryTree(tree_id)
  BerryTree.pbResetBerryTree(tree_id)
end