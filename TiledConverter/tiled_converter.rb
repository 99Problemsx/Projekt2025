#===============================================================================
# * Tiled Map Converter für Pokémon Essentials
# * Konvertiert zwischen Essentials .rxdata und Tiled .tmx Formaten
#===============================================================================

require 'rexml/document'
require 'json'

class TiledConverter
  
  def initialize
    @tilesets = {}
    @maps = {}
    echoln("TiledConverter initialized")
  end
  
  #=============================================================================
  # * Export Essentials Map zu Tiled TMX
  #=============================================================================
  
  def export_map_to_tiled(map_id, output_dir = "TiledMaps")
    begin
      # Lade Essentials Map Daten
      map_filename = sprintf("Data/Map%03d.rxdata", map_id)
      unless File.exist?(map_filename)
        echoln("Error: Map file #{map_filename} not found!")
        return false
      end
      
      echoln("Exporting Map #{map_id} to Tiled format...")
      
      # Lade Map Daten
      map_data = load_data(map_filename)
      
      # Erstelle Output Directory
      Dir.mkdir(output_dir) unless Dir.exist?(output_dir)
      
      # Konvertiere zu TMX
      tmx_content = convert_map_to_tmx(map_data, map_id)
      
      # Speichere TMX Datei
      output_file = File.join(output_dir, "Map#{sprintf('%03d', map_id)}.tmx")
      File.write(output_file, tmx_content)
      
      echoln("Map exported successfully to: #{output_file}")
      return true
      
    rescue => e
      echoln("Error exporting map: #{e.message}")
      echoln(e.backtrace.join("\n"))
      return false
    end
  end
  
  def convert_map_to_tmx(map_data, map_id)
    # Erstelle TMX XML Dokument
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new
    
    # Map Root Element
    map_element = doc.add_element('map')
    map_element.add_attributes({
      'version' => '1.10',
      'tiledversion' => '1.11.2', 
      'orientation' => 'orthogonal',
      'renderorder' => 'right-down',
      'width' => map_data.width.to_s,
      'height' => map_data.height.to_s,
      'tilewidth' => '32',
      'tileheight' => '32',
      'infinite' => '0',
      'nextlayerid' => '10',
      'nextobjectid' => '1'
    })
    
    # Tileset Referenzen hinzufügen
    add_tilesets_to_tmx(map_element, map_data)
    
    # Layer hinzufügen (3 Ebenen in Essentials)
    (0..2).each do |layer_id|
      add_layer_to_tmx(map_element, map_data, layer_id)
    end
    
    # Events als Objektebene hinzufügen
    add_events_to_tmx(map_element, map_id)
    
    # Formatiere XML
    formatter = REXML::Formatters::Pretty.new
    output = ""
    formatter.write(doc, output)
    
    return output
  end
  
  def add_tilesets_to_tmx(map_element, map_data)
    # Essentials verwendet normalerweise wenige Tilesets
    # Haupt-Tileset hinzufügen
    tileset = map_element.add_element('tileset')
    tileset.add_attributes({
      'firstgid' => '1',
      'name' => 'MainTileset',
      'tilewidth' => '32',
      'tileheight' => '32',
      'tilecount' => '384', # 12x32 Tiles typisch
      'columns' => '12'
    })
    
    # Tileset Bild
    image = tileset.add_element('image')
    image.add_attributes({
      'source' => '../Graphics/Tilesets/001.png', # Anpassen je nach Map
      'width' => '384',
      'height' => '1024'
    })
  end
  
  def add_layer_to_tmx(map_element, map_data, layer_id)
    layer = map_element.add_element('layer')
    layer.add_attributes({
      'id' => (layer_id + 1).to_s,
      'name' => "Layer#{layer_id}",
      'width' => map_data.width.to_s,
      'height' => map_data.height.to_s
    })
    
    # Tile Daten
    data_element = layer.add_element('data')
    data_element.add_attributes({'encoding' => 'csv'})
    
    # Konvertiere Essentials Tile-Daten zu Tiled Format
    csv_data = []
    (0...map_data.height).each do |y|
      (0...map_data.width).each do |x|
        tile_id = map_data.data[x, y, layer_id] || 0
        # Tiled verwendet 1-basierte IDs, Essentials 0-basierte
        csv_data << (tile_id == 0 ? 0 : tile_id + 1)
      end
    end
    
    # Formatiere als CSV
    csv_string = csv_data.each_slice(map_data.width).map { |row| row.join(',') }.join(",\n")
    data_element.text = "\n#{csv_string}\n"
  end
  
  def add_events_to_tmx(map_element, map_id)
    # Lade Events für diese Map
    begin
      mapinfos = load_data("Data/MapInfos.rxdata")
      return unless mapinfos[map_id] # Map existiert nicht
      
      # Events Objektebene
      objectgroup = map_element.add_element('objectgroup')
      objectgroup.add_attributes({
        'id' => '4',
        'name' => 'Events'
      })
      
      # Lade Map für Events (falls verfügbar)
      map_file = sprintf("Data/Map%03d.rxdata", map_id)
      if File.exist?(map_file)
        map = load_data(map_file)
        
        map.events.each do |event_id, event|
          next unless event
          
          object = objectgroup.add_element('object')
          object.add_attributes({
            'id' => event_id.to_s,
            'name' => event.name || "Event#{event_id}",
            'x' => (event.x * 32).to_s,
            'y' => (event.y * 32).to_s,
            'width' => '32',
            'height' => '32'
          })
          
          # Event Properties hinzufügen
          properties = object.add_element('properties')
          
          # Event Pages als Properties
          event.pages.each_with_index do |page, page_index|
            next unless page
            
            prop = properties.add_element('property')
            prop.add_attributes({
              'name' => "page_#{page_index}_graphic",
              'value' => page.graphic.character_name || ""
            })
            
            if page.list && !page.list.empty?
              prop = properties.add_element('property')
              prop.add_attributes({
                'name' => "page_#{page_index}_commands",
                'value' => page.list.length.to_s
              })
            end
          end
        end
      end
      
    rescue => e
      echoln("Warning: Could not add events for map #{map_id}: #{e.message}")
    end
  end
  
  #=============================================================================
  # * Import Tiled TMX zu Essentials Map
  #=============================================================================
  
  def import_map_from_tiled(tmx_file, map_id)
    begin
      echoln("Importing TMX file: #{tmx_file} to Map #{map_id}")
      
      unless File.exist?(tmx_file)
        echoln("Error: TMX file #{tmx_file} not found!")
        return false
      end
      
      # Parse TMX
      doc = REXML::Document.new(File.read(tmx_file))
      map_element = doc.root
      
      # Konvertiere zu Essentials Format
      map_data = convert_tmx_to_map(map_element, map_id)
      
      # Speichere als .rxdata
      output_file = sprintf("Data/Map%03d.rxdata", map_id)
      save_data(map_data, output_file)
      
      echoln("Map imported successfully to: #{output_file}")
      return true
      
    rescue => e
      echoln("Error importing TMX: #{e.message}")
      echoln(e.backtrace.join("\n"))
      return false
    end
  end
  
  def convert_tmx_to_map(map_element, map_id)
    # Erstelle neue RPG::Map Struktur
    map = RPG::Map.new
    
    # Map Eigenschaften
    map.width = map_element.attributes['width'].to_i
    map.height = map_element.attributes['height'].to_i
    
    # 3D Array für Tile Daten (x, y, z)
    map.data = Table.new(map.width, map.height, 3)
    
    # Parse Layer
    layer_index = 0
    map_element.elements.each('layer') do |layer|
      break if layer_index >= 3 # Max 3 Layer in Essentials
      
      parse_layer_data(layer, map, layer_index)
      layer_index += 1
    end
    
    # Parse Events
    map.events = {}
    map_element.elements.each('objectgroup') do |objectgroup|
      if objectgroup.attributes['name'] == 'Events'
        parse_events(objectgroup, map)
      end
    end
    
    return map
  end
  
  def parse_layer_data(layer, map, layer_index)
    data_element = layer.elements['data']
    return unless data_element
    
    if data_element.attributes['encoding'] == 'csv'
      csv_data = data_element.text.strip.split(',').map(&:to_i)
      
      index = 0
      (0...map.height).each do |y|
        (0...map.width).each do |x|
          tile_id = csv_data[index] || 0
          # Konvertiere von Tiled (1-basiert) zu Essentials (0-basiert)
          tile_id = tile_id == 0 ? 0 : tile_id - 1
          map.data[x, y, layer_index] = tile_id
          index += 1
        end
      end
    end
  end
  
  def parse_events(objectgroup, map)
    objectgroup.elements.each('object') do |object|
      event_id = object.attributes['id'].to_i
      
      event = RPG::Event.new
      event.name = object.attributes['name'] || "Event#{event_id}"
      event.x = (object.attributes['x'].to_f / 32).to_i
      event.y = (object.attributes['y'].to_f / 32).to_i
      
      # Einfache Event Page erstellen
      page = RPG::Event::Page.new
      page.graphic = RPG::Event::Page::Graphic.new
      
      # Properties parsen
      if object.elements['properties']
        object.elements['properties'].elements.each('property') do |prop|
          name = prop.attributes['name']
          value = prop.attributes['value']
          
          if name == 'page_0_graphic'
            page.graphic.character_name = value
          end
        end
      end
      
      event.pages = [page]
      map.events[event_id] = event
    end
  end
  
  #=============================================================================
  # * Batch Operations
  #=============================================================================
  
  def export_all_maps(output_dir = "TiledMaps")
    echoln("Exporting all maps to Tiled format...")
    
    exported = 0
    Dir.glob("Data/Map*.rxdata").each do |file|
      if file =~ /Map(\d+)\.rxdata/
        map_id = $1.to_i
        if export_map_to_tiled(map_id, output_dir)
          exported += 1
        end
      end
    end
    
    echoln("Successfully exported #{exported} maps to #{output_dir}/")
  end
  
  #=============================================================================
  # * Debug Commands
  #=============================================================================
  
  def debug_export_current_map
    current_map_id = $game_map ? $game_map.map_id : 1
    export_map_to_tiled(current_map_id)
  end
  
