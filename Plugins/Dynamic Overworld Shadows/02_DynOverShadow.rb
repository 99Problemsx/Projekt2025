#===============================================================================
# Dynamic Overworld Shadows 
#
# Creado por: /  Created by: Zik
# Creditos: / Credits: Golisopod User, Wolf PP, Marin 
#
# Descripción:
# Sistema de sombras automaticas(y dinámicas) para los Overworlds.
# Basado en el script Overworld Shadows EX.
#
# Description:
# An automatic (and dynamic) shadow system for Overworlds.
# Based on the Overworld Shadows EX script.
# 
# A D V E R T E N C I A : El rendimiento decae si se usan las conexiones de Mapa.
# W A R N I N G : Performance may drop when using Map Connections.
#===============================================================================

#===============================================================================
# INTEGRACIÓN CON EL MENÚ DE OPCIONES
# INTEGRATION WITH THE OPTIONS MENU
#===============================================================================

class PokemonSystem
  attr_accessor :shadow_type
  
  alias __shadows__initialize initialize unless private_method_defined?(:__shadows__initialize)
  def initialize
    __shadows__initialize
    @shadow_type = 3
  end
end

MenuHandlers.add(:options_menu, :overworld_shadows, {
  "name"        => _INTL("Overworld Shadows"),
  "order"       => 125,
  "type"        => EnumOption,
  "parameters"  => [_INTL("X"), _INTL("EX"), _INTL("EX++"), _INTL("MAX")],
  "description" => _INTL("Escoge qué tipo de sombra quieres que se aplique en el juego."),
  "get_proc"    => proc { next $PokemonSystem.shadow_type || 3 },
  "set_proc"    => proc { |value, scene|
    old_value = $PokemonSystem.shadow_type || 3
    $PokemonSystem.shadow_type = value

    if (old_value == 0 && value > 0) || (old_value > 0 && value == 0)
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = $game_map.map_id
      $game_temp.player_new_x = $game_player.x
      $game_temp.player_new_y = $game_player.y
      $game_temp.player_new_direction = $game_player.direction
      $scene.transfer_player if $scene.is_a?(Scene_Map)
    end

    descriptions = [
      _INTL("No se aplicará ningún tipo de sombra."),
      _INTL("Se aplicará una sombra sencilla."),
      _INTL("Mejoras estéticas para hacer más dinámica la sombra sencilla."),
      _INTL("Se aplicará una sombra dinámica que calza con la forma del Overworld.")
    ]
    scene.sprites["textbox"].text = descriptions[value]
  },

  "on_select"   => proc { |scene|
    value = $PokemonSystem.shadow_type || 3
    descriptions = [
      _INTL("No se aplicará ningún tipo de sombra."),
      _INTL("Se aplicará una sombra sencilla."),
      _INTL("Mejoras estéticas para hacer más dinámica la sombra sencilla."),
      _INTL("Se aplicará una sombra dinámica que calza con la forma del Overworld.")
    ]
    scene.sprites["textbox"].text = descriptions[value]
  }
})

