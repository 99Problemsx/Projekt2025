#-------------------------------------------------------------------------------
# Main Module for handling challenge data
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Extend PokemonGlobalMetadata to include new challenge variables
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :challenge_monotype_type
  attr_accessor :challenge_randomizer_seed
  attr_accessor :challenge_randomizer_map
end

module ChallengeModes
  @@started = false

  module_function
  #-----------------------------------------------------------------------------
  # check if challenge is on, toggle challenge state and get rules
  #-----------------------------------------------------------------------------
  def running?; return $PokemonGlobal && $PokemonGlobal.challenge_started; end

  def on?(rule = nil)
    return false if !(running? && @@started)
    return rule.nil? ? true : rules.include?(rule)
  end

  def toggle(force = nil); @@started = force.nil? ? !@@started : force; end

  def rules; return ($PokemonGlobal && $PokemonGlobal.challenge_rules) || []; end
  #-----------------------------------------------------------------------------
  # Main command to start the challenge
  #-----------------------------------------------------------------------------
  def start
    $PokemonGlobal.challenge_rules = select_mode
    return if $PokemonGlobal.challenge_rules.empty?
    $PokemonGlobal.challenge_qued  = true
    $PokemonGlobal.challenge_encs  = {}
    return if !$bag
    GameData::Item.each do |item|
      next if !item.is_poke_ball? || !$bag.has?(item)
      begin_challenge
      pbMessage(_INTL("Your Challenge has begun! Good Luck!"))
      return
    end
  end
  #----------------------------------------------------------------------------
  # Script command to begin challenge
  #----------------------------------------------------------------------------
  def begin_challenge
    @@started                             = true
    $PokemonGlobal.challenge_started      = true
    $PokemonGlobal.challenge_qued         = false
    $PokemonSystem.battlestyle            = 1 if $PokemonGlobal.challenge_rules.include?(:FORCE_SET_BATTLES)
    $PokemonSystem.givenicknames          = 0 if $PokemonGlobal.challenge_rules.include?(:FORCE_NICKNAME)
    
    # Initialize challenge variables if they don't exist
    $PokemonGlobal.challenge_monotype_type = nil if !$PokemonGlobal.challenge_monotype_type
    $PokemonGlobal.challenge_randomizer_seed = nil if !$PokemonGlobal.challenge_randomizer_seed
    $PokemonGlobal.challenge_randomizer_map = nil if !$PokemonGlobal.challenge_randomizer_map
    
    # Initialize Monotype mode
    if $PokemonGlobal.challenge_rules.include?(:MONOTYPE_MODE)
      select_monotype_type if !$PokemonGlobal.challenge_monotype_type
    end
    
    # Initialize Randomizer mode
    if $PokemonGlobal.challenge_rules.include?(:RANDOMIZER_MODE)
      initialize_randomizer if !$PokemonGlobal.challenge_randomizer_seed
    end
  end
  #-----------------------------------------------------------------------------
  # Clear all challenge data and stop the challenge
  #-----------------------------------------------------------------------------
  def reset
    @@started                             = false
    return if !$PokemonGlobal
    $PokemonGlobal.challenge_qued         = nil
    $PokemonGlobal.challenge_encs         = nil
    $PokemonGlobal.challenge_started      = nil
    pbEachPokemon do |pkmn, _|
      next if !pkmn.respond_to?(:perma_faint)
      pkmn.perma_faint = false
    end
    # Intentionally not resetting rules so that they can be assessed later in case of loss
  end
  #-----------------------------------------------------------------------------
  # Commands to signify victory/loss in challenge
  #-----------------------------------------------------------------------------
  def set_victory(should_reset = false)
    return if !ChallengeModes.on?
    num = $PokemonGlobal.hallOfFameLastNumber
    num = 0 if num < 0
    $PokemonGlobal.challenge_state[num] = [:VICTORY, ChallengeModes.rules.clone]
    reset if should_reset
  end

  def won?(hall_no = -1)
    if hall_no == -1
      return $PokemonGlobal.challenge_state.values.any? { |v| v.is_a?(Array) && v[0] == :VICTORY }
    else
      return false if !$PokemonGlobal.challenge_state[hall_no].is_a?(Array)
      return $PokemonGlobal.challenge_state[hall_no][0] == :VICTORY
    end
  end

  def set_loss(should_reset = true)
    num = $PokemonGlobal.hallOfFameLastNumber
    num = 0 if num < 0
    return if !ChallengeModes.on? || ChallengeModes.won?(num)
    $PokemonGlobal.challenge_state[num] = [:LOSS, ChallengeModes.rules.clone]
    reset if should_reset
  end

  def lost?(hall_no = -1)
    if hall_no == -1
      return $PokemonGlobal.challenge_state.values.any? { |v| v.is_a?(Array) && v[0] == :LOSS }
    else
      return false if !$PokemonGlobal.challenge_state[hall_no].is_a?(Array)
      return $PokemonGlobal.challenge_state[hall_no][0] == :LOSS
    end
  end
  #-----------------------------------------------------------------------------
  # Set and check for encounter on map
  #-----------------------------------------------------------------------------
  def set_first_encounter(pkmn, owned_flag = nil)
    return if !ChallengeModes.on?(:ONE_CAPTURE)
    return if $mystery_gift
    sp_data  = GameData::Species.get_species_form(pkmn.species, pkmn.form)
    captured = true
    captured = false if ChallengeModes::ONE_CAPTURE_WHITELIST.any? { |s| pkmn.isSpecies?(s) }
    captured = false if sp_data.has_flag?("OneCaptureWhitelist")
    if ChallengeModes.on?(:DUPS_CLAUSE)
      sp_data.get_family_species.each do |pk| 
        captured = false if owned_flag.nil? ? $player.owned?(pk) : owned_flag
      end
    end
    captured = false if ChallengeModes.on?(:SHINY_CLAUSE) && pkmn.shiny?
    return if !captured
    map_id = $game_map.map_id
    $PokemonGlobal.challenge_encs[map_id] = true
    ChallengeModes::SPLIT_MAPS_FOR_ENCOUNTERS.each do |map_grp|
      next if !map_grp.include?(map_id)
      map_grp.each { |m| $PokemonGlobal.challenge_encs[m] = true }
    end
  end

  def had_first_encounter?(pkmn = nil)
    return false if !ChallengeModes.on?(:ONE_CAPTURE)
    return false if pkmn && pkmn.shiny? && ChallengeModes.on?(:SHINY_CLAUSE)
    return false if $mystery_gift
    map_id = $game_map.map_id
    return true if $PokemonGlobal.challenge_encs[map_id]
    ChallengeModes::SPLIT_MAPS_FOR_ENCOUNTERS.each do |map_grp|
      next if !map_grp.include?(map_id)
      map_grp.each { |m| return true if $PokemonGlobal.challenge_encs[m] }
    end
    return false
  end

  #-----------------------------------------------------------------------------
  # Monotype mode methods
  #-----------------------------------------------------------------------------
  def select_monotype_type
    type_names = []
    MONOTYPE_TYPES.each { |type| type_names.push(GameData::Type.get(type).name) }
    type_names.push(_INTL("Cancel"))
    
    selected = pbMessage(_INTL("Choose your Monotype:"), type_names)
    if selected >= 0 && selected < MONOTYPE_TYPES.length
      $PokemonGlobal.challenge_monotype_type = MONOTYPE_TYPES[selected]
      type_name = GameData::Type.get($PokemonGlobal.challenge_monotype_type).name
      pbMessage(_INTL("You have chosen {1}-type Pokémon for your Monotype challenge!", type_name))
    else
      return false
    end
    return true
  end
  
  def valid_monotype_pokemon?(pokemon)
    return true if !on?(:MONOTYPE_MODE)
    return false if !$PokemonGlobal.challenge_monotype_type
    
    chosen_type = $PokemonGlobal.challenge_monotype_type
    species_data = pokemon.is_a?(Pokemon) ? pokemon.species_data : GameData::Species.get(pokemon)
    
    return species_data.types.include?(chosen_type)
  end
  
  #-----------------------------------------------------------------------------
  # Randomizer mode methods  
  #-----------------------------------------------------------------------------
  def initialize_randomizer
    # Create a seed based on current time and trainer ID
    seed = Time.now.to_i + $player.id
    $PokemonGlobal.challenge_randomizer_seed = seed
    $PokemonGlobal.challenge_randomizer_map = {}
    # Randomizer silently initialized (no message to avoid cluttering the game)
  end
  
  def get_randomized_species(original_species, is_legendary = false, level = 1)
    return original_species if !on?(:RANDOMIZER_MODE)
    
    # Use the original species as part of the key for consistent randomization
    key = original_species.to_s + (is_legendary ? "_legendary" : "_normal")
    
    # If we already randomized this species, return the same result
    if $PokemonGlobal.challenge_randomizer_map[key]
      return $PokemonGlobal.challenge_randomizer_map[key]
    end
    
    # Get list of possible Pokemon
    possible_species = []
    GameData::Species.each do |species|
      next if species.form != 0  # Only base forms
      next if species.mega_stone || species.mega_move  # No mega evolutions
      
      # Separate legendaries if setting is enabled
      species_is_legendary = species.has_flag?("Legendary") || species.has_flag?("Mythical")
      if RANDOMIZER_SETTINGS[:legendary_separate]
        next if is_legendary != species_is_legendary
      end
      
      # Try to match similar strength levels
      if RANDOMIZER_SETTINGS[:similar_strength] && level > 1
        species_bst = species.base_stats.values.sum
        original_bst = GameData::Species.get(original_species).base_stats.values.sum
        next if (species_bst - original_bst).abs > 100  # BST difference threshold
      end
      
      possible_species.push(species.species)
    end
    
    # Select random species using seeded randomization
    srand($PokemonGlobal.challenge_randomizer_seed + original_species.to_s.hash)
    randomized_species = possible_species.sample
    srand()  # Reset random seed
    
    # Store the mapping for consistency
    $PokemonGlobal.challenge_randomizer_map[key] = randomized_species
    
    return randomized_species
  end

  #-----------------------------------------------------------------------------
end