end

# Global Instance
$tiled_converter = TiledConverter.new

# Test function for immediate use
def test_convert_ranch_map
  converter = TiledConverter.new
  success = converter.export_map_to_tiled(22, "TiledMaps")
  if success
    puts "✅ Ranch Map (022) successfully exported to TiledMaps/Map022.tmx"
    puts "You can now open TiledMaps/Map022.tmx in Tiled!"
  else
    puts "❌ Export failed - check console for errors"
  end
end

#=============================================================================
# * Debug Menu Integration
#=============================================================================

MenuHandlers.add(:debug_menu, :export_map_tiled, {
  "name"        => _INTL("Export Map to Tiled"),
  "parent"      => :editors_menu,
  "description" => _INTL("Export current map to Tiled TMX format."),
  "effect"      => proc {
    $tiled_converter.debug_export_current_map
    pbMessage(_INTL("Map exported to TiledMaps/ folder!"))
  }
})

MenuHandlers.add(:debug_menu, :export_all_maps_tiled, {
  "name"        => _INTL("Export All Maps to Tiled"),
  "parent"      => :editors_menu, 
  "description" => _INTL("Export all maps to Tiled TMX format."),
  "effect"      => proc {
    $tiled_converter.export_all_maps
    pbMessage(_INTL("All maps exported to TiledMaps/ folder!"))
  }
})

MenuHandlers.add(:debug_menu, :import_map_tiled, {
  "name"        => _INTL("Import Map from Tiled"),
  "parent"      => :editors_menu,
  "description" => _INTL("Import TMX file as Essentials map."),
  "effect"      => proc {
    # Einfache Map ID Eingabe
    map_id = pbEnterText(_INTL("Enter Map ID to import to:"), 0, 3).to_i
    if map_id > 0
      tmx_file = "TiledMaps/Map#{sprintf('%03d', map_id)}.tmx"
      if $tiled_converter.import_map_from_tiled(tmx_file, map_id)
        pbMessage(_INTL("Map imported successfully!"))
      else
        pbMessage(_INTL("Import failed! Check console for errors."))
      end
    end
  }
})

echoln("Tiled Converter loaded! Available in Debug Menu > Editors")