#===============================================================================
# MOTOR PRINCIPAL DE LAS SOMBRAS
# MAIN SHADOW ENGINE
#===============================================================================
module OWShadowSettings
  # --- CONFIGURACIÓN / CONFIGURATION ---
  
  # Si es 'true', las listas negras distinguirán entre mayúsculas y minúsculas (ej: "puerta" no es lo mismo que "Puerta").
  # If 'true', blacklists will be case-sensitive (e.g., "door" is not the same as "Door").
  CASE_SENSITIVE_BLACKLISTS = true
  
  # Los eventos cuyo nombre contenga cualquiera de estos textos NO tendrán sombra.
  # Events whose name contains any of these strings will NOT have a shadow.
  SHADOWLESS_EVENT_NAME     = [
    "door", "FlechaSalida", "nurse", "Enfermera", "Healing balls", "Balls curativas", "Mart","Tendero", "SmashRock", "RocaRompible", "StrengthBoulder", "PiedraFuerza",
    "CutTree", "ArbolCorte", "HeadbuttTree", "ArbolGolpeCabeza", "BerryPlant", "Planta Bayas", ".shadowless", ".noshadow", ".sl", "Entrada Mazmorra Bosque", "Entrada Cueva", "Relic Stone",
    "Escalera", "Puerta"
  ]
  
  # Los personajes cuyo nombre de archivo de gráfico contenga estos textos NO tendrán sombra.
  # Characters whose graphic filename contains these strings will NOT have a shadow.
  SHADOWLESS_CHARACTER_NAME = ["nil"]
  
  # Los personajes que estén sobre un tile con una de estas etiquetas de terreno NO tendrán sombra.
  # Characters standing on a tile with one of these terrain tags will NOT have a shadow.
  SHADOWLESS_TERRAIN_NAME   = [
    :Grass, :DeepWater, :StillWater, :Water, :Waterfall, :WaterfallCrest,
    :Puddle
  ]
  
  # Nombre del archivo de sombra por defecto para los modos "EX" y "EX++". Se busca en "Graphics/Characters/Shadows/".
  # Default shadow filename for "EX" and "EX++" modes. Looked for in "Graphics/Characters/Shadows/".
  DEFAULT_SHADOW_FILENAME   = "defaultShadow"
  
  # Nombre del archivo de sombra específico para el jugador en los modos "EX" y "EX++".
  # Specific shadow filename for the player in "EX" and "EX++" modes.
  PLAYER_SHADOW_FILENAME    = "defaultShadow"
  
  # Prioridades de tile que ocultan la sombra (ej: puentes, copas de árboles). Si el personaje está en un tile con esta prioridad, la sombra desaparece.
  # Tile priorities that hide the shadow (e.g., bridges, treetops). If the character is on a tile with this priority, the shadow disappears.
  OCCLUSION_PRIORITIES = [1, 2, 3, 4, 5]

  # Velocidad de la animación de "respiración" de la sombra en modo EX++. Un valor más alto la hace más rápida.
  # Speed of the "breathing" animation for the shadow in EX++ mode. A higher value makes it faster.
  EXPP_ANIM_SPEED = 0.1
  
  # Intensidad (cuánto se encoge/expande) de la animación. 0.05 = 5% de cambio sobre el tamaño original.
  # Intensity (how much it shrinks/expands) of the animation. 0.05 = 5% change from the original size.
  EXPP_ANIM_INTENSITY = 0.06
end

