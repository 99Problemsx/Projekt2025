#===============================================================================
# Wild Drop Items - By Vendily [v21]
#===============================================================================
# This script adds in Wild Drop Items, allowing for Wild Pokémon to drop
#  specially defined items in the PBS upon fainting.
# They do not have to be the same as the items Wild Pokémon might generate with.
#===============================================================================
# The script is plug and play, you just need to add in the PBS information
#  `WildDropCommon`, `WildDropUncommon`, and `WildDropRare`, used in the same
#  way as the `WildItem` version. (You don't have to define all three.)
# The base rate is `[50,5,1]`, but if all three properties are the same then it
#  is a 100% rate.
# Check the `def pbFaint` here if you wish to modify the mechanics further
#  or change the windowskin colour to dark mode.
#===============================================================================
PluginManager.register({
  :name    => "Wild Drop Items",
  :version => "1.0",
  :essentials => "21.1",
  :credits => "Vendily"
})
 
 
module GameData
  class Species
    attr_reader :wild_drop_common
    attr_reader :wild_drop_uncommon
    attr_reader :wild_drop_rare
    
    class << self
      alias_method :wild_drop_schema, :schema
      def schema(compiling_forms = false)
        ret = wild_drop_schema(compiling_forms)
        ret["WildDropCommon"]   = [:wild_drop_common,   "*e", :Item]
        ret["WildDropUncommon"] = [:wild_drop_uncommon, "*e", :Item]
        ret["WildDropRare"]     = [:wild_drop_rare,     "*e", :Item]
        return ret
      end
      
      alias_method :wild_drop_editor_properties, :editor_properties
      def editor_properties
        ret = wild_drop_editor_properties
        ret.push(["WildDropCommon",    GameDataPoolProperty.new(:Item),    _INTL("Item(s) commonly dropped by wild Pokémon of this species.")])
        ret.push(["WildDropUncommon",  GameDataPoolProperty.new(:Item),    _INTL("Item(s) uncommonly dropped by wild Pokémon of this species.")])
        ret.push(["WildDropRare",      GameDataPoolProperty.new(:Item),    _INTL("Item(s) rarely dropped by wild Pokémon of this species.")])
        return ret
      end
    end
    alias wild_drop_initialize initialize
    def initialize(hash)
      wild_drop_initialize(hash)
      @wild_drop_common   = hash[:wild_drop_common]   || []
      @wild_drop_uncommon = hash[:wild_drop_uncommon] || []
      @wild_drop_rare     = hash[:wild_drop_rare]     || []
    end
  end
end
 
class Pokemon
  # @return [Array<Array<Symbol>>] the items this species can drop in the wild
  def wildDropItems
    sp_data = species_data
    return [sp_data.wild_drop_common, sp_data.wild_drop_uncommon, sp_data.wild_drop_rare]
  end
end
 
class Battle::Battler
  alias wild_drop_pbFaint pbFaint
  def pbFaint(showMessage = true)
    old_fainted = @fainted
    wild_drop_pbFaint(showMessage)
    # we don't drop items if no message will show
    return unless showMessage
    # must be a wild battle, and this is a wild mon
    return unless @battle.wildBattle? && opposes?
    # must be fainted, and it can't already have been fainted
    return unless @fainted && old_fainted != @fainted
    # we need a pokemon, and this can't be a non-standard battle
    return unless @pokemon && @battle.internalBattle
    items = @pokemon.wildDropItems
    chances = [50, 5, 1]
    itemrnd = rand(100)
    item = nil
    qty = 1
    if (items[0] == items[1] && items[1] == items[2]) || itemrnd < chances[0]
      item = items[0].sample
    elsif itemrnd < (chances[0] + chances[1])
      item = items[1].sample
    elsif itemrnd < (chances[0] + chances[1] + chances[2])
      item = items[2].sample
    end
    return unless item
    # if we have an item and sucessfully added it
    old_quantity_items = $bag.quantity(item)
    $bag.add(item,qty)
    added_items = $bag.quantity(item) - old_quantity_items
    if added_items>0
      item_data = GameData::Item.get(item)
      itemname = (added_items > 1) ? item_data.portion_name_plural : item_data.portion_name
      pocket = item_data.pocket
      # change the false to true if your battle window skin is dark
      colour_tag = getSkinColor(nil, 1, false)
      @battle.pbDisplay(_INTL("{1} dropped {2}{3} x{4}</c3>!",pbThis,colour_tag,itemname,added_items))
      @battle.pbDisplay(_INTL("You put the {1} in\nyour Bag's <icon=bagPocket{2}>{3}{4}</c3> pocket.",
                    itemname, pocket, colour_tag, PokemonBag.pocket_names[pocket - 1]))
    end
  end
end