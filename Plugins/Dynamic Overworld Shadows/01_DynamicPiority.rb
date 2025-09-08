#==============================================================================
# Dynamic Priority Tiles v1.0
#------------------------------------------------------------------------------
# Autor: Zik
#
# Descripción:
# Este script permite crear zonas en el mapa que cambian dinámicamente su
# apariencia cuando el jugador o un evento se acerca. Se configura a través
# de eventos con un nombre específico.
#
# Description:
# This script allows creating zones on the map that dynamically change their
# appearance when the player or an event gets close. It is configured through
# events with a specific name.
#
#==============================================================================

#==============================================================================
# ▼▼▼ INSTRUCCIONES DE USO / HOW TO USE ▼▼▼
#==============================================================================
#
# --- 1. Configuración en la Base de Datos / Database Setup ---
#
#   1. Ve a la pestaña "Tilesets" en la Base de Datos (F9).
#      Go to the Database (F9) and select the "Tilesets" tab.
#
#   2. Selecciona el tileset que usarás en tu mapa.
#      Select the tileset you will be using on your map.
#
#   3. IMPORTANTE: El script copiará los tiles a un área de tu tileset que
#      debe estar vacía. Por defecto, empieza en el ID 3280 (configurable abajo).
#      IMPORTANT: The script will copy tiles to an area of your tileset that
#      must be empty. By default, it starts at ID 3280 (configurable below).
#
#   4. Las propiedades de los tiles copiados (pasabilidad, prioridad, tag de
#      terreno) NO se heredan. Se usarán las propiedades que tú definas
#      para esa área de destino (ID 3280 en adelante) en la base de datos.
#      The properties of the copied tiles (passability, priority, terrain tag)
#      are NOT inherited. The script will use the properties you define for
#      that destination area (ID 3280 onwards) in the database.
#
#   5. La carpeta del plugin incluye una imagen de referencia (256x16384px) con 
#      todos los IDs de tile enumerados para ayudarte a visualizar y elegir el
#      "TILE_COPY_START_ID" correcto.
#      The plugin folder includes a reference image (256x16384px) with all
#      tile IDs numbered to help you visualize and choose the correct
#      "TILE_COPY_START_ID".
#
# --- 3. Uso en el Mapa / In-Map Usage ---
#
#   1. Ve al mapa donde quieres crear una zona dinámica.
#      Go to the map where you want to create a dynamic zone.
#   2. Crea un nuevo evento. La posición de este evento será el **extremo derecho**
#      de la zona de tiles que quieres que cambie.
#      Create a new event. This event's position will be the **rightmost edge**
#      of the tile zone you want to change.
#
#   3. Nombra al evento: "Priority Activated(x)", reemplazando "x" por el ancho
#      en tiles que desees para la zona.
#      Name the event: "Priority Activated(x)", replacing "x" with the desired
#      width in tiles for the zone.
#      - Ejemplo / Example: Un evento en (21, 31) llamado "Priority Activated(14)"
#        creará una zona de 14 tiles de ancho, desde x=8 hasta x=21 en la fila y=31.
#        An event at (21, 31) named "Priority Activated(14)" will create a zone
#        14 tiles wide, from x=8 to x=21 on row y=31.
#
#==============================================================================