class Sprite_OWShadow
  @@shadow_bitmap_cache = {}

  def self.clear_cache
    @@shadow_bitmap_cache.each_value { |bitmap| bitmap.dispose if bitmap && !bitmap.disposed? }
    @@shadow_bitmap_cache.clear
  end

  attr_reader :visible

  SHADOW_COLOR = Color.new(0, 0, 0, 100) # Color y opacidad de la sombra dinámica. / Color and opacity of the dynamic shadow.
  SHADOW_SQUASH_FACTOR = 0.5 # Factor de "aplastamiento" vertical para la sombra dinámica. / Vertical "squash" factor for the dynamic shadow.
  JUMP_SCALE_SMOOTHING_FACTOR = 0.15 # Suavizado de la animación de escala al saltar. / Smoothing for the scaling animation when jumping.
  JUMP_DISAPPEAR_HEIGHT = 3 * 32 # Altura en píxeles a la que la sombra desaparece por completo al saltar. /  Height in pixels at which the shadow completely disappears when jumping.
  DEFAULT_SHADOW_VERTICAL_OFFSET = 24 # Desplazamiento vertical por defecto para la sombra dinámica (modo MAX). / Default vertical offset for the dynamic shadow (MAX mode).

  def initialize(sprite, event, viewport = nil)
    @rsprite = sprite  
    @event = event     
    @viewport = viewport
    @sprite = Sprite.new(viewport) 
    @disposed = false
    @current_scale = 1.0
    @vertical_offset = DEFAULT_SHADOW_VERTICAL_OFFSET
    @animation_counter = 0
    @idle_frames = 0
    
    # Permite un desplazamiento vertical personalizado para la sombra dinámica usando "(SVO: Y)" en el nombre del evento.
    # Allows a custom vertical offset for the dynamic shadow using "(SVO: Y)" in the event's name.
    if @event.is_a?(Game_Event) && @event.name
      match_data = @event.name.match(/\(SVO:\s*(\d+)\)/i)
      @vertical_offset = match_data[1].to_i if match_data
    end
    
    name = ""
    if !defined?(Game_FollowingPkmn) || !@event.is_a?(Game_FollowingPkmn)
      if @event != $game_player && @event.name
        name = $~[1] if @event.name[/shdw\((.*?)\)/]
      else
        name = OWShadowSettings::PLAYER_SHADOW_FILENAME
      end
    end
    name = OWShadowSettings::DEFAULT_SHADOW_FILENAME if nil_or_empty?(name)
    @ow_shadow_bitmap = AnimatedBitmap.new("Graphics/Characters/Shadows/" + name)
    RPG::Cache.retain("Graphics/Characters/Shadows/" + name)
  end

  def update
    return if disposed?
    case ($PokemonSystem.shadow_type || 3)
    when 1; update_classic      
    when 2; update_classic_ex   
    when 3; update_dynamic      
    else; @sprite.visible = false 
    end
  end

  # Lógica para la sombra "EX": una imagen estática que sigue al personaje.
  # Logic for the "EX" shadow: a static image that follows the character.
  def update_classic
    @sprite.visible = @rsprite.visible && @event.shows_shadow?
    return if !@sprite.visible
    @ow_shadow_bitmap.update
    @sprite.bitmap  = @ow_shadow_bitmap.bitmap
    if @event.jumping?
      if @event.jump_count && @event.jump_peak
        if @event.jump_count > @event.jump_peak / 2; @sprite.zoom_x -= 0.05; @sprite.zoom_y -= 0.05
        else; @sprite.zoom_x += 0.05; @sprite.zoom_y += 0.05; end
        @sprite.zoom_x = @sprite.zoom_x.clamp(0, 1); @sprite.zoom_y = @sprite.zoom_y.clamp(0, 1)
      end
      @sprite.x = @event.screen_x; @sprite.y = @event.screen_y
    else
      @sprite.x = @rsprite.x; @sprite.y = @rsprite.y
      @sprite.zoom_x = @rsprite.zoom_x; @sprite.zoom_y = @rsprite.zoom_y
    end
    @sprite.ox = @ow_shadow_bitmap.width / 2
    @sprite.oy = @ow_shadow_bitmap.height - 2
    @sprite.z = @rsprite.z - 1
    @sprite.opacity = @rsprite.opacity * calculate_occlusion_opacity
  end

 # Lógica para la sombra "EX++": igual que la EX, pero con escalado suavizado al saltar y animación al moverse.
 # Logic for the "EX++" shadow: same as EX, with smooth scaling on jump and animation on move.
