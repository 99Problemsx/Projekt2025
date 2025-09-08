#===============================================================================
# Configuration
#===============================================================================
# :internal_name    -> has to be an unique name, the name you define for the item in the PBS file
# :item             -> defines if this should be an item, where it able to be used, if set to false you do not have to add an item to the PBS file.
# :move             -> defines if this should be a active move, if it set to false it will disable the move to be used as an in the overworld
# :needed_badge     -> the id of the badge required in order to use the item (0 means no badge required)
# :needed_switches  -> the switches that needs to be active in order to use the item (leave the brackets empty for no switch requirement. example: [4,22,77] would mean that the switches 4, 22 and 77 must be active)
# :use_in_debug     -> when true this item can be used in debug regardless of the requirements
# :number_terrain   -> has the number for the giving Terrain Tag
#===============================================================================
# Options
#===============================================================================
module AdvancedItemsFieldMoves
# Enables the total count of bagde instead of a specific/unique bagde
  BADGE_COUNT = true                                    # Default: false

  MENU_CONFIG = {
#   Allow option Sub Menu to show
    :option                             => true,                    # Default: true
#   Allow show inside Sub Menu
    :animation_option                   => true,                    # Default: true
    :text_option                        => true,                    # Default: true
    :moves_option                       => true,                    # Default: true
    :camouflage_option                  => true,                    # Default: true
# Not in use atm    :surf_option                        => true,                    # Default: true
  }

  OPTION_BOOT = {
    :item_animation                     => 0, # Item animation is Always shown when used.   0 = Always 1  = Disable
    :item_animation_type                => 0, # New Item animation type, Rock Smash or Cut. 0 = New 1     = Old
    :move_animation                     => 0, # Move animation is Always shown when used.   0 = Always    = Disable
    :ask_text                           => 0, # Ask if you like to use Item or Move.        0 = Normal    = Disable
    :moves_option                       => 0 # Multiple Hidden moves Menu Show or Fastest   0 = Show      = Fastest
  }

#===============================================================================
# DEBUG_MENU
#===============================================================================
# Shows Toggle for the config in Debug
  DEBUG_MENU = {
#   Can also been called via Script using aifm_configurations
# it Shows what is active
# if Item can be used
# if Move can be used and if move uses PP
   :boot                                => true,                   # Default: false
   :showbootpocket                      => true,                   # Default: false
#   Show Drop in Debug menu when rolled
   :showDrops                           => false,                   # Default: false
  }
#===============================================================================
# Obstacle Smash
#===============================================================================
# Cannon HM
  ROCKSMASH_CONFIG = {
    #===================[Item Config]===================#
      :internal_name                    => :ROCKSMASHITEM,         # :ROCKSMASHITEM
      :item                             => true,                   # Default: true
      :item_needed_badge                => 0,                      # Default: 0
      :item_needed_switches             => [],                     # Default: []
      :allow_item_debug                 => false,                  # Default: false
    #===================[Move Config]===================#
      :move_name                        => [:ROCKSMASH],           # :ROCKSMASH
      :move                             => true,                   # Default: true
      :uses_pp                          => false,                  # Default: false
      :move_needed_badge                => 0,                      # Default: 0
      :move_needed_switches             => [],                     # Default: []
      :allow_move_debug                 => false,                  # Default: false
    #===================[Text Config]===================#
      #===[Item Text]===#
          :text_item_badge              => "Badge",
          :text_item_comfirm            => "This rock seems breakable.\nWould you like to use the \\c[1]{2}\\c[0]?", # {2} = Item
      #===[Move Text]===#
          :text_move_badge              => "Badge",                #
          :text_move_comfirm            => "This rock seems breakable with a move.\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move (Single only)
          :text_move_comfirm_plus       => "This rock seems breakable with a move.\nWhich move would you like to use?", #(mulitple choice)
          #[Missing PP]
          :missing_PP                   => "Not enough \\c[1]PP\\c[0]...",
      #===[Interact Failed Text]===#
          #[Missing Item and Move] if Both are Enable
          :missing_element_both         => "It's a rugged rock but the \\c[1]{2}\\c[0] or \\c[1]{3}\\c[0] may be able to smash it.", # {2} = item name, {3} = move name (first if mulitple choice)
          #[IDLE] if Both are Disable
          :both_disable                 => "It's a strudy rock but the nothing would be able to smash it.", # {2} = item name, {3} = move name (first if mulitple choice)
          #[Missing Item] if Item is Enable and Move is Disable
          :missing_element_item         => "It's a rugged rock but the \\c[1]{2}\\c[0] may be able to smash it.", # {2} = item_name
          #[Player has Item - Missing Bagde] - {2} = number of badges
          :missing_bagde_item           => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
          #[Missing Move] if Move is Enable and Item is Disable
          :missing_element_move         => "It's a rugged rock, but the move \\c[1]{2}\\c[0] may be able to smash it.", # {2} = move name (first if mulitple choice)
          #[Pokémon have Move - Missing Bagde]
          :missing_bagde_move           => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)

  }