module DynamicPriorityTiles
  #============================================================================
  # ▼ INICIO DE LA CONFIGURACIÓN / START OF CONFIGURATION
  #============================================================================
  
  # El ID del primer tile en el tileset donde se guardarán las copias.
  # Asegúrate de que esta área y las siguientes estén libres en tu tileset.
  # The ID of the first tile in the tileset where the copies will be stored.
  # Make sure this area and the following ones are free in your tileset.
  TILE_COPY_START_ID = 3280

  # El nombre que deben tener los eventos para ser reconocidos por el script.
  # The name that events must have to be recognized by the script.
  EVENT_NAME_REGEX = /Priority Activated\((\d+)\)/i

  # Desplazamiento vertical para el área de activación. -1 significa que la
  # primera fila de activación estará justo encima de la zona de tiles.
  # Vertical offset for the activation area. -1 means the first activation
  # row will be right above the tile zone.
  TRIGGER_Y_OFFSET = -1
  
  #============================================================================
  # ▼▼▼▼▼▼▼ NO TOCAR / DO NOT TOUCH ▼▼▼▼▼▼
  #============================================================================
  
  TILE_OFFSET = 384
  TILESET_COLS = 8

  #============================================================================
  # ▲▲▲▲▲▲ NO TOCAR / NO DOT TOUCH ▲▲▲▲▲▲
  #============================================================================

  class PriorityZone
    attr_reader :id, :trigger_rect, :is_active, :zone_rect
    
    def initialize(event, width)
      @id = event.id
      @event_x = event.x
      @event_y = event.y
      @width = width
      @is_active = false
      
      @zone_rect = Rect.new(@event_x - @width + 1, @event_y, @width, 1)
      trigger_y = @event_y + TRIGGER_Y_OFFSET
      
      @trigger_rect = Rect.new(@zone_rect.x - 1, trigger_y - 1, @zone_rect.width + 2, 2)
      
      @original_tiles = {}
      @priority_tiles = {}
    end
    
    def record_original_tile(x, y, z, tile_id)
      @original_tiles[[x, y]] ||= {}
      @original_tiles[[x, y]][z] = tile_id
    end
    
    def record_priority_tile(x, y, z, tile_id)
      @priority_tiles[[x, y]] ||= {}
      @priority_tiles[[x, y]][z] = tile_id
    end

    def activate
      return if @is_active
      @is_active = true
      
      (@zone_rect.x...@zone_rect.x + @zone_rect.width).each do |x|
        y = @zone_rect.y
        coords = [x, y]
        
        p_tiles = @priority_tiles[coords] || {}
        
        consolidated_tile = 0
        if p_tiles[:fused] && p_tiles[:fused] > 0
          consolidated_tile = p_tiles[:fused]
        elsif p_tiles[2] && p_tiles[2] > 0
          consolidated_tile = p_tiles[2]
        elsif p_tiles[1] && p_tiles[1] > 0
          consolidated_tile = p_tiles[1]
        end
        
        $game_map.data[x, y, 1] = consolidated_tile
        $game_map.data[x, y, 2] = 0
      end
    end
    
    def deactivate
      return unless @is_active
      @is_active = false
      
      (@zone_rect.x...@zone_rect.x + @zone_rect.width).each do |x|
        y = @zone_rect.y
        coords = [x, y]
        
        o_tiles = @original_tiles[coords] || {}
        $game_map.data[x, y, 1] = o_tiles[1] || 0
        $game_map.data[x, y, 2] = o_tiles[2] || 0
      end
    end
  end

  class Manager
    def initialize
      @zones = []
      @tileset_backup = nil
      @next_copy_id = TILE_COPY_START_ID
      @tile_map = {}
      @fused_tile_map = {}
    end
    
    def setup(map)
      @map = map
      @tileset = $data_tilesets[@map.tileset_id]
      @tileset_bmp = RPG::Cache.tileset(@tileset.tileset_name)
      @tileset_backup = @tileset_bmp.clone
      
      @map.events.values.each do |event|
        if event.name =~ EVENT_NAME_REGEX
          width = $1.to_i
          next if width <= 0
          
          zone = PriorityZone.new(event, width)
          process_zone_tiles(zone)
          @zones << zone
        end
      end
      
      update
    end
    
    def process_zone_tiles(zone)
      (zone.zone_rect.x...zone.zone_rect.x + zone.zone_rect.width).each do |x|
        y = zone.zone_rect.y
        
        original_id_z1 = @map.data[x, y, 1]
        original_id_z2 = @map.data[x, y, 2]
        zone.record_original_tile(x, y, 1, original_id_z1)
        zone.record_original_tile(x, y, 2, original_id_z2)
        
        unless @tile_map.key?(original_id_z1)
          @tile_map[original_id_z1] = create_tile_copy(original_id_z1)
        end
        new_id_z1 = @tile_map[original_id_z1]
        
        unless @tile_map.key?(original_id_z2)
          @tile_map[original_id_z2] = create_tile_copy(original_id_z2)
        end
        new_id_z2 = @tile_map[original_id_z2]
        
        zone.record_priority_tile(x, y, 1, new_id_z1)
        zone.record_priority_tile(x, y, 2, new_id_z2)
        
        if new_id_z1 > 0 && new_id_z2 > 0
          pair = [original_id_z1, original_id_z2]
          unless @fused_tile_map.key?(pair)
            @fused_tile_map[pair] = create_fused_tile(pair[0], pair[1])
          end
          fused_id = @fused_tile_map[pair]
          zone.record_priority_tile(x, y, :fused, fused_id)
        end
      end
    end

    def create_tile_copy(original_id)
      return 0 unless original_id > 0
      new_db_id = get_next_id
      draw_tile(@tileset_bmp, original_id, new_db_id, true)
      return new_db_id + TILE_OFFSET
    end
    
    def create_fused_tile(id_bottom, id_top)
      new_db_id = get_next_id
      draw_tile(@tileset_bmp, id_bottom, new_db_id, true)
      draw_tile(@tileset_bmp, id_top, new_db_id, false)
      return new_db_id + TILE_OFFSET
    end

    def draw_tile(dest_bmp, source_id, dest_db_id, clear_first)
      dest_x = (dest_db_id % TILESET_COLS) * 32
      dest_y = (dest_db_id / TILESET_COLS) * 32
      dest_bmp.fill_rect(dest_x, dest_y, 32, 32, Color.new(0,0,0,0)) if clear_first
      
      if source_id < TILE_OFFSET
        autotile_name = @tileset.autotile_names[source_id / 48]
        unless autotile_name.empty?
          autotile_bmp = RPG::Cache.autotile(autotile_name)
          src_rect = Rect.new(32, 0, 32, 32)
          dest_bmp.blt(dest_x, dest_y, autotile_bmp, src_rect)
        end
      else
        source_db_id = source_id - TILE_OFFSET
        src_x = (source_db_id % TILESET_COLS) * 32
        src_y = (source_db_id / TILESET_COLS) * 32
        src_rect = Rect.new(src_x, src_y, 32, 32)
        dest_bmp.blt(dest_x, dest_y, @tileset_backup, src_rect)
      end
    end
    
    def get_next_id
      id = @next_copy_id
      @next_copy_id += 1
      return id
    end
    
    def update
      return if @zones.empty?
      
      characters_to_check = [$game_player]
      $game_map.events.values.each do |event|
        characters_to_check << event if event.character_name != ""
      end
      
      @zones.each do |zone|
        is_triggered_by_anyone = false
        
        characters_to_check.each do |character|
          rect = zone.trigger_rect
          if character.x >= rect.x && character.x < (rect.x + rect.width) &&
             character.y >= rect.y && character.y < (rect.y + rect.height)
            is_triggered_by_anyone = true
            break
          end
        end
        
        if is_triggered_by_anyone
          zone.activate
        else
          zone.deactivate
        end
      end
    end
    
    def dispose
      return unless @tileset_backup
      @tileset_bmp.clear
      @tileset_bmp.blt(0, 0, @tileset_backup, @tileset_backup.rect)
      @tileset_backup.dispose
      @tileset_backup = nil
      @zones.clear
    end
  end
  
  $dynamic_tiles_manager = nil
end

class Spriteset_Map
  alias_method :dynamic_tiles_initialize, :initialize
  alias_method :dynamic_tiles_dispose, :dispose
  alias_method :dynamic_tiles_update, :update

  def initialize(viewport = nil)
    dynamic_tiles_initialize(viewport)

    @dynamic_tiles_manager = DynamicPriorityTiles::Manager.new
    @setup_run = false
    @map_id = $game_map.map_id
  end

  def dispose
    @dynamic_tiles_manager.dispose if @dynamic_tiles_manager
    dynamic_tiles_dispose
  end

  def update
    dynamic_tiles_update

    if @map_id != $game_map.map_id
      @dynamic_tiles_manager.dispose if @dynamic_tiles_manager
      @dynamic_tiles_manager = DynamicPriorityTiles::Manager.new
      @map_id = $game_map.map_id
      @setup_run = false 
    end
    
    unless @setup_run
      @dynamic_tiles_manager.setup($game_map)
      @setup_run = true
    end
    
    @dynamic_tiles_manager.update if @dynamic_tiles_manager
  end
end