def update_classic_ex

  jump_scale = @event.jumping? ? calculate_jump_scale : 1.0

  has_moved = (@event.x != @last_x || @event.y != @last_y)
  is_in_motion = @event.moving? || has_moved
  
  movement_anim_scale = 1.0
  
  if is_in_motion && !@event.jumping?
    @idle_frames = 0
    @animation_counter += OWShadowSettings::EXPP_ANIM_SPEED
    sine_wave = Math.sin(@animation_counter)
    movement_anim_scale = 1.0 - (sine_wave * OWShadowSettings::EXPP_ANIM_INTENSITY)
  else
    @idle_frames += 1
    
    if @idle_frames < 5
      @animation_counter += OWShadowSettings::EXPP_ANIM_SPEED
      sine_wave = Math.sin(@animation_counter)
      movement_anim_scale = 1.0 - (sine_wave * OWShadowSettings::EXPP_ANIM_INTENSITY)
    else
      @animation_counter = 0
      movement_anim_scale = 1.0
    end
  end
  
  @last_x = @event.x
  @last_y = @event.y
  
  target_scale = jump_scale * movement_anim_scale
  
  @current_scale += (target_scale - @current_scale) * JUMP_SCALE_SMOOTHING_FACTOR
  
  @sprite.visible = @rsprite.visible && @event.shows_shadow? && @current_scale > 0.01
  return if !@sprite.visible
  
  @ow_shadow_bitmap.update
  @sprite.bitmap = @ow_shadow_bitmap.bitmap
  @sprite.ox = @ow_shadow_bitmap.width / 2
  @sprite.oy = @ow_shadow_bitmap.height - 2
  @sprite.z = @rsprite.z - 1
  @sprite.opacity = @rsprite.opacity * calculate_occlusion_opacity
  
  if @event.jumping?
    @sprite.x = @event.screen_x
    @sprite.y = @event.screen_y_ground
  else
    @sprite.x = @rsprite.x
    @sprite.y = @rsprite.y
  end
  
  @sprite.zoom_x = @rsprite.zoom_x * @current_scale
  @sprite.zoom_y = @rsprite.zoom_y * @current_scale
end

  # Lógica para la sombra "MAX": genera una sombra basada en la silueta del sprite del personaje.
  # Logic for the "MAX" shadow: generates a shadow based on the character sprite's silhouette.
  def update_dynamic
    char_name = @event.character_name
    @sprite.visible = @rsprite.visible && @event.shows_shadow?
    return if !@sprite.visible || nil_or_empty?(char_name)
    
    unless @@shadow_bitmap_cache.key?(char_name)
      @@shadow_bitmap_cache[char_name] = generate_shadow_bitmap
    end
    @sprite.bitmap = @@shadow_bitmap_cache[char_name]
    return if !@sprite.bitmap || @sprite.bitmap.disposed?
    
    target_scale = @event.jumping? ? calculate_jump_scale : 1.0
    @current_scale += (target_scale - @current_scale) * JUMP_SCALE_SMOOTHING_FACTOR
    @sprite.visible = @sprite.visible && @current_scale > 0.01
    return if !@sprite.visible
    
    @sprite.src_rect.set(@rsprite.src_rect) 
    @sprite.z = @rsprite.z - 1
    @sprite.oy = 0
    @sprite.ox = @rsprite.ox
    @sprite.opacity = @rsprite.opacity * calculate_occlusion_opacity
    
    if @event.jumping?
      @sprite.x = @event.screen_x
      @sprite.y = @event.screen_y_ground + @vertical_offset
    else
      @sprite.x = @rsprite.x
      @sprite.y = @rsprite.y + @vertical_offset
    end
    
    @sprite.zoom_x = @rsprite.zoom_x * @current_scale
    @sprite.zoom_y = @rsprite.zoom_y * -SHADOW_SQUASH_FACTOR * @current_scale
  end

  private

  def calculate_occlusion_opacity
    return 1.0 if @event.in_air?
    priority = $game_map.priority(@event.x, @event.y)
    return OWShadowSettings::OCCLUSION_PRIORITIES.include?(priority) ? 0.0 : 1.0
  end

  def calculate_jump_scale
    current_pixel_height = @event.screen_y_ground - @rsprite.y
    disappear_ratio = (JUMP_DISAPPEAR_HEIGHT > 0) ? (current_pixel_height / JUMP_DISAPPEAR_HEIGHT.to_f) : 0
    disappear_ratio = disappear_ratio.clamp(0.0, 1.0)
    return 1.0 - disappear_ratio
  end

  def generate_shadow_bitmap
    return nil if !@rsprite || !@rsprite.bitmap || @rsprite.bitmap.disposed?
    shadow_bm = Bitmap.new(@rsprite.bitmap.width, @rsprite.bitmap.height)
    for y in 0...shadow_bm.height
      for x in 0...shadow_bm.width
        shadow_bm.set_pixel(x, y, SHADOW_COLOR) if @rsprite.bitmap.get_pixel(x, y).alpha > 0
      end
    end
    return shadow_bm
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @ow_shadow_bitmap.dispose if @ow_shadow_bitmap
    @sprite, @ow_shadow_bitmap = nil, nil
    @disposed = true
  end

  def disposed?; @disposed; end