# Cannon HM
  CUT_CONFIG = {
    #===================[Item Config]===================#
      :internal_name                    => :CUTITEM,                # :CUTITEM
      :item                             => true,                    # Default: true
      :item_needed_badge                => 0,                       # Default: 0
      :item_needed_switches             => [],                      # Default: []
      :allow_item_debug                 => false,                   # Default: false
    #===================[Move Config]===================#
      :move_name                        => [:CUT],                  # :CUT
      :move                             => true,                    # Default: true
      :uses_pp                          => false,                   # Default: false
      :move_needed_badge                => 0,                       # Default: 0
      :move_needed_switches             => [],                      # Default: []
      :allow_move_debug                 => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "This tree looks like it can be cut down!\nWould you like to use the \\c[1]{2}\\c[0]?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "This tree looks like it can be cut down!\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move (Single only)
        :text_move_comfirm_plus         => "This tree looks like it can be cut down!\nWhich move would you like to use?", #(mulitple choice)
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "This tree looks like it can be cut down, a \\c[1]{2}\\c[0] or \\c[1]{3}\\c[0] may be able to do it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "It's a strudy tree but the nothing would be able to cut it down.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "This tree looks like it can be cut down, a \\c[1]{2}\\c[0] may be able to do it.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "This tree looks like it can be cut down, a Pokémon with \\c[1]{2}\\c[0] may be able to do it.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
# Custom
  ICESMASH_CONFIG = {
    #===================[Item Config]===================#
      :internal_name                    => :ICESMASHITEM,           # :ICESMASHITEM
      :item                             => true,                    # Default: true
      :item_needed_badge                => 0,                       # Default: 0
      :item_needed_switches             => [],                      # Default: []
      :allow_item_debug                 => false,                   # Default: false
    #===================[Move Config]===================#
      :move_name                        => [:EMBER],                # :EMBER
      :move                             => true,                    # Default: true
      :uses_pp                          => false,                   # Default: false
      :move_needed_badge                => 0,                       # Default: 0
      :move_needed_switches             => [],                      # Default: []
      :allow_move_debug                 => false,                   # Default: false
    #===================[Drop]==========================#
      :allow_drop                       => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "This icy obstruction appears fragile\nWould you like to use the \\c[1]{2}\\c[0]?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "This icy obstruction appears fragile.\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "This icy obstruction appears fragile.\nWhich move would you like to use?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "This icy obstruction appears to be breakable, Maybe a strong impact could shattered it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "This icy obstruction appears to be unbreakable.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "This icy obstruction appears to be breakable. The \\c[1]{2}\\c[0] could shattered it.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "This icy obstruction appears to be breakable. \\c[1]{2}\\c[0] may be able to shattered it.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
#===============================================================================
# Enocunters
#===============================================================================
# Cannon Move
  HEADBUTT_CONFIG = {
    #===================[Item Config]===================#
      :internal_name                    => :HEADBUTTITEM,           # :HEADBUTTITEM
      :item                             => true,                    # Default: true
      :item_needed_badge                => 0,                       # Default: 0
      :item_needed_switches             => [],                      # Default: []
      :allow_item_debug                 => false,                   # Default: false
    #===================[Move Config]===================#
      :move_name                        => [:HEADBUTT],             # :HEADBUTT
      :move                             => true,                    # Default: true
      :uses_pp                          => false,                   # Default: false
      :move_needed_badge                => 0,                       # Default: 0
      :move_needed_switches             => [],                      # Default: []
      :allow_move_debug                 => false,                   # Default: false
    #===================[Drop]==========================#
      :allow_shake                      => true,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "A Pokémon could be in this tree.\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "A Pokémon could be in this tree.\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "A Pokémon could be in this tree.\nWhich move would you like to use?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "A Pokémon could be in this tree. Perhaps shaking the tree will cause a reaction.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "A Pokémon could be in this tree. But this tree won't budge an inch.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "A Pokémon could be in this tree. Perhaps shaking the tree will cause a reaction.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "A Pokémon could be in this tree. Perhaps shaking the tree will cause a reaction.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
}
# Cannon Move
  SWEETSCENT_CONFIG = {
    #===================[Item Config]===================#
      :internal_name                    => :SWEETSCENTITEM,         # :SWEETSCENTITEM
      :item                             => true,                    # Default: true
      :item_needed_badge                => 0,                       # Default: 0
      :item_needed_switches             => [],                      # Default: []
      :allow_item_debug                 => false,                   # Default: false
    #===================[Move Config]===================#
      :move_name                        => [:SWEETSCENT],           # :SWEETSCENT
      :move                             => true,                    # Default: true
      :uses_pp                          => false,                   # Default: false
      :move_needed_badge                => 0,                       # Default: 0
      :move_needed_switches             => [],                      # Default: []
      :allow_move_debug                 => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
    #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
#===============================================================================
# Environment Interactions
#===============================================================================
# Cannon HM
  STRENGTH_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :STRENGTHITEM,           # :STRENGTHITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:STRENGTH],             # :STRENGTH
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
        #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "It's a big boulder.\nWould you like to use the \\c[1]{2}\\c[0] to push it?", # {2} = Item
        #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "It's a big boulder.\nWould you like to use \\c[1]{2}\\c[0] to push it?", # {2} = Move
        :text_move_comfirm_plus         => "It's a big boulder.\nWhich move would you like to use to push it?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "It's a big boulder, but a something may be able to push it aside.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "It's a big boulder, but nothing would move it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "It's a big boulder, but an {2} may be able to push it aside.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "A new \\c[1]{2}\\c[0] is required to use the \\c[1]{3}\\c[0] in the wild", # {2} = text_item_badge, {3} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "It's a big boulder, but {2} may be able to push it aside.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "A new \\c[1]{2}\\c[0] is required to use \\c[1]{3}\\c[0] in the wild.", # {2} = text_move_badge, {3} = move name
}
# Cannon HM
  FLASH_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :FLASHITEM,              # :FLASHITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:FLASH],                # :FLASH
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
# Cannon HM
  DEFOG_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :DEFOGITEM,              # :DEFOGITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:DEFOG],                # :DEFOG
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
  WEATHERPUSH_CONFIG = {
    #===================[Weather Text]===================#
    # This Section is Control auto weather and pushing the player away
    # If the Sandstrom is to Strong and you need a Go-Googles to pass
    # OR if the Fog is too dense and you need Defog to continue

    # Event Name "Fog(4,6,Left)" this can create the weather if it see the player in the any direction if will create fog
    # it also disable the weather and restore the orginale weather there was before
    # First number is tiles to player to add weather
    # Secound Number of tiles to player facing away from the event in same Looking line
    # Scriptevent, "pbWeatherCheck(:Fog)" and if it fog the puch player back in the opposite direction
    # Too use and item to pass it creat an item and name it "weathertype" + "ITEM" fx: FOGITEM or BLIZZARDITEM

   :None                                =>   "CLEAR!",
   :Rain                                =>   "The rain is coming down!",
   :Storm                               =>   "A storm is strong to move in for now!",
   :Snow                                =>   "The snow is falling to fast for now!",
   :Sandstorm                           =>   "The sandstorm is too intense, and is to dangerous to walk in!",
   :HeavyRain                           =>   "The heavy rain is relentless, and it hard to see!",
   :Sun                                 =>   "The sun is shining to brightly to see anything",
   :Fog                                 =>   "The fog is too dense to see anything!",
    }

# Custom Weather flute? learning new songs
  WEATHER_P1_CONFIG = {
    #===================[Item & Pocket]===================#
    #===================[   Config    ]===================#
    :internal_name                      => :OCARINA,                # :OCARINA
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
  }

  WEATHER_P2_CONFIG = {
    #===================[Item & Pocket]===================#
    #===================[   Config    ]===================#
    :internal_name                      => :HARP,                   # :HARP
    :item                               => false,                   # Default: false
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
  }

  WEATHER_P3_CONFIG = {
    #===================[Item & Pocket]===================#
    #===================[   Config    ]===================#
    :internal_name                      => :LUTE,                   # :LUTE
    :item                               => false,                   # Default: false
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
  }

  WEATHER_CONFIG = {
    #=================[Sheets Music Control]=================#
    :sheetsbookitem                     => :MUSICNOTEBOOKITEM,      #Storing the Music Tunes
    #===================[Cloudless Config]===================#
    :sheetclearing                      => :MUSICSHEETCLEARING,     #
    :clearing                           => true,                    # Default: true
    :clearing_needed_badge              => 0,                       # Default: 0
    :clearing_needed_switches           => [],
    #===================[Rain Config]==================#
    :sheetrain                          => :MUSICSHEETRAIN,         #
    :rain                               => true,                    # Default: true
    :rain_needed_badge                  => 0,                       # Default: 0
    :rain_needed_switches               => [],
    #===================[Strom Config]===================#
    :sheetstorm                         => :MUSICSHEETSTORM,        #
    :storm                              => true,                    # Default: true
    :storm_needed_badge                 => 0,                       # Default: 0
    :storm_needed_switches              => [],
    #===================[Snow Config]===================#
    :sheetsnow                          => :MUSICSHEETSNOW,         #
    :snow                               => true,                    # Default: true
    :snow_needed_badge                  => 0,                       # Default: 0
    :snow_needed_switches               => [],
    #===================[Blizzard Config]===================#
    :sheetblizzard                      => :MUSICSHEETBLIZZARD,     #
    :blizzard                           => true,                    # Default: true
    :blizzard_needed_badge              => 0,                       # Default: 0
    :blizzard_needed_switches           => [],
    #===================[Sandstrom Config]===================#
    :sheetsandstorm                     => :MUSICSHEETSANDSTORM,    #
    :sandstrom                          => true,                    # Default: true
    :sandstorm_needed_badge             => 0,                       # Default: 0
    :sandstrom_needed_switches          => [],
    #===================[Heavy Rain Config]===================#
    :sheetheavyrain                     => :MUSICSHEETHEAVYRAIN,    #
    :heavyrain                          => true,                    # Default: true
    :heavyrain_needed_badge             => 0,                       # Default: 0
    :heavyrain_needed_switches          => [],
    #===================[Sun Config]===================#
    :sheetsun                           => :MUSICSHEETSUN,          #
    :sun                                => true,                    # Default: true
    :sun_needed_badge                   => 0,                       # Default: 0
    :sun_needed_switches                => [],
    #===================[Fog Config]===================#
    :sheetfog                           => :MUSICSHEETFOG,          #
    :fog                                => true,                    # Default: true
    :fog_needed_badge                   => 0,                       # Default: 0
    :fog_needed_switches                => [],
    #===================[Move Config]===================#
    :move_name                          => [                        # Needs to been in same order
      :WHIRLWIND, :RAINDANCE, :SUNNYDAY, :HAIL],                    #[:WHIRLWIND,:RAINDANCE,:SUNNYDAY,:HAIL]
    :weather_type                       => [                        #  ↑↓         ↑↓         ↑↓        ↑↓
      :None, :Rain, :Sun, :Snow],                                   #[:None,     :Rain,     :Sun,     :Snow]
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
    :text_item_badge                    => "Badge",
    #===[Move Text]===#
    :text_move_badge                    => "Badge",
    #[Missing PP]
    :missing_PP                         => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
    #[Player has Item - Missing Bagde] - {2} = number of badges
    :missing_bagde_item                 => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
    #[Pokémon have Move - Missing Bagde]
    :missing_bagde_move                 => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
# pbSheetAdd(sheet_id) where sheet id is weather id :rain or :snow
# pbSheetRemove(sheet_id)
# Custom
  CAMOUFLAGE_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :CAMOUFLAGEITEM,         # :CAMOUFLAGEITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:CAMOUFLAGE],           # :CAMOUFLAGE
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Other Config]==================#
    :transpernt                         => 20,                      # Default: 20
    :transpernt_min                     => 5,                       # Default: 20
    :autoDetection                      => true,                    # Default: true // See player if they are action key events
    :hiddenFromEvents                   => [                        # Sneaky event wont see you if they have this in there name
      "PC", "Sign",
      "Cuttree", "SmashRock", "BreakIce", "StrengthBoulder", "HeadbuttTree",
      "HiddenItem", "Item", "Ball",
      "Apricorn tree", "BerryPlant"
    ],
    :unhideFromEvents                   => [                        # Event will always see if they have this in there name // Works with touch event also
      "Door"
    ],
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }

#    [Using Camouflage by TechSkylander1518]
#    Events triggered by player touch will still be affected, so there's no need to worry about those becoming broken!
#    If you like to be in control of what events will break the illions of camouflage i suggest running an event with this check:
#    "turnVisible" in a script
#    So it does not look a bit awkward for NPCs to chat with the invisible player

#===============================================================================
# Water Movement
#===============================================================================
# Cannon HM
  SURF_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :SURFITEM,               # :SURFITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:SURF],                 # :SURF
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    :basePKMN?                          => false,                   # Default: false
    #===================[Other Config]==================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The water is a deep blue color...\nWould you like to use \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "The water is a deep blue color...\nWould you like to use \\c[1]{2}\\c[0] on it?", # {2} = Move
        :text_move_comfirm_plus         => "The water is a deep blue color...\nWhich move would you like to use on it?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===# The water is a deep blue color... Would you like to use Surf on it?
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The water is a deep blue color... Maybe something could be use to travel on it?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The water is a deep blue color... but is to dangerous to go alone", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The water is a deep blue color... Maybe the {2} could move smoothly over it", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The water is a deep blue color... Maybe {2} could move smoothly over it", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #==================[Utility Config]=================#
    #TerrainTagNumber
    :number_watercurrent_up              => 20,                # Default: 20
    :number_watercurrent_left            => 21,                # Default: 21
    :number_watercurrent_right           => 22,                # Default: 22
    :number_watercurrent_down            => 23,                # Default: 23
  }

