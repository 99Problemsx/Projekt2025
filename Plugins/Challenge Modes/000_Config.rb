module ChallengeModes
  # Array of species that are to be ignored when checking for "One
  # Capture per Map" rule
  ONE_CAPTURE_WHITELIST = [
    :DIALGA, :PALKIA, :GIRATINA, :ARCEUS
  ]

  # Groups of Map IDs that should be considered as one map in the case
  # where one large map is split up into multiple small maps
  SPLIT_MAPS_FOR_ENCOUNTERS = [
    [44, 45],
    [49, 50, 51]
  ]

  # Available types for Monotype mode
  MONOTYPE_TYPES = [
    :NORMAL, :FIRE, :WATER, :ELECTRIC, :GRASS, :ICE, :FIGHTING, :POISON,
    :GROUND, :FLYING, :PSYCHIC, :BUG, :ROCK, :GHOST, :DRAGON, :DARK, :STEEL, :FAIRY
  ]

  # Randomizer settings
  RANDOMIZER_SETTINGS = {
    :wild_pokemon => true,      # Randomize wild Pokemon encounters
    :trainer_pokemon => true,   # Randomize trainer Pokemon
    :starter_pokemon => true,   # Randomize starter Pokemon
    :gift_pokemon => true,      # Randomize gift Pokemon
    :legendary_separate => true, # Keep legendaries separate from regular Pokemon
    :similar_strength => true   # Try to match Pokemon of similar strength levels
  }

  # Name and Description for all the rules that can be toggled in the challenge
  RULES = {
    :PERMAFAINT => {
      :name  => _INTL("Permafaint"),
      :desc  => _INTL("Once a Pokémon faints, it cannot be revived until the challenge ends."),
      :order => 1
    },
    :ONE_CAPTURE => {
      :name  => _INTL("One Capture per Map"),
      :desc  => _INTL("Only the first Pokémon encountered on a map can be caught and added to your party."),
      :order => 2
    },
    :SHINY_CLAUSE => {
      :name  => _INTL("Shiny Clause"),
      :desc  => _INTL("Shiny Pokemon are exempt from the \"One Capture per Map\" rule."),
      :order => 3
    },
    :DUPS_CLAUSE => {
      :name  => _INTL("Dupes Clause"),
      :desc  => _INTL("Evolution lines of owned species don't count as \"first encounters\" for the \"One Capture per Map\" rule."),
      :order => 4
    },
    :GIFT_CLAUSE => {
      :name  => _INTL("Gift Clause"),
      :desc  => _INTL("Gifted Pokémon or eggs don't count as \"first encounters\" for the \"One Capture per Map\" rule."),
      :order => 5
    },
    :MONOTYPE_MODE => {
      :name  => _INTL("Monotype Challenge"),
      :desc  => _INTL("You can only use Pokémon of a single type. Mixed-type Pokémon must have your chosen type as primary or secondary type."),
      :order => 6
    },
    :RANDOMIZER_MODE => {
      :name  => _INTL("Randomizer Mode"),
      :desc  => _INTL("Wild Pokémon, trainer Pokémon, and gifts are randomized while maintaining game balance."),
      :order => 7
    },
    :FORCE_NICKNAME => {
      :name  => _INTL("Forced Nicknames"),
      :desc  => _INTL("Any Pokémon that is caught/obtained must be nicknamed."),
      :order => 8
    },
    :FORCE_SET_BATTLES => {
      :name  => _INTL("Forced Set Battle Style"),
      :desc  => _INTL("The option to switch your Pokémon after fainting an opponent's Pokémon will not be shown."),
      :order => 9
    },
    :NO_TRAINER_BATTLE_ITEMS => {
      :name  => _INTL("No Items in Trainer Battles"),
      :desc  => _INTL("Item usage will be disabled in Trainer Battles."),
      :order => 10
    },
    :GAME_OVER_WHITEOUT => {
      :name  => _INTL("No White-out"),
      :desc  => _INTL("If all your party Pokémon faint in battle, you lose the challenge immediately."),
      :order => 11
    }
  }
end