end

#===============================================================================

class Scene_Map
  alias __shadow_cache__create_spritesets createSpritesets
  def createSpritesets
    Sprite_OWShadow.clear_cache
    __shadow_cache__create_spritesets
  end
end

class Sprite_Character
  attr_accessor :ow_shadow
  
  alias __ow_shadow__initialize initialize unless private_method_defined?(:__ow_shadow__initialize)
  def initialize(*args)
    __ow_shadow__initialize(*args)
    shadow_type = $PokemonSystem ? ($PokemonSystem.shadow_type || 3) : 3
    if shadow_type > 0 && @character
      @ow_shadow = Sprite_OWShadow.new(self, @character, self.viewport)
    end
  end
  
  alias __ow_shadow__dispose dispose unless method_defined?(:__ow_shadow__dispose)
  def dispose(*args); @ow_shadow.dispose if @ow_shadow; __ow_shadow__dispose(*args); end
  
  alias __ow_shadow__update update unless method_defined?(:__ow_shadow__update)
  def update(*args)
    __ow_shadow__update(*args)
    @ow_shadow.update if @ow_shadow
  end
end

class Game_Map
  def priority(x, y)
    return 0 if !@map || !@tileset || !valid?(x, y)
    (@map.data.zsize - 1).downto(0) do |i|
      tile_id = @map.data[x, y, i]
      next if tile_id.nil? || tile_id == 0
      return @tileset.priorities[tile_id]
    end
    return 0
  end
end

class Game_Character
  attr_reader :jump_peak, :jump_count
  
  def in_air?
    return self.jumping?
  end
  
  def shows_shadow?(recalc = false)
    shadow_type = $PokemonSystem ? ($PokemonSystem.shadow_type || 3) : 3
    return @shows_shadow = false if shadow_type == 0 || nil_or_empty?(self.character_name)
    return @shows_shadow if !recalc && !@shows_shadow.nil?
    return @shows_shadow = false if self.transparent || @tile_id > 0
    
    if OWShadowSettings::CASE_SENSITIVE_BLACKLISTS
      return @shows_shadow = false if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any? { |e| self.character_name.include?(e) }
      return @shows_shadow = false if self.respond_to?(:name) && OWShadowSettings::SHADOWLESS_EVENT_NAME.any? { |e| self.name.include?(e) }
    else
      return @shows_shadow = false if OWShadowSettings::SHADOWLESS_CHARACTER_NAME.any? { |e| self.character_name.downcase.include?(e.downcase) }
      return @shows_shadow = false if self.respond_to?(:name) && OWShadowSettings::SHADOWLESS_EVENT_NAME.any? { |e| self.name.downcase.include?(e.downcase) }
    end
    
    terrain = $game_map.terrain_tag(self.x, self.y)
    return @shows_shadow = false if terrain && OWShadowSettings::SHADOWLESS_TERRAIN_NAME.include?(terrain.id)
    
    return @shows_shadow = true
  end
  
  alias __ow_shadow__transparent_set transparent= unless method_defined?(:__ow_shadow__transparent_set)
  def transparent=(value); __ow_shadow__transparent_set(value); shows_shadow?(true); end
end

class Game_Event

  alias __ow_shadow__refresh refresh unless method_defined?(:__ow_shadow__refresh)
  def refresh(*args); __ow_shadow__refresh(*args); shows_shadow?(true); end
end

class Game_Player
  alias __ow_shadow__set_movement_type set_movement_type unless method_defined?(:__ow_shadow__set_movement_type)
  def set_movement_type(*args); ret = __ow_shadow__set_movement_type(*args); shows_shadow?(true); return ret; end
end