# Cannon HM
  DIVE_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :DIVEITEM,               # :DIVEITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:DIVE],                 # :DIVE
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Other Config]==================#
    :ascend_require_element             => true,                    # Default: true, but this doen not make any sense to me, why would you need a the move to ascend?
    :ascend_require_element_text        => "Light is filtering down from above. Would you like to ascent?",
    :basePKMN?                          => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                =>  "Badge",
        :text_item_comfirm_descend      =>  "Dive use [Item]\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
        :text_item_comfirm_ascend       =>  "Dive use [Item]\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                =>  "Badge",
        :text_move_comfirm_descend      =>  "The sea is deep here. Would you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_ascend       =>  "Light is filtering down from above. Would you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus_descend =>  "Dive - Descend [Move+]\nLight is filtering down from above.\nWhich move would you like to use?",
        :text_move_comfirm_plus_ascend  =>  "Dive - Ascend [Move+]\nLight is filtering down from above.\nWhich move would you like to use?",
        #===[Interact Failed Text]===#
        #[Missing PP]
        :missing_PP                     =>  "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both_descend   =>  "The sea is deep here. A Pokémon or Item may be able to go underwater.", # {2} = item name, {3} = move name (first if mulitple choice)
        :missing_element_both_ascend    =>  "Light is filtering down from above. Would you like to surface here.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable_descend           =>  "The sea is too deep here. What might be down there?", # {2} = item name, {3} = move name (first if mulitple choice)
        :both_disable_ascend            =>  "Light is filtering down from above. Would you like to surface here.",
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item_descend   =>  "The sea is deep here. The {2} may be used to go underwater.", # {2} = item_name
        :missing_element_item_ascend    =>  "Light is filtering down from above. Would you like to surface here.",
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             =>  "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move_descend   =>  "The sea is deep here. A Pokémon may be able to go underwater.", # {2} = move name (first if mulitple choice)
        :missing_element_move_ascend    =>  "Light is filtering down from above. Would you like to surface here.",
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             =>  "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    }

