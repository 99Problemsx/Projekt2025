# ============================================================================
# Integration Script für verschlüsselte Assets
# ============================================================================
# Füge diesen Code am ANFANG deiner Scripts ein (vor allem anderen!)
# Z.B. in Data/Scripts/001_Start.rb oder ähnlich
# ============================================================================

# Lade den Game Loader
begin
  require_relative '../../game_loader'
  puts "Verschlüsselte Assets geladen!"
rescue LoadError => e
  puts "WARNUNG: game_loader.rb nicht gefunden - normale Dateien werden verwendet"
  puts "Fehler: #{e.message}"
end

# Optional: Integritätsprüfung beim Start
if defined?(GameLoader) && GameLoader.respond_to?(:load_package)
  unless GameLoader.send(:class_variable_get, :@@package_loaded)
    puts "FEHLER: Package konnte nicht geladen werden!"
    puts "Stelle sicher, dass GameData.pack vorhanden ist."
    # Optional: Beende das Spiel
    # exit(1)
  end
end

# Ab hier normaler Script-Code...
