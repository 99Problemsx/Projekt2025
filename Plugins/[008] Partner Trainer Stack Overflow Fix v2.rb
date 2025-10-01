#===============================================================================
# [008] Partner Trainer Stack Overflow Fix v2.rb
#===============================================================================

#-------------------------------------------------------------------------------
# Prevents SystemStackError when partner trainer Pokemon faint in raid battles
# by intercepting the raid capture process that triggers the validation loops.
#-------------------------------------------------------------------------------

# Fix the root cause: makeUnmega calls during raid capture trigger validation
class Pokemon
  alias stack_overflow_fix_makeUnmega makeUnmega
  def makeUnmega
    # Prevent validation loops during capture processing
    Thread.current[:in_makeUnmega] ||= false
    
    if Thread.current[:in_makeUnmega]
      # Already processing, just set form directly
      @form = 0 if @form && @form > 0
      @form_simple = 0 if @form_simple && @form_simple > 0
      calc_stats
      return
    end
    
    Thread.current[:in_makeUnmega] = true
    begin
      stack_overflow_fix_makeUnmega
    ensure
      Thread.current[:in_makeUnmega] = false
    end
  end
end

# Prevent recursion in mega? checks as backup protection
class Pokemon
  alias stack_overflow_fix_mega? mega?
  def mega?
    Thread.current[:checking_mega] ||= []
    
    # Check if this exact Pokemon object is already being checked
    if Thread.current[:checking_mega].include?(self.object_id)
      return false
    end
    
    Thread.current[:checking_mega].push(self.object_id)
    begin
      result = stack_overflow_fix_mega?
    ensure
      Thread.current[:checking_mega].pop
    end
    
    return result
  end
end

# Prevent recursion in battler mega? checks
class Battle::Battler
  alias stack_overflow_fix_mega? mega?
  def mega?
    Thread.current[:checking_battler_mega] ||= []
    
    # Check if this exact battler object is already being checked
    if Thread.current[:checking_battler_mega].include?(self.object_id)
      return false
    end
    
    Thread.current[:checking_battler_mega].push(self.object_id)
    begin
      result = stack_overflow_fix_mega?
    ensure
      Thread.current[:checking_battler_mega].pop
    end
    
    return result
  end
end

# Extra protection for the species validation that's part of the chain
module GameData
  class Species
    class << self
      alias stack_overflow_fix_get get
      def get(species)
        Thread.current[:getting_species] ||= []
        
        # Convert species to string for comparison
        species_key = species.to_s
        
        # Check if we're already getting this species
        if Thread.current[:getting_species].include?(species_key)
          # Return a safe fallback
          return nil
        end
        
        Thread.current[:getting_species].push(species_key)
        begin
          result = stack_overflow_fix_get(species)
        ensure
          Thread.current[:getting_species].pop
        end
        
        return result
      end
    end
  end
end