# Cannon HM
  WATERFALL_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :WATERFALLITEM,          # :WATERFALLITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:WATERFALL],            # :WATERFALL
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "It's a large waterfall. Would you like to the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "It's a large waterfall. Would you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "It's a large waterfall. Which move would you like to use Waterfall?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "It's a large waterfall. Maybe something could traverse the cascading water?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "It's a large waterfall. Nothing can traverse the cascading water?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "It's a large waterfall. Maybe the {2} could traverse the cascading water?", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "It's a large waterfall. Maybe {2} could traverse the cascading water?", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }

# Cannon HM
  WHIRLPOOL_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :WHIRLPOOLITEM,          # :WHIRLPOOLITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:WHIRLPOOL],            # :WHIRLPOOL
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The whirlpool's vortex is strong...\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "The whirlpool's vortex is strong...\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "The whirlpool's vortex is strong...\nWhich move would you like to use?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The whirlpool's vortex is strong... Maybe something could swim across it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The whirlpool's vortex is strong... Nothing would be able to cross it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The whirlpool's vortex is strong... Maybe the {2} could swim across it.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The whirlpool's vortex is strong... Maybe {2} could swim across it.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #==================[Utility Config]=================#
    #TerrainTagNumber
    :number_whirlpool                   => 19,                # Default: 20
    #Animation Number
    :MoveIdUp                           => 25,                # Default: 25
    :MoveIdLeft                         => 26,                # Default: 26
    :MoveIdRight                        => 27,                # Default: 27
    :MoveIdDown                         => 28                 # Default: 28
  }
