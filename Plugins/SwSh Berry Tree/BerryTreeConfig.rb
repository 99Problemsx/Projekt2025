#===============================================================================
# Berry Tree System - Sword/Shield Style - Configurations
#===============================================================================
# >> How to configure the Berry Tree system:

# 1. TREE_BERRIES:
#    Assign a list of berries to each tree ID. The key is the tree's unique ID
#    (used in the event command `pbBerryTree(id)`), and the value is an array
#    of berry symbols.
#    Example: 1 => [:ORANBERRY, :SITRUSBERRY]

# 2. ENCOUNTER_TYPE:
#    Define the type of wild encounter triggered when a Pokémon jumps from the tree.
#    This must match an existing encounter type in your PBS "encounters.txt".

# 3. BERRY_TREE_VAR:
#    This is the game variable ID used to store the state of each tree (e.g., 98).
#    You should reserve this variable and not use it for anything else.

# 4. RESET_TYPE and RESET_TIME:
#    Choose how long a tree takes to reset:
#      RESET_TYPE = :hours or :days
#      RESET_TIME = how many hours or days until the tree resets

# 5. MAX_SHAKES_RANGE:
#    The maximum number of shakes possible per tree interaction (randomized).
#    Example: (4..6) allows between 4 and 6 shakes.

# 6. ENCOUNTER_CHANCE:
#    Probability (from 0.0 to 1.0) that a wild Pokémon appears during shaking.
#    Example: 0.2 means a 20% chance.

# 7. STEAL_RATIO:
#    If a wild Pokémon appears, this is the percentage of collected berries
#    that are stolen (0.0 to 1.0).

# 8. BERRIES_PER_SHAKE_RANGE:
#    How many berries fall on each shake, randomized.
#    Example: (1..3)

# 9. RARE_ITEM_CHANCE:
#    Chance (0.0 to 1.0) of finding a rare item when shaking a tree.

# 10. RARE_ITEMS:
#     List of symbols representing possible rare item drops from trees.
#     Example: [:TINYMUSHROOM, :STARDUST, :HONEY]
#===============================================================================
module BerryTreeConfig
  TREE_BERRIES = {
    1 => [:ORANBERRY, :SITRUSBERRY, :PECHABERRY],
    2 => [:CHESTOBERRY, :LEPPABERRY],
    3 => [:FIGYBERRY, :AGUAVBERRY]
  }

  ENCOUNTER_TYPE   = :BerryTree
  BERRY_TREE_VAR   = 98

  RESET_TYPE       = :days
  RESET_TIME       = 1

  MAX_SHAKES_RANGE = (4..6)
  ENCOUNTER_CHANCE = 0.15
  STEAL_RATIO      = 0.5
  BERRIES_PER_SHAKE_RANGE = (1..3)

  RARE_ITEM_CHANCE = 0.05 # 5%
  RARE_ITEMS = [:TINYMUSHROOM, :STARDUST, :HONEY]
end
