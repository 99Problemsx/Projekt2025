#!/usr/bin/env ruby
#===============================================================================
# * Schneller Map022 Converter für Tiled
# * Konvertiert die Ranch Map zu TMX Format
#===============================================================================

# Führe diesen Script aus dem Projekt-Root aus:
# ruby TiledConverter/convert_map022.rb

require_relative 'tiled_converter.rb'

puts "🗺️  Converting Ranch Map (022) to Tiled format..."
puts "=" * 50

begin
  # Erstelle Converter
  converter = TiledConverter.new
  
  # Konvertiere Map 022 (Ranch)
  success = converter.export_map_to_tiled(22, "TiledMaps")
  
  if success
    puts ""
    puts "✅ SUCCESS! Ranch Map exported!"
    puts "📁 File: TiledMaps/Map022.tmx"
    puts ""
    puts "🎯 Next Steps:"
    puts "1. Open Tiled (https://www.mapeditor.org/)"
    puts "2. File > Open > TiledMaps/Map022.tmx"
    puts "3. Edit your map in Tiled"
    puts "4. Save and use converter to import back"
    puts ""
  else
    puts ""
    puts "❌ FAILED! Check error messages above"
    puts "Make sure you're running from the project root directory"
    puts ""
  end
  
rescue => e
  puts ""
  puts "❌ ERROR: #{e.message}"
  puts e.backtrace.join("\n")
  puts ""
  puts "Make sure you have:"
  puts "- Ruby installed"
  puts "- Running from project root"
  puts "- Data/Map022.rxdata exists"
end

puts "=" * 50