#===============================================================================
# Other Movement
#===============================================================================
# Cannon HM
  FLY_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :FLYITEM,                # :FLYITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:FLY],                  # :FLY
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "Would you like to use the {2}, to travel thought the skies?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "Would you like to use {2}, to travel thought the skies?", # {2} = Move
        :text_move_comfirm_plus         => "Which move would you like to travel thought the skies?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The wind currents are strong...\nMaybe something could ride the breeze.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The wind currents too are strong...\nNothing would ride the breeze.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The wind currents are strong...\nMaybe the {2} could ride the breeze.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The wind currents are strong...\nMaybe {2} could ride the breeze.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }

# Cannon Move
  DIG_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :DIGITEM,                # :DIGITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:DIG],                  # :DIG
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The earth is navigable...\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
        #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "The earth is navigable...\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "The earth is navigable...\nWhich move would you like to use?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }

# Cannon Move
  TELEPORT_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :TELEPORTITEM,           # :TELEPORTITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:TELEPORT],             # :TELEPORT
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Other Config]===================#
    :behav_as_fly                       => false,                   # Default: false; When True works as fly
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The space can be folded...\nWould you like to use the \\c[1]{2}\\c[0] to travel instantly?", # {2} = Item
        #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "The space can be folded...\nWould you like to use \\c[1]{2}\\c[0] to travel instantly?", # {2} = Move
        :text_move_comfirm_plus         => "The space can be folded...\nWhich move would you like to use \\c[1]{2}\\c[0] to travel instantly?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }

