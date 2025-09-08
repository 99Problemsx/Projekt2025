=begin
def owuse items
 Pick Axe
 Axe / Sword
 Ice Pick
 Gloves
 Strength
end

 Essence
 Lantern
 Flute (Ocraina)
 Cloak
 Flippers
 Scuba Gear
 Nimbus
 Shovel
 Disk of returning
 Heat Shoes
end

def fly animation

end

def teleport animation

end

def dig animation

end
=end
#===============================================================================
# RockSmash
#===============================================================================
class Sprite_RockSmashAnimation
  attr_reader :visible

  def initialize(parent_sprite, viewport = nil)
    @parent_sprite = parent_sprite
    @sprite = nil
    @viewport = viewport
    @disposed = false
    @rocksmash_animation_bitmap = Bitmap.new("Graphics/Animations/AIFM/RockSmash")
    @cws = 88 # Widgt per animation frame
    @chs = 76 # Height per animation frame
    @frame_index = 0
    @frame_counter = 0
    update
  end

  def dispose
    return if @disposed
    @sprite&.dispose
    @sprite = nil
    @parent_sprite = nil
    @rocksmash_animation_bitmap&.dispose
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def event
    return @parent_sprite.character
  end

  def update
    return if disposed?
    if !$rocksmash_animation
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
        @frame_index = 0 # Reset frame index
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    return if !@sprite
    @sprite.bitmap = @rocksmash_animation_bitmap
    @frame_counter += 1
    puts "#{@frame_counter}"
    if @frame_counter >= 6  # default 6
      @frame_counter = 0
      @frame_index += 1
      if @frame_index >= 6 # Make sure you have at least 6 frames
        $rocksmash_animation = false
      end
    end
    sx = @frame_index * @cws
    sy = ((@parent_sprite.character.direction - 2) / 2) * @chs
    @sprite.src_rect.set(sx, sy, @cws, @chs)
    offsets = {
      2 => [0, -8, 1],
      4 => [0, -14, 1],
      6 => [0, -14, 1],
      8 => [0, -26, -1]
    }

    dir = @parent_sprite.character.direction
    offset = offsets[dir]
    @sprite.x = @parent_sprite.x + offset[0]
    @sprite.y = @parent_sprite.y + offset[1]
    @sprite.ox = @cws / 2
    @sprite.oy = @chs / 2
    @sprite.z = @parent_sprite.z + offset[2]
  end
end

class Sprite_Character < RPG::Sprite
  alias rocksmash_animation_initialize initialize
  def initialize(viewport, character = nil)
    rocksmash_animation_initialize(viewport, character)
    @rocksmash_animation = Sprite_RockSmashAnimation.new(self, viewport) if character == $game_player
  end

  alias rocksmash_animation_dispose dispose
  def dispose
    rocksmash_animation_dispose
    @rocksmash_animation&.dispose
    @rocksmash_animation = nil
  end

  alias rocksmash_animation_update update
  def update
    rocksmash_animation_update
    @rocksmash_animation&.update
  end
end

def pbRockSmashAnimation
  $rocksmash_animation = true
end
#===============================================================================
# Cut
#===============================================================================
class Sprite_CutAnimation
  attr_reader :visible

  def initialize(parent_sprite, viewport = nil)
    @parent_sprite = parent_sprite
    @sprite = nil
    @viewport = viewport
    @disposed = false
    @cut_animation_bitmap = Bitmap.new("Graphics/Animations/AIFM/Cut")
    @cws = 88 # Widgt per animation frame
    @chs = 76 # Height per animation frame
    @frame_index = 0
    @frame_counter = 0
    update
  end

  def dispose
    return if @disposed
    @sprite&.dispose
    @sprite = nil
    @parent_sprite = nil
    @cut_animation_bitmap&.dispose
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def event
    return @parent_sprite.character
  end

  def update
    return if disposed?
    if !$cut_animation
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
        @frame_index = 0 # Reset frame index
      end
      return
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    return if !@sprite
    @sprite.bitmap = @cut_animation_bitmap
    @frame_counter += 1
    if @frame_counter >= 6 # default 6
      @frame_counter = 0
      @frame_index += 1
      if @frame_index >= 6 # Make sure you have at least 6 frames
        $cut_animation = false
      end
    end
    sx = @frame_index * @cws
    sy = ((@parent_sprite.character.direction - 2) / 2) * @chs
    @sprite.src_rect.set(sx, sy, @cws, @chs)
    offsets = {
      2 => [0, -12, 1],
      4 => [0, -14, 1],
      6 => [0, -14, 1],
      8 => [0, -22, -1]
    }

    dir = @parent_sprite.character.direction
    offset = offsets[dir]
    @sprite.x = @parent_sprite.x + offset[0]
    @sprite.y = @parent_sprite.y + offset[1]
    @sprite.ox = @cws / 2
    @sprite.oy = @chs / 2
    @sprite.z = @parent_sprite.z + offset[2]
  end
end

class Sprite_Character < RPG::Sprite
  alias cut_animation_initialize initialize
  def initialize(viewport, character = nil)
    cut_animation_initialize(viewport, character)
    @cut_animation = Sprite_CutAnimation.new(self, viewport) if character == $game_player
  end

  alias cut_animation_dispose dispose
  def dispose
    cut_animation_dispose
    @cut_animation&.dispose
    @cut_animation = nil
  end

  alias cut_animation_update update
  def update
    cut_animation_update
    @cut_animation&.update
  end
end

def pbCutAnimation
  $cut_animation = true
end
