Battle::AbilityEffects::AfterMoveUseFromTarget.add(:COLORCHANGE,
  proc { |ability, target, user, move, switched_battlers, battle|
    next if target.damageState.calcDamage == 0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    if target.isSpecies?(:KECLEON)
      case typeName
      when "Grass","Bug","Normal"
        form = 0
      when "Fire","Fighting"
        form = 1
      when "Water","Dragon"
        form = 2
      when "Electric",
        form = 3
      when "Ice","Flying"
        form = 4
      when "Fairy","Psychic"
        form = 5
      when "Poison","Ghost"
        form = 6
      when "Ground","Rock"
        form = 7
      when "Dark"
        form = 8
      else
        form = 9
      end
      if form != target.form
        target.pbChangeForm(form, "")
        battle.pbDisplay(_INTL("{1}'s color changed to {2}!",
           target.pbThis, target.pokemon.species_data.color))
      end
    end
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s type changed to {2} because of its {3}!",
       target.pbThis, typeName, target.abilityName))
    battle.pbHideAbilitySplash(target)
  }
)