# Cannon HM
  ROCKCLIMB_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :ROCKCLIMBITEM,          # :ROCKCLIMBITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:ROCKCLIMB],            # :ROCKCLIMB
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Other Config]==================#
    :basePKMN?                          => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The rock face is steep... Would you like to use the \\c[1]{2}\\c[0] to scale it?", # {2} = Item
        #===[Move Text]===#
        :text_move_badge                => "Badge",                #
        :text_move_comfirm              => "The rock face is steep... Would you like to use \\c[1]{2}\\c[0] to scale it", # {2} = Move
        :text_move_comfirm_plus         => "The rock face is steep... Which move would you like to use the to scale it",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The rock face is steep... Maybe something could scale it with ease.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The rock face is steep... nothing would scale this.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The rock face is steep... Maybe the {2} could scale it with ease.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The rock face is steep... Maybe {2} could scale it with ease.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #===================[Other Config]===================#
    #TerrainTagNumber
        :number_rockclimb               => 18,                      # Default: 18
    #Animation Number
        :DebrisId                       => 20,                      # Default: 20
        :MoveIdUp                       => 21,                      # Default: 21
        :MoveIdLeft                     => 22,                      # Default: 22
        :MoveIdRight                    => 23,                      # Default: 23
        :MoveIdDown                     => 24,                      # Default: 24
  }
#===============================================================================
# Lava Movement
#===============================================================================
# Custom
  LAVASURF_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :LAVASURFITEM,           # :LAVASURFITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:FLAMECHARGE],          # :FLAMECHARGE // Maybe find a better move or make your own
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    :basePKMN?                          => false,                   # Default: false
    #===================[Other Config]==================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The lava is a deep red color...\nWould you like to use \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "The lava is a deep red color...\nWould you like to use \\c[1]{2}\\c[0] on it?", # {2} = Move
        :text_move_comfirm_plus         => "The lava is a deep red color...\nWhich move would you like to use on it?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===# The water is a deep blue color... Would you like to use Surf on it?
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The lava is a deep red color... Maybe something could be use to travel on it?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The lava is a deep red color... but is to dangerous to go alone", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The lava is a deep red color... Maybe the {2} could move smoothly over it", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The lava is a deep red color... Maybe {2} could move smoothly over it", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #==================[Utility Config]=================#
    #TerrainTagNumber
    :number_lavasurf                    => 24,                      # Default: 24
  }

#Custom
  LAVAFALL_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :LAVAFALLITEM,           # :LAVAFALLITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:HEATCRASH],            # :HEATCRASH
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "It's a large lavafall. Would you like to the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "It's a large lavafall. Would you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "It's a large lavafall. Which move would you like to use Waterfall?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "It's a large lavafall. Maybe something could traverse the cascading water?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "It's a large lavafall. Nothing can traverse the cascading water?", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "It's a large lavafall. Maybe the {2} could traverse the cascading water?", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "It's a large lavafall. Maybe {2} could traverse the cascading water?", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #==================[Utility Config]=================#
    #TerrainTagNumber
    :number_lavafall                    => 25,                      # Default: 25
    :number_lavafall_crest              => 26,                      # Default: 26
  }

#Custom
  LAVASWIRL_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :LAVASWIRLITEM,          # :LAVASWIRLITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:FLAMEWHEEL],           # :FLAMEWHEEL
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "The lavaswirl's vortex is strong...\nWould you like to use the \\c[1]{2}\\c[0] on it?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "The lavaswirl's vortex is strong...\nWould you like to use \\c[1]{2}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "The lavaswirl's vortex is strong...\nWhich move would you like to use?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The lavaswirl's vortex is strong... Maybe something could cross it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The lavaswirl's vortex is strong... Nothing would be able to cross it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The lavaswirl's vortex is strong... Maybe the {2} could cross it.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The lavaswirl's vortex is strong... Maybe {2} could cross it.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #==================[Utility Config]=================#
    #TerrainTagNumber
    :number_lavaswirl                   => 27,                      # Default: 27
    #Animation Number
    :MoveIdUp                           => 31,                      # Default: 29
    :MoveIdLeft                         => 32,                      # Default: 30
    :MoveIdRight                        => 33,                      # Default: 31
    :MoveIdDown                         => 34                       # Default: 32
  }
#===============================================================================
# Other Thing - Legend of Zelda
#===============================================================================
# Custom LoZ
  LIFT_CONFIG = {                       # Use in EVENT Name; "Name(Stone) Pickup" also you need to use pbCanLift
    #===================[Item Config]===================#
    :internal_name                      => :LIFTITEM,               # :LIFTITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:ROCKTOMB],             # :ROCKTOMB // :STRENGTH would be better but is already taking
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :cantRunWhileLifting                => "Heavy",                 # If heavy then the player can lift it. // Not useful yet
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
        :text_item_comfirm              => "Would you like to use the \\c[1]{2}\\c[0], to pick up the \\c[1]{3}\\c[0]?", # {2} = Item
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        :text_move_comfirm              => "Would you like to use \\c[1]{2}\\c[0], to pick up the \\c[1]{3}\\c[0]?", # {2} = Move
        :text_move_comfirm_plus         => "Which move would you like use to pick up the \\c[1]{3}\\c[0]?",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Missing Item and Move] if Both are Enable
        :missing_element_both           => "The \\c[1]{4}\\c[0] is heavy... Maybe something could lift it easily.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[IDLE] if Both are Disable
        :both_disable                   => "The \\c[1]{2}\\c[0] is too heavy... Nothing could lift it.", # {2} = item name, {3} = move name (first if mulitple choice)
        #[Missing Item] if Item is Enable and Move is Disable
        :missing_element_item           => "The \\c[1]{3}\\c[0] is heavy... Maybe the \\c[1]{2}\\c[0] could lift it easily.", # {2} = item_name
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Missing Move] if Move is Enable and Item is Disable
        :missing_element_move           => "The \\c[1]{3}\\c[0] is heavy... Maybe \\c[1]{2}\\c[0] could lift it easily.", # {2} = move name (first if mulitple choice)
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
  }
#Custom LoZ
  SENSETRUTH_CONFIG = {
    #===================[Item Config]===================#
    :internal_name                      => :SENSETRUTHITEM,         # :SENSETRUTHITEM
    :item                               => true,                    # Default: true
    :item_needed_badge                  => 0,                       # Default: 0
    :item_needed_switches               => [],                      # Default: []
    :allow_item_debug                   => false,                   # Default: false
    #===================[Move Config]===================#
    :move_name                          => [:DETECT],               # :DETECT
    :move                               => true,                    # Default: true
    :uses_pp                            => false,                   # Default: false
    :move_needed_badge                  => 0,                       # Default: 0
    :move_needed_switches               => [],                      # Default: []
    :allow_move_debug                   => false,                   # Default: false
    #===================[Other Config]==================#
    :senseRange                         => 6,                       # Range from the player (6 sqaures = 30ft. from dnd)
    :senseSteps                         => 100,                     # 100 = a Normal Repel
    :senseCooldown                      => false,                   # Default: false
    :senseCooldownTime                  => 120,                     # Cooldown in sec real time
    :senseHidden                        => ["Hidden"],              # Event Name for Sense Truth
    :senseIllusion                      => ["Illusion"],            # Event Name what illsuion
                                                                    # Opacity can be set to a custom via Illusion,100
    :sensePKMN                          => "PKMN",                  # PKMN can also be set to a custom via PKMN(:Ditto,100) or PKMN(:Kecleon,100)
#   (:Ditto), (:Mew), (:Latios), (:Latias), (:Zorua), (:Zoroark), (:Kecleon)    Pokemon the can disguise themselves
    :senseDisable                       => "Skip",                  # Skips Hide Secret from Sense Truth Effect
    #===================[Text Config]===================#
    #===[Item Text]===#
        :text_item_badge                => "Badge",
    #===[Move Text]===#
        :text_move_badge                => "Badge",
        #[Missing PP]
        :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
    #===[Interact Failed Text]===#
        #[Player has Item - Missing Bagde] - {2} = number of badges
        :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
        #[Pokémon have Move - Missing Bagde]
        :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    #===[Disable the effect]===#
        :disableSenseTruth              => "You are already \\c[1]Revealing the truth\\c[0]. Would you like to end it?"
  }

  # Custom LoZ
    BOMB_CONFIG = {                       # Use in EVENT Name; "Name(Stone) Pickup" also you need to use pbCanLift
      #===================[Item Config]===================#
      :internal_name                      => :BOMBITEM,               # :LIFTITEM
      :item                               => true,                    # Default: true
      :item_needed_badge                  => 0,                       # Default: 0
      :item_needed_switches               => [],                      # Default: []
      :allow_item_debug                   => false,                   # Default: false
      #===================[Move Config]===================#
      :move_name                          => [:EXPLOSION],            # :EXPLOSION // works better with "Followers Pokemon EX"
      :move                               => true,                    # Default: true
      :uses_pp                            => false,                   # Default: false
      :move_needed_badge                  => 0,                       # Default: 0
      :move_needed_switches               => [],                      # Default: []
      :allow_move_debug                   => false,                   # Default: false
      #===================[ultilty Config]================#
      :allow_lifting                      => true,                    # Default: false
      :bomb_timer                         => 7, #Seconds              # Default: 7
      :explosion_radius                   => 1, #Area Effected        # Default: 1
      #===================[Text Config]===================#
      #===[Item Text]===#
          :text_item_badge                => "Badge",
          :text_item_comfirm              => "Would you like to use the \\c[1]{2}\\c[0], to pick up the \\c[1]{3}\\c[0]?", # {2} = Item
      #===[Move Text]===#
          :text_move_badge                => "Badge",
          :text_move_comfirm              => "Would you like to use \\c[1]{2}\\c[0], to pick up the \\c[1]{3}\\c[0]?", # {2} = Move
          :text_move_comfirm_plus         => "Which move would you like use to pick up the \\c[1]{3}\\c[0]?",
          #[Missing PP]
          :missing_PP                     => "Not enough \\c[1]PP\\c[0]...",
      #===[Interact Failed Text]===#
          #[Missing Item and Move] if Both are Enable
          :missing_element_both           => "The \\c[1]{4}\\c[0] is heavy... Maybe something could lift it easily.", # {2} = item name, {3} = move name (first if mulitple choice)
          #[IDLE] if Both are Disable
          :both_disable                   => "The \\c[1]{2}\\c[0] is too heavy... Nothing could lift it.", # {2} = item name, {3} = move name (first if mulitple choice)
          #[Missing Item] if Item is Enable and Move is Disable
          :missing_element_item           => "The \\c[1]{3}\\c[0] is heavy... Maybe the \\c[1]{2}\\c[0] could lift it easily.", # {2} = item_name
          #[Player has Item - Missing Bagde] - {2} = number of badges
          :missing_bagde_item             => "You need at least \\c[1]{2} {3}\\c[0],\nto use the \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = item name
          #[Missing Move] if Move is Enable and Item is Disable
          :missing_element_move           => "The \\c[1]{3}\\c[0] is heavy... Maybe \\c[1]{2}\\c[0] could lift it easily.", # {2} = move name (first if mulitple choice)
          #[Pokémon have Move - Missing Bagde]
          :missing_bagde_move             => "You need at least \\c[1]{2} {3}\\c[0],\nto use \\c[1]{4}\\c[0] in the wild", # {2} = badge count, {3} = badge reference, {4} = move name (first if mulitple choice)
    }
end
